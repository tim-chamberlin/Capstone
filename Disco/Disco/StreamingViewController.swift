//
//  StreamingViewController.swift
//  Disco
//
//  Created by Tim on 8/28/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class StreamingViewController: TrackListViewController, SPTAudioStreamingDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "TrackTableViewCell", bundle: nil), forCellReuseIdentifier: "trackCell")
        
        spotifyPlayer.delegate = self
        audioStreamingDidLogin(spotifyPlayer)
    }
    
    override func addTrackObservers() {
        PlaylistController.sharedController.addTrackObserverForPlaylist(playlist) { (track, success) in
            dispatch_async(dispatch_get_main_queue(), {
                if let track = track {
                    self.playlist.tracks.append(track)
                    self.playlist.tracks = PlaylistController.sharedController.sortPlaylistByVoteCount(self.playlist)
                    // Get current user's vote status for the track (always 0 for new tracks) and attach a listener for user votes
                    TrackController.sharedController.getVoteStatusForTrackWithID(track.firebaseUID, inPlaylistWithID: self.playlist.uid, ofType: .Hosting, user: self.currentUser, completion: { (voteStatus, success) in
                        track.currentUserVoteStatus = voteStatus
                        self.tableView.reloadData()
                    })
                    
                    TrackController.sharedController.attachVoteListener(forTrack: track, inPlaylist: self.playlist, completion: { (newVoteCount, success) in
                        track.voteCount = newVoteCount
                        self.playlist.tracks = PlaylistController.sharedController.sortPlaylistByVoteCount(self.playlist)
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
    
    
    // MARK: - Spotify Streaming
    
    func audioStreamingDidLogin(audioStreaming: SPTAudioStreamingController!) {
        let url = NSURL(string: "spotify:track:0j0DNujXWeupLpZobbABoo")
        if let player = spotifyPlayer {
            player.playURI(url, startingWithIndex: 0) { (error) in
                if error != nil {
                    print("Error playing track.")
                } else {
                    print("Success")
                }
            }
        }
    }
    
    @IBAction override func addSongButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("addTrackToPlaylistSegue", sender: self)
    }
}
