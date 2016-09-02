//
//  StreamingViewController.swift
//  Disco
//
//  Created by Tim on 8/28/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit



class StreamingViewController: TrackListViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
    var spotifyLoginVC: SpotifyLoginViewController!
    
    var session: SPTSession!
    var player: SPTAudioStreamingController = spotifyPlayer
    var hostedPlaylist: Playlist? = PlaylistController.sharedController.hostedPlaylist
    
    var isPlaying: Bool = false
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playbackControlsView: UIView!
    @IBOutlet weak var spotifyLoginContainer: UIView!
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.spotifyUserDidLogin(_:)), name: kSpotifyLoginNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didSetHostedPlaylist), name: kDidSetHostedPlaylist, object: nil)
        
        tableView.registerNib(UINib(nibName: "TrackTableViewCell", bundle: nil), forCellReuseIdentifier: "trackCell")
        
        checkSpotifyAuth()
        
        spotifyPlayer.delegate = self
        spotifyPlayer.playbackDelegate = self
    }
    
    deinit {
        // TODO: Add modal view segue to streaming vc and alert user that they will stop playing music
        spotifyPlayer.logout()
        PlaylistController.sharedController.removeTrackObserverForPlaylist(hostedPlaylist!) { (success) in
            //
        }
    }
    
    func addTrackObservers(forPlaylistType playlistType: PlaylistType) {
        guard let queue = playlist, currentUser = UserController.sharedController.currentUser else { return }
        PlaylistController.sharedController.addUpNextObserverToQueue(queue) { (track, didAdd) in
            if let track = track {
                if didAdd {
                    queue.upNext.append(track)
                    self.updateTableViewWithQueueData()
                    
                    // Add vote observers
                    TrackController.sharedController.getVoteStatusForTrackWithID(track.firebaseUID, inPlaylistWithID: queue.uid, ofType: playlistType, user: currentUser, completion: { (voteStatus, success) in
                        if success {
                            track.currentUserVoteStatus = voteStatus
                            self.updateTableViewWithQueueData()
                        }
                    })
                    TrackController.sharedController.attachVoteListener(forTrack: track, inPlaylist: queue, completion: { (newVoteCount, success) in
                        track.voteCount = newVoteCount
                        self.updateTableViewWithQueueData()
                    })
                } else { // Track removed
                    queue.upNext = queue.upNext.filter { $0 != track }
                    self.updateTableViewWithQueueData()
                }
            }
        }
    }
    
    func updateTableViewWithQueueData() {
        guard let queue = playlist else { return }
        queue.upNext = TrackController.sortTracklistByVoteCount(queue.upNext)
        tableView.reloadData()
    }
    

    func didSetHostedPlaylist() {
        self.playlist = PlaylistController.sharedController.hostedPlaylist
        addTrackObservers(forPlaylistType: .Hosting)
        tableView.reloadData()
    }
    
    override func didPressVoteButton(sender: TrackTableViewCell, voteType: VoteType) {
        guard let currentUser = UserController.sharedController.currentUser, track = sender.track else { return }
        guard let playlist = playlist else { return }
        
        TrackController.sharedController.user(currentUser, didVoteWithType: voteType, withVoteStatus: (sender.track?.currentUserVoteStatus)!, onTrack: track, inPlaylist: playlist, ofPlaylistType: .Hosting) { (success) in
            //
        }
    }
    
    func presentErrorMessage() {
        let alert = UIAlertController(title: "You aren't a Spotify Premium Member", message: "You must be logged into a Spotify Premium account to stream music. You can still make cool playlists though!", preferredStyle: .Alert)
        let okayAction = UIAlertAction(title: "OK", style: .Default) { (_) in
            return
        }
        alert.addAction(okayAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Spotify Check Auth
    
    func setupSpotifyLoginView() {
        if let session = SPTAuth.defaultInstance().session {
            if session.isValid() {
                // Spotify session is valid
                self.spotifyLoginContainer.hidden = true
                return
            } else {
                self.spotifyLoginContainer.hidden = false
                return
            }
        } else {
            self.spotifyLoginContainer.hidden = false
        }
    }
    
    func checkSpotifyAuth() {
        let auth = SPTAuth.defaultInstance()
        
        if auth.session == nil {
            setupSpotifyLoginView()
            return
        }
        if !auth.session.isValid() {
            // Should hide login
            setupSpotifyLoginView()
            return
        }
        
        if auth.hasTokenRefreshService {
            renewSpotifyTokenAndShowPlayer()
            setupSpotifyLoginView()
        } else {
            // Should show login
            setupSpotifyLoginView()
        }
    }
    
    func spotifyUserDidLogin(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? [String: SPTSession], session = userInfo[kSpotifyLoginNotificationKey] else { return }
        checkSpotifyAuth()
        UserController.sharedController.loginToSpotifyUsingSession(session)
    }
    
    func renewSpotifyTokenAndShowPlayer() {
        let auth = SPTAuth.defaultInstance()
        auth.renewSession(auth.session) { (error, session) in
            auth.session = session
            if (error != nil) {
                print("Error renewing Spotify session")
                return
            }
            // show player
        }
    }
    
    // MARK: - Spotify Streaming
    
    func audioStreamingDidLogin(audioStreaming: SPTAudioStreamingController!) {
        // Queue the first track when audio streaming controller logs in
        if let nowPlaying = playlist?.nowPlaying {
            SpotifyStreamingController.initializePlayerWithURI(nowPlaying.spotifyURI)
        }
    }
    
    func audioStreamingDidLogout(audioStreaming: SPTAudioStreamingController!) {
        //
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didEncounterError error: NSError!) {
        print("Streaming error: \(error.localizedDescription)")
        presentErrorMessage()
        playbackControlsView.hidden = true
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePosition position: NSTimeInterval) {
        if (((audioStreaming.metadata.currentTrack?.duration)! - position) < 0.75) {
            // Queue next song
            print("\(playlist?.nowPlaying?.name) ended")
            moveToNextSong()
        }
    }
    
    // Delete track from playlist in Firebase, set playing to false, set next playing track, popQueue, set player with new nowPlaying
    func moveToNextSong() {
        guard let queue = playlist else { return }
        if !queue.upNext.isEmpty {
            PlaylistController.sharedController.changeQueueInFirebase(queue, oldNowPlaying: queue.nowPlaying, newNowPlaying: queue.upNext[0], completion: { (newNowPlaying) in
                spotifyPlayer.playSpotifyURI(newNowPlaying?.spotifyURI, startingWithIndex: 0, startingWithPosition: 0, callback: { (error) in
                    if error == nil {
                        print("Started playing \(newNowPlaying?.name)")
                    }
                })
            })
        } else { // there are no songs in the queue
            PlaylistController.sharedController.changeQueueInFirebase(queue, oldNowPlaying: queue.nowPlaying, newNowPlaying: nil, completion: { (newNowPlaying) in
                // stop playing
            })
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedSpotifyLoginSegue" {
            spotifyLoginVC = segue.destinationViewController as! SpotifyLoginViewController
        } else if segue.identifier == "addTrackToPlaylistSegue" {
            let navVC = segue.destinationViewController as? UINavigationController
            guard let searchVC = navVC?.viewControllers.first as? SpotifySearchTableViewController else { return }
            searchVC.delegate = self
        }
    }
    
    // MARK: - IBACtions

    
    @IBAction func playButtonTapped(sender: AnyObject) {
        if let _ = playlist?.nowPlaying {
            SpotifyStreamingController.toggleIsPlaying(isPlaying) { [weak self] (isPlaying) in
                if isPlaying {
                    self?.playButton.setTitle("Pause", forState: .Normal)
                    self?.isPlaying = true
                } else {
                    self?.playButton.setTitle("Play", forState: .Normal)
                    self?.isPlaying = false
                }
            }
        } else {
            return
        }
    }
    
    @IBAction func nextButtonTapped(sender: AnyObject) {
        moveToNextSong()
    }
    
    @IBAction func addTrackButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("addTrackToPlaylistSegue", sender: self)
    }
}
