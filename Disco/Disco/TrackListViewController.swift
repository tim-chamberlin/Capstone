//
//  TrackListViewController.swift
//  Disco
//
//  Created by Tim on 8/25/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit


let kTrackListDidLoad = "TrackListDidLoad"
let kUpNextListDidUpdate = "UpNextListDidUpdate"
let kTrackListDidRemoveSong = "TrackListDidUpdate"

class TrackListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddTrackToPlaylistDelegate, TrackTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var playlist: Playlist?
    var currentUser: User = UserController.sharedController.currentUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "TrackTableViewCell", bundle: nil), forCellReuseIdentifier: "trackCell")
        
    }
    
    deinit {
//        PlaylistController.sharedController.removeTrackObserverForPlaylist(playlist) { (success) in
//            
//        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let playlist = playlist else { return 0 }
        if section == 0 {
            return playlist.nowPlaying != nil ? 1 : 0
        } else if section == 1 {
            return playlist.upNext.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("trackCell", forIndexPath: indexPath) as? TrackTableViewCell, playlist = playlist else { return UITableViewCell() }
        
        if indexPath.section == 0 {
            if let nowPlaying = playlist.nowPlaying {
                let track = nowPlaying
                cell.track = track
                cell.voteStatus = track.currentUserVoteStatus
                cell.updateCellWithTrack(track)
                cell.votingStackView.hidden = true
                cell.delegate = self
            }
        } else if indexPath.section == 1 {
            if !playlist.upNext.isEmpty {
                let track = playlist.upNext[indexPath.row]
                cell.track = track
                cell.voteStatus = track.currentUserVoteStatus
                cell.updateCellWithTrack(track)
                cell.delegate = self
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Now Playing"
        } else if section == 1 {
            return "Up Next"
        } else {
            return ""
        }
    }
    
    // MARK: - Delegate Methods
    
    func didPressVoteButton(sender: TrackTableViewCell, voteType: VoteType) {
        guard let currentUser = UserController.sharedController.currentUser, playlist = playlist, track = sender.track else { return }
        
        TrackController.sharedController.user(currentUser, didVoteWithType: voteType, withVoteStatus: (sender.track?.currentUserVoteStatus)!, onTrack: track, inPlaylist: playlist, ofPlaylistType: .Contributing) { (success) in
            //
        }
    }
    
    func willAddTrackToPlaylist(track: Track) {
        
        track.playlistID = self.playlist!.uid
        PlaylistController.sharedController.addTrack(track, toQueue: self.playlist!) { (success) in
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