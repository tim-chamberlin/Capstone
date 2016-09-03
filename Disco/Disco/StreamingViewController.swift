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
    
    var player: SPTAudioStreamingController = spotifyPlayer
    var hostedPlaylist: Playlist? = PlaylistController.sharedController.hostedPlaylist
    
    var isPlaying: Bool = false
    
    var nowPlayingPercentDone: Float = 0.0 {
        didSet {
//            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
//            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        }
    }
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playbackControlsView: UIView!
    @IBOutlet weak var spotifyLoginContainer: UIView!
    
    override func viewDidLoad() {
//        checkSpotifyAuth()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.spotifyUserDidLogin(_:)), name: kSpotifyLoginNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didSetHostedPlaylist), name: kDidSetHostedPlaylist, object: nil)
        registerCustomCells()
//        tableView.registerNib(UINib(nibName: "TrackTableViewCell", bundle: nil), forCellReuseIdentifier: "trackCell")
        
        
        
        spotifyPlayer.delegate = self
        spotifyPlayer.playbackDelegate = self
    }
    
    deinit {
        // TODO: Add modal view segue to streaming vc and alert user that they will stop playing music
        spotifyPlayer.logout()
    }    

    func didSetHostedPlaylist() {
        self.playlist = PlaylistController.sharedController.hostedPlaylist
        addTrackObservers(forPlaylistType: .Hosting)
        tableView.reloadData()
        setupViewForEmptyQueue()
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
    
    // MARK: - TableViewDelegate
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCellWithIdentifier(nowPlayingCellReuseIdentifier, forIndexPath: indexPath) as? NowPlayingTableViewCell, playlist = playlist, nowPlaying = playlist.nowPlaying {
                let track = nowPlaying
                cell.updateCellWithTrack(track)
                cell.songProgressView.setProgress(nowPlayingPercentDone, animated: true)
                return cell
            }
        } else if indexPath.section == 1 {
            if let cell = tableView.dequeueReusableCellWithIdentifier(trackCellReuseIdentifier, forIndexPath: indexPath) as? TrackTableViewCell, playlist = playlist {
                if !playlist.upNext.isEmpty {
                    let track = playlist.upNext[indexPath.row]
                    cell.track = track
                    cell.voteStatus = track.currentUserVoteStatus
                    cell.updateCellWithTrack(track)
                    cell.delegate = self
                    return cell
                }
            }
        }
        return UITableViewCell()
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
        // There is a valid token
        setupSpotifyLoginView()
        UserController.sharedController.loginToSpotifyUsingSession(auth.session)
        
//        if auth.hasTokenRefreshService {
//            renewSpotifyTokenAndShowPlayer()
//            setupSpotifyLoginView()
//        }
    }
    
    func spotifyUserDidLogin(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? [String: SPTSession], session = userInfo[kSpotifyLoginNotificationKey] else { return }
        checkSpotifyAuth()
        setupViewForEmptyQueue()
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
    
    // MARK: - Spotify Streaming Delegate Methods
    
    func audioStreamingDidLogin(audioStreaming: SPTAudioStreamingController!) {
        guard let queue = playlist else { return }
        // Queue the first track when audio streaming controller logs in
        if let nowPlaying = queue.nowPlaying {
            SpotifyStreamingController.initializePlayerWithURI(nowPlaying.spotifyURI)
            return
        }
        if !queue.upNext.isEmpty {
            SpotifyStreamingController.initializePlayerWithURI(queue.upNext[0].spotifyURI)
        }
    }
    
    func audioStreamingDidLosePermissionForPlayback(audioStreaming: SPTAudioStreamingController!) {
        setupSpotifyLoginView()
    }
    
    func audioStreamingDidDisconnect(audioStreaming: SPTAudioStreamingController!) {
        setupSpotifyLoginView()
    }
    
    func audioStreamingDidReconnect(audioStreaming: SPTAudioStreamingController!) {
        setupSpotifyLoginView()
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
        
        let percentDone = position/(audioStreaming.metadata.currentTrack?.duration)!
        nowPlayingPercentDone = Float(percentDone)
        
        
        if (((audioStreaming.metadata.currentTrack?.duration)! - position) < 0.75) {
            // Queue next song
            print("\(playlist?.nowPlaying?.name) ended")
            moveToNextSong({ 
                //
            })
        }
    }
    
    // Delete track from playlist in Firebase, set playing to false, set next playing track, popQueue, set player with new nowPlaying
    func moveToNextSong(completion:() -> Void) {
        guard let queue = playlist else { return }
        if !queue.upNext.isEmpty {
            PlaylistController.sharedController.changeQueueInFirebase(queue, oldNowPlaying: queue.nowPlaying, newNowPlaying: queue.upNext[0], completion: { (newNowPlaying) in
                spotifyPlayer.playSpotifyURI(newNowPlaying?.spotifyURI, startingWithIndex: 0, startingWithPosition: 0, callback: { (error) in
                    if error == nil {
                        self.playButton.setTitle("Pause", forState: .Normal)
                        print("Started playing \(newNowPlaying?.name)")
                    }
                })
            })
        } else { // there are no songs in the queue
            PlaylistController.sharedController.changeQueueInFirebase(queue, oldNowPlaying: queue.nowPlaying, newNowPlaying: nil, completion: { (newNowPlaying) in
                // stop playing
                do {
                    try spotifyPlayer.stop()
                    self.playButton.setTitle("Play", forState: .Normal)
                } catch {
                    print("Can't stop, won't stop: \(error)")
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
        guard let queue = playlist else { return }
        if let _ = queue.nowPlaying {
            SpotifyStreamingController.toggleIsPlaying(isPlaying, forQueue: queue) { [weak self] (isPlaying) in
                if isPlaying {
                    self?.playButton.setTitle("Pause", forState: .Normal)
                    self?.isPlaying = true
                } else {
                    self?.playButton.setTitle("Play", forState: .Normal)
                    self?.isPlaying = false
                }
            }
        } else if !queue.upNext.isEmpty {
            moveToNextSong({ 
                self.playButton.setTitle("Pause", forState: .Normal)
                print("Started playing \(queue.upNext[0].name)")
            })
        } else if queue.upNext.isEmpty {
            SpotifyStreamingController.toggleIsPlaying(isPlaying, forQueue: queue, completion: { (isPlaying) in
                return
            })
        }
    }
    
    @IBAction func nextButtonTapped(sender: AnyObject) {
        moveToNextSong {
        }
    }
    
    @IBAction func addTrackButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("addTrackToPlaylistSegue", sender: self)
    }
    
    func presentNamingDialog() {
        let alert = UIAlertController(title: "Give your queue a name", message: "", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Name"
        }
        let okayAction = UIAlertAction(title: "OK", style: .Default) { (_) in
            if let text = alert.textFields?[0].text where !text.isEmpty {
                PlaylistController.sharedController.createPlaylist(forUser: self.currentUser, withName: text, completion: { (success, playlist) in
                    if success {
                        guard let playlist = playlist, currentUser = UserController.sharedController.currentUser else { return }
                        PlaylistController.sharedController.createPlaylistReferenceForUserID(playlist, userID: currentUser.FBID, playlistType: .Hosting, completion: { (success) in
                            print("New queue created")
                            self.performSegueWithIdentifier("addTrackToPlaylistSegue", sender: self)
                        })
                    }
                })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in
            return
        }
        alert.addAction(cancelAction)
        alert.addAction(okayAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction override func addFirstSongToQueueTapped(sender: AnyObject) {
        presentNamingDialog()
    }
    
}