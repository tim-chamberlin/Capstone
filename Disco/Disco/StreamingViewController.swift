//
//  StreamingViewController.swift
//  Disco
//
//  Created by Tim on 8/28/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit



class StreamingViewController: TrackListViewController, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate {
    
    var session: SPTSession!
    var player: SPTAudioStreamingController = spotifyPlayer
    var hostedPlaylist: Playlist? = PlaylistController.sharedController.hostedPlaylist
    
    var isPlaying: Bool = false
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playbackControlsView: UIView!
    
    override func viewDidLoad() {
        
        title = hostedPlaylist?.name
        tableView.registerNib(UINib(nibName: "TrackTableViewCell", bundle: nil), forCellReuseIdentifier: "trackCell")
        
        spotifyPlayer.delegate = self
        spotifyPlayer.playbackDelegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.loadTrackList), name: kTrackListDidLoad, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StreamingViewController.updateNextUpList), name: kUpNextListDidUpdate, object: nil)
        
        addTrackObservers(forPlaylistType: .Hosting)
        
        let session = SPTAuth.defaultInstance().session
//        UserController.sharedController.loginToSpotifyUsingSession(session)
    }
    
    deinit {
        // TODO: Add modal view segue to streaming vc and alert user that they will stop playing music
        spotifyPlayer.logout()
        PlaylistController.sharedController.removeTrackObserverForPlaylist(hostedPlaylist!) { (success) in
            //
        }
    }
    
    override func updateNextUpList() {
        guard let playlist = playlist else { return }
        if !playlist.tracks.isEmpty {
//            self.playlist.tracks = self.playlist.tracks.filter { $0.firebaseUID != self.nowPlaying?.firebaseUID }
            playlist.tracks = TrackController.sortTracklistByVoteCount(playlist.tracks)
            tableView.reloadData()
        }
        if self.nowPlaying == nil {
            print("Queue new song to player")
            nowPlaying = playlist.tracks[0]
            guard let nowPlayingURI = nowPlaying?.spotifyURI else { return }
            SpotifyStreamingController.initializePlayerWithURI(nowPlayingURI)
        }
    }
    
    func presentWarningAlert() {
        let alert = UIAlertController(title: "Stop playing?", message: "If you exit this view, the music will stop playing!", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in
            return
        }
        let okayAction = UIAlertAction(title: "OK", style: .Default) { (_) in
            spotifyPlayer.logout()
            print("Spotify player logged out")
        }
        alert.addAction(cancelAction)
        alert.addAction(okayAction)
        self.presentViewController(alert, animated: true, completion: nil)
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
                    if !playlist.tracks.isEmpty {
                        self.nowPlaying = nil
                        self.nowPlaying = playlist.tracks[0]
                        self.popQueue()
                        spotifyPlayer.playSpotifyURI(self.nowPlaying?.spotifyURI, startingWithIndex: 0, startingWithPosition: 0, callback: { (error) in
                            if error == nil {
                                print("Started playing next track")
                            }
                        })
                    } else {
                        self.popQueue()
                        self.playButton.setTitle("Play", forState: .Normal)
                    }
                }
            })
        }
    }
    
    // Remove last nowPlaying, replace it with the playlist.tracks[0], update playlist.tracks
    func popQueue() {
        guard let playlist = playlist else { return }
        if !playlist.tracks.isEmpty {
            playlist.tracks = playlist.tracks.filter({ (track) -> Bool in
                return track != nowPlaying
            })
            playlist.tracks = TrackController.sortTracklistByVoteCount(playlist.tracks)
        } else { // TODO: else remove now playing and display "no songs" label
            self.nowPlaying = nil
        }
        tableView.reloadData()
    }
    
    // MARK: - IBACtions
    
    @IBAction override func addSongButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("addTrackToPlaylistSegue", sender: self)
    }
    
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
}
