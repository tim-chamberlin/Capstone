//
//  TrackListViewController.swift
//  Disco
//
//  Created by Tim on 8/25/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class TrackListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddTrackToPlaylistDelegate, TrackTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var playlist: Playlist!
    var currentUser: User = UserController.sharedController.currentUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = playlist.name
        self.playlist.tracks = []
        // Add observer for new tracks
        PlaylistController.sharedController.addTrackObserverForPlaylist(playlist) { (track, success) in
            dispatch_async(dispatch_get_main_queue(), {
                if let track = track {
                    
                    self.playlist.tracks.append(track)
                    self.playlist.tracks = PlaylistController.sharedController.sortPlaylistByVoteCount(self.playlist)
                    
                    // Get current user's vote status for the track (always 0 for new tracks) and attach a listener for user votes
                    TrackController.sharedController.getVoteStatusForTrackWithID(track.firebaseUID, inPlaylistWithID: self.playlist.uid, user: self.currentUser, completion: { (voteStatus, success) in
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return 1
//        } else if section == 1 {
//            return playlist.tracks.count - 1
//        }
        return playlist.tracks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("trackCell", forIndexPath: indexPath) as? TrackTableViewCell else { return UITableViewCell() }
        
        
        let track = playlist.tracks[indexPath.row]
        cell.track = track
        cell.voteStatus = track.currentUserVoteStatus
        cell.updateCellWithTrack(track)
        cell.delegate = self
        
        return cell
    }
    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 0 {
//            return "Now Playing"
//        } else if section == 1 {
//            return "Up Next"
//        }
//        return ""
//    }
    
    // MARK: - Delegate Methods
    
    func didPressVoteButton(sender: TrackTableViewCell, voteType: VoteType) {
        guard let currentUser = UserController.sharedController.currentUser, track = sender.track else { return }
        
        TrackController.sharedController.user(currentUser, didVoteWithType: voteType, withVoteStatus: (sender.track?.currentUserVoteStatus)!, onTrack: track, inPlaylist: playlist, ofPlaylistType: .Contributing) { (success) in
            //
        }
    }
    
    func willAddTrackToPlaylist(track: Track) {
        track.playlistID = self.playlist.uid
        PlaylistController.sharedController.addTrack(track, toPlaylist: self.playlist) { (success) in
            // Fetch playlist tracks and reload tableView
            print("Update playlist with track: \(track.name)")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addTrackToPlaylistSegue" {
            let navVC = segue.destinationViewController as? UINavigationController
            guard let searchVC = navVC?.viewControllers.first as? SpotifySearchTableViewController else { return }
            searchVC.delegate = self
        }
    }
    
    @IBAction func addSongButtonTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("addTrackToPlaylistSegue", sender: self)
    }
}
