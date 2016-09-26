//
//  StreamingViewController.swift
//  Disco
//
//  Created by Tim on 8/28/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit
import MediaPlayer

class StreamingViewController: TrackListViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate, UIPopoverPresentationControllerDelegate, SpotifyLogoutDelegate {
    
    var spotifyLoginVC: SpotifyLoginViewController!
    
    var player: SPTAudioStreamingController = spotifyPlayer
    var playbackState: SPTPlaybackState?
    
    @IBOutlet weak var spotifyProfilePictureImageView: UIImageView!
    @IBOutlet weak var spotifyUserName: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var trackProgressView: UIProgressView!
    @IBOutlet weak var playbackControlsView: UIView!
    @IBOutlet weak var spotifyLoginContainer: UIView!
    
    override func viewDidLoad() {
        UserController.sharedController.checkSpotifyUserAuth { (loggedIn, session) in
            if loggedIn {
                dispatch_async(dispatch_get_main_queue(), {
                    self.setupViewWithSpotifySession(session)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("Spotify user doesn't have a session")
                    self.setupSpotifyAuthView()
                })
            }
        }
        didSetHostedPlaylist()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.spotifyUserDidLogin(_:)), name: kSpotifyLoginNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didSetHostedPlaylist), name: kDidSetHostedPlaylist, object: nil)
        registerCustomCells()
        spotifyPlayer.delegate = self
        spotifyPlayer.playbackDelegate = self
        
        spotifyProfilePictureImageView.backgroundColor = UIColor.blueColor()
        
    }
    
    deinit {
        try! spotifyPlayer.stop()
        spotifyPlayer.logout()
    }
    
    func setupProfilePictureImageView() {
        spotifyProfilePictureImageView.layer.cornerRadius = spotifyProfilePictureImageView.frame.width/2
        spotifyProfilePictureImageView.contentMode = .ScaleAspectFill
        spotifyProfilePictureImageView.layer.masksToBounds = true
    }

    func didSetHostedPlaylist() {
        if let playlist = PlaylistController.sharedController.hostedPlaylist {
            self.playlist = playlist
            addTrackObservers(forPlaylistType: .Hosting)
            tableView.reloadData()
            setupViewForEmptyQueue()
            MusicStreamingController.initializeMPRemoteCommandCenterForQueue(playlist)
        }
    }
    
    // MARK: - TrackTableViewCell Delegate Method
    
    override func didPressVoteButton(sender: TrackTableViewCell, voteType: VoteType) {
        guard let currentUser = UserController.sharedController.currentUser, track = sender.track else { return }
        guard let playlist = playlist else { return }
        
        TrackController.user(currentUser, didVoteWithType: voteType, withVoteStatus: (sender.track?.currentUserVoteStatus)!, onTrack: track, inPlaylist: playlist, ofPlaylistType: .Hosting) { (success) in
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
    
    // MARK: - Spotify Setup
    
    func setupViewWithSpotifySession(session: SPTSession?) {
        if let session = session { // Valid session
            UserController.sharedController.loginToSpotifyUsingSession(session)
            setupProfilePictureImageView()
            setupViewForEmptyQueue()
            UserController.sharedController.getCurrentSpotifyUserData(session) { (spotifyUser, success) in
                if success {
                    dispatch_async(dispatch_get_main_queue(), {
                        guard let spotifyUser = spotifyUser else { return }
                        let nameToDisplay = spotifyUser.displayName ?? spotifyUser.canonicalUserName
                        self.spotifyUserName.text = nameToDisplay
                        
                        // Retrieve image if it exists
                        if let imageURL = spotifyUser.imageURL {
                            ImageController.getImageFromURLWithResponse(imageURL, completion: { (image, response, error) in
                                guard let image = image else { return }
                                self.spotifyProfilePictureImageView.image = image
                                
                            })
                        }
                    })
                }
            }
        }
        setupSpotifyAuthView()
    }
    
    func setupSpotifyAuthView() {
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
    
    func spotifyUserDidLogin(notification: NSNotification) {
        guard let userInfo = notification.userInfo as? [String: SPTSession], session = userInfo[kSpotifyLoginNotificationKey] else { return }
        setupViewWithSpotifySession(session)
    }
    
    // MARK: - Spotify Streaming Delegate Methods
    
    func audioStreamingDidLogin(audioStreaming: SPTAudioStreamingController!) {
        guard let queue = playlist else { return }
        // Queue the first track when audio streaming controller logs in
        if let nowPlaying = queue.nowPlaying {
            MusicStreamingController.initializePlayerWithURI(nowPlaying.spotifyURI)
            return
        }
        if !queue.upNext.isEmpty {
            MusicStreamingController.initializePlayerWithURI(queue.upNext[0].spotifyURI)
        }
    }
    
    func audioStreamingDidLogout(audioStreaming: SPTAudioStreamingController!) {
        try! spotifyPlayer.stop()
        dispatch_async(dispatch_get_main_queue(), {
            print("Spotify user logged out")
            
            self.spotifyLoginContainer.hidden = false
        })
    }
    
    func audioStreamingDidLosePermissionForPlayback(audioStreaming: SPTAudioStreamingController!) {
        setupSpotifyAuthView()
    }
    
    func audioStreamingDidDisconnect(audioStreaming: SPTAudioStreamingController!) {
        setupSpotifyAuthView()
    }
    
    func audioStreamingDidReconnect(audioStreaming: SPTAudioStreamingController!) {
        setupSpotifyAuthView()
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        updatePlaybackUI()
        if let nowPlaying = playlist?.nowPlaying {
            MusicStreamingController.setMPNowPlayingInfoCenterForTrack(nowPlaying)
        }
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didEncounterError error: NSError!) {
        print("Streaming error: \(error.localizedDescription)")
        presentErrorMessage()
        playbackControlsView.hidden = true
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePosition position: NSTimeInterval) {
        
        trackProgressView.progress = Float(position/(spotifyPlayer.metadata.currentTrack?.duration)!)
        
        if (((audioStreaming.metadata.currentTrack?.duration)! - position) < 0.75) {
            // Queue next song
            print("\(playlist?.nowPlaying?.name) ended")
            guard let playlist = playlist else { return }
            MusicStreamingController.skipToNextTrack(inQueue: playlist, completion: {
                // update ui
                if playlist.upNext.isEmpty {
                    self.trackProgressView.progress = 0.0
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
            guard let searchVC = navVC?.viewControllers.first as? MusicSearchTableViewController else { return }
            searchVC.delegate = self
        } else if segue.identifier == "showLogoutPopover" {
            let vc = segue.destinationViewController as? SpotifyPopoverViewController
            vc?.delegate = self
            let controller = vc?.popoverPresentationController
            
            if let controller = controller, sourceView = controller.sourceView {
                controller.delegate = self
                controller.backgroundColor = UIColor.lightCharcoalColor()
                controller.sourceRect = CGRect(x: sourceView.frame.width * 0.25, y: 0, width: 0, height: 0)
            }
        }
    }
    
    func updatePlaybackUI() {
        // Check if player is loaded with song
        guard let playbackState = spotifyPlayer.playbackState else {
            playButton.setImage(UIImage(named: "Play"), forState: .Normal)
            return
        }
        
        let playPauseImage = playbackState.isPlaying ? UIImage(named: "Pause") : UIImage(named: "Play")
        playButton.setImage(playPauseImage, forState: .Normal)
    }
    
    // MARK: - IBActions

    @IBAction func playButtonTapped(sender: AnyObject) {
        guard let queue = playlist else { return }
        if let _ = queue.nowPlaying {
            MusicStreamingController.toggleIsPlaying(forQueue: queue) { (isPlaying) in
                self.updatePlaybackUI()
            }
        } else if !queue.upNext.isEmpty {
            
            MusicStreamingController.skipToNextTrack(inQueue: queue, completion: {
                PlaylistController.sharedController.setIsLive(true, forQueue: queue, completion: nil)
                self.updatePlaybackUI()
            })
        } else if queue.upNext.isEmpty {
            updatePlaybackUI()
        }
    }
    
    @IBAction func nextButtonTapped(sender: AnyObject) {
        guard let queue = playlist else { return }
        MusicStreamingController.skipToNextTrack(inQueue: queue) { 
            if queue.upNext.isEmpty {
                self.trackProgressView.progress = 0.0
            }
        }
    }
    
    @IBAction func addTrackButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("addTrackToPlaylistSegue", sender: self)
    }
    
    @IBAction override func addFirstSongToQueueTapped(sender: AnyObject) {
        PlaylistController.sharedController.createPlaylist(forUser: self.currentUser, withName: "\(currentUser.name)'s Queue", completion: { (success, playlist) in
            if success {
                guard let playlist = playlist, currentUser = UserController.sharedController.currentUser else { return }
                PlaylistController.sharedController.createPlaylistReferenceForUserID(playlist, userID: currentUser.FBID, playlistType: .Hosting, completion: { (success) in
                    self.performSegueWithIdentifier("addTrackToPlaylistSegue", sender: self)
                })
            }
        })
    }
    
    @IBAction func logoutOfSpotify(sender: AnyObject) {
        self.performSegueWithIdentifier("showLogoutPopover", sender: self)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func popoverViewDidLogoutSpotifyUser() {
        UserController.sharedController.logoutOfSpotify { 
            dispatch_async(dispatch_get_main_queue(), {
                self.playButton.setImage(UIImage(named: "Play"), forState: .Normal)
            })
        }
    }
}
