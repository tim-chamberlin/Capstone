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
    
    var isPlaying: Bool = false
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playbackControlsView: UIView!
    
    override func viewDidLoad() {
        title = playlist.name
        tableView.registerNib(UINib(nibName: "TrackTableViewCell", bundle: nil), forCellReuseIdentifier: "trackCell")
        
        
        
        spotifyPlayer.delegate = self
        spotifyPlayer.playbackDelegate = self
        
        addTrackObservers()
        let session = SPTAuth.defaultInstance().session
        UserController.sharedController.loginToSpotifyUsingSession(session)
        
    }
    
    override func addTrackObservers() {
        PlaylistController.sharedController.addTrackObserverForPlaylist(playlist) { (track, success) in
            dispatch_async(dispatch_get_main_queue(), {
                if let track = track {
                    self.playlist.tracks.append(track)
                    self.playlist.tracks = TrackController.sortTracklistByVoteCount(self.playlist.tracks)
                    self.nowPlaying = self.playlist.tracks[0]
                    self.upNext = self.playlist.tracks.filter({ (track) -> Bool in
                        return track != self.playlist.tracks[0]
                    })
                    
                    // Get current user's vote status for the track (always 0 for new tracks) and attach a listener for user votes
                    TrackController.sharedController.getVoteStatusForTrackWithID(track.firebaseUID, inPlaylistWithID: self.playlist.uid, ofType: .Hosting, user: self.currentUser, completion: { (voteStatus, success) in
                        track.currentUserVoteStatus = voteStatus
                        self.tableView.reloadData()
                    })
                    
                    TrackController.sharedController.attachVoteListener(forTrack: track, inPlaylist: self.playlist, completion: { (newVoteCount, success) in
                        track.voteCount = newVoteCount
                        self.playlist.tracks = TrackController.sortTracklistByVoteCount(self.playlist.tracks)
                        self.upNext = TrackController.sortTracklistByVoteCount(self.upNext)
                        self.tableView.reloadData()
                    })
                }
            })
        }
    }
    
    override func didPressVoteButton(sender: TrackTableViewCell, voteType: VoteType) {
        guard let currentUser = UserController.sharedController.currentUser, track = sender.track else { return }
        
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
        if !playlist.tracks.isEmpty {
            // Queue the first track
            let nowPlaying = self.playlist.tracks[0]
            self.playSongWithURI(nowPlaying.spotifyURI)
        }
    }
    
    func playSongWithURI(spotifyURI: String) {
        let url = NSURL(string: spotifyURI)
        if let player = spotifyPlayer {
            player.playURI(url, startingWithIndex: 0) { (error) in
                if error != nil {
                    print("Error playing track")
                } else {
                    print("Success")
                    self.addNextSongToQueue()
                    self.player.setIsPlaying(false, callback: { (error) in
                        if error != nil {
                            print(error)
                        }
                    })
                }
            }
        }
    }
    
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePlaybackState playbackState: SPTPlaybackState!) {
        
        if audioStreaming.currentPlaybackPosition > (audioStreaming.currentTrackDuration + 5) {
            print("Track is ending")
            if !upNext.isEmpty {
                playSongWithURI(self.upNext[0].spotifyURI)
            } else {
                return
            }
        }
    }
    
    func addNextSongToQueue() {
        if !playlist.tracks.isEmpty {
            guard let spotifyURL = NSURL(string: playlist.tracks[1].spotifyURL) else { return }
            player.queueURI(spotifyURL, callback: { (error) in
                if error != nil {
                    print(error)
                }
                
            })
        }
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didEncounterError error: NSError!) {
        print("Streaming error: \(error.localizedDescription)")
        presentErrorMessage()
        playbackControlsView.hidden = true
    }
    
    func toggleIsPlaying() {
        if isPlaying {
            player.setIsPlaying(false, callback: { (error) in
                if error != nil {
                    print(error)
                    self.isPlaying = true
                } else {
                    self.isPlaying = false
                    self.playButton.setTitle("Play", forState: .Normal)
                }
            })
        } else {
            player.setIsPlaying(true, callback: { (error) in
                if error != nil {
                    print(error)
                    self.isPlaying = false
                } else {
                    self.isPlaying = true
                    self.playButton.setTitle("Pause", forState: .Normal)
                }
            })
        }
    }
    
    @IBAction override func addSongButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("addTrackToPlaylistSegue", sender: self)
    }
    
    @IBAction func playButtonTapped(sender: AnyObject) {
        toggleIsPlaying()
    }
    
    @IBAction func nextButtonTapped(sender: AnyObject) {
        spotifyPlayer.skipNext { (error) in
            //
        }
    }
    
    @IBAction func previousButtonTapped(sender: AnyObject) {
        spotifyPlayer.skipPrevious { (error) in
            //
        }
    }
    
}
