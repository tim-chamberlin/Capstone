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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = playlist.name
        playlist.tracks = []
        // Add observer for new tracks
        PlaylistController.sharedController.addTrackObserverForPlaylist(playlist) { (track, success) in
            dispatch_async(dispatch_get_main_queue(), {
                if let track = track {
                    self.playlist.tracks.append(track)
                    self.playlist.tracks = PlaylistController.sharedController.sortPlaylistByVoteCount(self.playlist)   
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist.tracks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("trackCell", forIndexPath: indexPath) as? TrackTableViewCell else { return UITableViewCell() }
        
        let track = playlist.tracks[indexPath.row]
        cell.updateCellWithTrack(track)
        cell.delegate = self
        
        return cell
    }
    
    
    // MARK: - Delegate Methods
    
    func didPressVoteButton(voteType: VoteType) {
        print(voteType)
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
