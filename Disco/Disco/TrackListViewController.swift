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
    var nowPlaying: Track?
    var currentUser: User = UserController.sharedController.currentUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "TrackTableViewCell", bundle: nil), forCellReuseIdentifier: "trackCell")
        title = playlist?.name
        self.playlist?.tracks = []
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.loadTrackList), name: kTrackListDidLoad, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.updateNextUpList), name: kUpNextListDidUpdate, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.updateTrackList), name: kTrackListDidRemoveSong, object: nil)
        
        // Add observer for new tracks
        addTrackObservers(forPlaylistType: .Hosting)
    }
    
    deinit {
//        PlaylistController.sharedController.removeTrackObserverForPlaylist(playlist) { (success) in
//            
//        }
    }
    
    // Adds Firebase and NSNotificationCenter observers to TrackList VC
    func addTrackObservers(forPlaylistType playlistType: PlaylistType) {
        // Initial load
        guard let playlist = playlist else { return }
        PlaylistController.sharedController.fetchTracksForPlaylist(playlist) { (tracks, success) in
                self.playlist?.tracks = tracks ?? []
                NSNotificationCenter.defaultCenter().postNotificationName(kTrackListDidLoad, object: nil)
            
            // Clear trackList before adding observers
            self.playlist?.tracks = []
            
            // Execute when initial load is finished
            PlaylistController.sharedController.addTrackObserverForPlaylist(playlist, completion: { [weak self] (track, didAdd) in
                if let track = track, this = self {
                    if didAdd {
                        
                        playlist.tracks.append(track)
                        NSNotificationCenter.defaultCenter().postNotificationName(kUpNextListDidUpdate, object: nil)
                        
                        // Get current user's vote status for the track (always 0 for new tracks) and set the cell accordingly
                        TrackController.sharedController.getVoteStatusForTrackWithID(track.firebaseUID, inPlaylistWithID: playlist.uid, ofType: playlistType, user: this.currentUser, completion: { (voteStatus, success) in
                            track.currentUserVoteStatus = voteStatus
                        })
                        
                        // Listen for votes
                        TrackController.sharedController.attachVoteListener(forTrack: track, inPlaylist: playlist, completion: { (newVoteCount, success) in
                            track.voteCount = newVoteCount
                            // upNext did update
                            NSNotificationCenter.defaultCenter().postNotificationName(kUpNextListDidUpdate, object: nil)
                        })
                        
                    } else { // Track removed
                        NSNotificationCenter.defaultCenter().postNotificationName(kTrackListDidRemoveSong, object: nil)
                        playlist.tracks = playlist.tracks.filter { $0 != track }
                    }
                }
            })
        }
    }
    
    // Called when songs in upNext are voted on/added, make sure nowPlaying isn't included twice
    func updateNextUpList() {
        guard let playlist = playlist else { return }
        if !playlist.tracks.isEmpty {
//            self.playlist.tracks = playlist.tracks.filter { $0.firebaseUID != self.nowPlaying?.firebaseUID }
            playlist.tracks = TrackController.sortTracklistByVoteCount(playlist.tracks)
            tableView.reloadData()
        } else if nowPlaying == nil {
            nowPlaying = playlist.tracks[0]
        }
    }
    
    // Called whenever the streamer goes to the next song (when the top track is deleted)
    func updateTrackList() {
        guard let playlist = playlist else { return }
        if !playlist.tracks.isEmpty {
            nowPlaying = playlist.tracks[0]
            playlist.tracks = playlist.tracks.filter({ (track) -> Bool in
                return track != nowPlaying
            })
            tableView.reloadData()
        } else {
            // TODO: Show no tracks label, hide tableView
        }
    }
    
    // Should only be called on initial load to get first nowPlaying track
    func loadTrackList() {
        nowPlaying = playlist?.tracks[0]
//        playlist.tracks = playlist.tracks.filter({ (track) -> Bool in
//            return track != playlist?.tracks[0]
//        })
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let _ = nowPlaying {
            return 2
        } else { // No tracks
            return 0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = nowPlaying {
            if section == 0 {
                return 1
            } else if section == 1 {
                 return playlist != nil ? playlist!.tracks.count : 0
            }
        }
        // No tracks
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("trackCell", forIndexPath: indexPath) as? TrackTableViewCell else { return UITableViewCell() }
        
        if let nowPlaying = nowPlaying {
            if indexPath.section == 0 {
                let track = nowPlaying
                cell.track = track
                cell.voteStatus = track.currentUserVoteStatus
                cell.updateCellWithTrack(track)
                cell.votingStackView.hidden = true
                cell.delegate = self
            } else {
                let track = playlist?.tracks[indexPath.row]
                cell.track = track
//                cell.voteStatus = track?.currentUserVoteStatus
//                cell.updateCellWithTrack(track)
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
        PlaylistController.sharedController.addTrack(track, toPlaylist: self.playlist!) { (success) in
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