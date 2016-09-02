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
    
    func didSetHostedPlaylist() {
        self.playlist = PlaylistController.sharedController.hostedPlaylist
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
        if let nowPlaying = nowPlaying {
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
            print("\(nowPlaying?.name) ended")
            moveToNextSong()
        }
    }
    
    // Delete track from playlist in Firebase, set playing to false, set next playing track, popQueue, set player with new nowPlaying
    func moveToNextSong() {
        guard let playlist = playlist else { return }
        guard let nowPlaying = nowPlaying else { return }
        PlaylistController.sharedController.removeTrack(nowPlaying, fromPlaylist: playlist) { (error) in
            spotifyPlayer.setIsPlaying(false, callback: { (error) in
                if error == nil {
                    guard let playlist = self.playlist else { return }
                    if !playlist.upNext.isEmpty {
                        self.nowPlaying = nil
                        self.nowPlaying = playlist.upNext[0]
                        spotifyPlayer.playSpotifyURI(self.nowPlaying?.spotifyURI, startingWithIndex: 0, startingWithPosition: 0, callback: { (error) in
                            if error == nil {
                                print("Started playing next track")
                            }
                        })
                    } else {
                        self.playButton.setTitle("Play", forState: .Normal)
                    }
                }
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
        if let _ = self.nowPlaying {
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
