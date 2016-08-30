//
//  StreamingViewController.swift
//  Disco
//
//  Created by Tim on 8/28/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

let kTrackInfoDidUpdate = "TrackInfoDidUpdate"

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
    
    deinit {
        // TODO: Add modal view segue to streaming vc and alert user that they will stop playing music
        spotifyPlayer.logout()
        PlaylistController.sharedController.removeTrackObserverForPlaylist(playlist) { (success) in
            //
        }
    }
    
    override func addTrackObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TrackListViewController.updateTrackData), name: kTrackInfoDidUpdate, object: nil)
        PlaylistController.sharedController.addTrackObserverForPlaylist(playlist) { [weak self] (track, didAdd) in
            dispatch_async(dispatch_get_main_queue(), {
                if let track = track, this = self {
                    if didAdd {
                        this.playlist.tracks.append(track)
                        NSNotificationCenter.defaultCenter().postNotificationName(kTrackInfoDidUpdate, object: nil)
                        
                        // Get current user's vote status for the track (always 0 for new tracks) and attach a listener for user votes
                        TrackController.sharedController.getVoteStatusForTrackWithID(track.firebaseUID, inPlaylistWithID: this.playlist.uid, ofType: .Hosting, user: this.currentUser, completion: { (voteStatus, success) in
                            track.currentUserVoteStatus = voteStatus
                            NSNotificationCenter.defaultCenter().postNotificationName(kTrackInfoDidUpdate, object: nil)
                        })
                        
                        // Listen for other votes
                        TrackController.sharedController.attachVoteListener(forTrack: track, inPlaylist: this.playlist, completion: { (newVoteCount, success) in
                            track.voteCount = newVoteCount
                            NSNotificationCenter.defaultCenter().postNotificationName(kTrackInfoDidUpdate, object: nil)
                        })
                    } else { // track removed
                        print("\(track.name) was removed from playlist \(this.playlist.uid)")
                        this.playlist.tracks = this.playlist.tracks.filter { $0 != track }
                        NSNotificationCenter.defaultCenter().postNotificationName(kTrackInfoDidUpdate, object: nil)
                    }
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
            SpotifyStreamingController.playSongWithURI(nowPlaying.spotifyURI)
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
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didChangePlaybackState playbackState: SPTPlaybackState!) {
        
        
        if audioStreaming.currentPlaybackPosition > (audioStreaming.currentTrackDuration + 2) {
            print("Track ended")            
            if !upNext.isEmpty {
                
                popQueue({ [weak self] (success) in
                    guard let nowPlaying = self?.nowPlaying else { return }
                    
                    SpotifyStreamingController.playSongWithURI(nowPlaying.spotifyURI)
                    
//                    guard let nextTrack = self?.upNext[0] else { return }
//                    SpotifyStreamingController.addNextSongToQueue(nextTrack)
//                    print("\(self?.upNext[0].name) queued")
                    
                    })
                
            } else {
                return
            }
        }
        
        
    }
    
    func popQueue(completion: (success: Bool) -> Void) {
        guard let nowPlaying = nowPlaying else { return }
        PlaylistController.sharedController.removeTrack(nowPlaying, fromPlaylist: playlist) { (error) in
            print("Removed song after it was played")
        }
    }
    
    @IBAction override func addSongButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("addTrackToPlaylistSegue", sender: self)
    }
    
    @IBAction func playButtonTapped(sender: AnyObject) {
        SpotifyStreamingController.toggleIsPlaying(isPlaying) { [weak self] (isPlaying) in
            if isPlaying {
                self?.playButton.setTitle("Play", forState: .Normal)
            } else {
                self?.playButton.setTitle("Pause", forState: .Normal)
            }
        }
    }
    
    @IBAction func nextButtonTapped(sender: AnyObject) {
        spotifyPlayer.skipNext { (error) in
            //
        }
    }
    
}
