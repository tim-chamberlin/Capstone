//
//  StreamingViewController.swift
//  Disco
//
//  Created by Tim on 8/28/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class StreamingViewController: TrackListViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate, UIPopoverPresentationControllerDelegate, SpotifyLogoutDelegate {
    
    var spotifyLoginVC: SpotifyLoginViewController!
    
    var player: SPTAudioStreamingController = spotifyPlayer
    var hostedPlaylist: Playlist?
    
    var isPlaying: Bool = false
    
    var nowPlayingPercentDone: Float = 0.0 {
        didSet {
//            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
//            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        }
    }
    
    
    @IBOutlet weak var spotifyProfilePictureImageView: UIImageView!
    @IBOutlet weak var spotifyUserName: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playbackControlsView: UIView!
    
    @IBOutlet weak var spotifyLoginContainer: UIView!
    
    override func viewDidLoad() {
        didSetHostedPlaylist()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.spotifyUserDidLogin(_:)), name: kSpotifyLoginNotificationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.didSetHostedPlaylist), name: kDidSetHostedPlaylist, object: nil)
        
        registerCustomCells()
        
        spotifyPlayer.delegate = self
        spotifyPlayer.playbackDelegate = self
        
        setupProfilePictureImageView()
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
        }
    }
    
    // MARK: - TrackTableViewCell Delegate Method
    
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
        UserController.sharedController.getCurrentSpotifyUserData(session) { (spotifyUser, success) in
            if success {
                guard let spotifyUser = spotifyUser else { return }
                self.spotifyUserName.text = spotifyUser.displayName
                
                ImageController.getImageFromURLWithResponse(spotifyUser.imageURL, completion: { (image, response, error) in
                    guard let image = image else { return }
                    self.spotifyProfilePictureImageView.image = image
                })
            }
        }
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
        try! spotifyPlayer.stop()
        dispatch_async(dispatch_get_main_queue(), {
            print("Spotify user logged out")
            
            self.spotifyLoginContainer.hidden = false
        })
        
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
                        self.playButton.setImage(UIImage(named: "Pause"), forState: .Normal)
                        print("Started playing \(newNowPlaying?.name)")
                    }
                })
            })
        } else { // there are no songs in the queue
            PlaylistController.sharedController.changeQueueInFirebase(queue, oldNowPlaying: queue.nowPlaying, newNowPlaying: nil, completion: { (newNowPlaying) in
                // stop playing
                do {
                    try spotifyPlayer.stop()
                    self.playButton.setImage(UIImage(named: "Play"), forState: .Normal)
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
    
    // MARK: - IBACtions

    
    @IBAction func playButtonTapped(sender: AnyObject) {
        guard let queue = playlist else { return }
        if let _ = queue.nowPlaying {
            SpotifyStreamingController.toggleIsPlaying(isPlaying, forQueue: queue) { [weak self] (isPlaying) in
                if isPlaying {
                    self?.playButton.setImage(UIImage(named: "Pause"), forState: .Normal)
                    self?.isPlaying = true
                } else {
                    self?.playButton.setImage(UIImage(named: "Play"), forState: .Normal)
                    self?.isPlaying = false
                }
            }
        } else if !queue.upNext.isEmpty {
            moveToNextSong({ 
                self.playButton.setImage(UIImage(named: "Pause"), forState: .Normal)
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
//        presentNamingDialog()
        
        PlaylistController.sharedController.createPlaylist(forUser: self.currentUser, withName: "\(currentUser.name)'s Queue", completion: { (success, playlist) in
            if success {
                guard let playlist = playlist, currentUser = UserController.sharedController.currentUser else { return }
                PlaylistController.sharedController.createPlaylistReferenceForUserID(playlist, userID: currentUser.FBID, playlistType: .Hosting, completion: { (success) in
                    print("New queue created")
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
        self.playButton.setImage(UIImage(named: "Play"), forState: .Normal)
        spotifyLoginVC.spotifyAuthViewController.clearCookies { 
            spotifyPlayer.logout()
        }
    }
}







