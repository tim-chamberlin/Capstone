//
//  PlaylistSearchTableViewController.swift
//  A-Side
//
//  Created by Tim on 9/24/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class PlaylistSearchTableViewController: UITableViewController {
    
    var playlistNames: [String] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var playlistTrackCounts: [UInt] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var playlistURIs: [NSURL] = []
    
    var selectedPlaylistIndexPath: NSIndexPath?
    var selectedPlaylistURI: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PlaylistController.sharedController.getSpotifyPlaylistList { (partialPlaylists) in
            dispatch_async(dispatch_get_main_queue(), {
                guard let partialPlaylists = partialPlaylists else { return }
                self.playlistNames = partialPlaylists.flatMap { $0.name }
                self.playlistTrackCounts = partialPlaylists.flatMap { $0.trackCount }
                self.playlistURIs = partialPlaylists.flatMap { $0.uri }
            })
        }
    }
    
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistNames.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("playlistCell", forIndexPath: indexPath)
        cell.selectionStyle = .None
        if indexPath == selectedPlaylistIndexPath {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        let playlistName = playlistNames[indexPath.row]
        let trackCount = playlistTrackCounts[indexPath.row]
        cell.textLabel?.text = "\(playlistName) - \(String(trackCount)) tracks"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return }
        selectedPlaylistIndexPath = indexPath
        selectedPlaylistURI = playlistURIs[indexPath.row]
        cell.accessoryType = .Checkmark
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return }
        cell.accessoryType = .None
    }
    
    // MARK: - IBActions
    
    @IBAction func cancelAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        if let selectedPlaylistURI = selectedPlaylistURI {
            PlaylistController.sharedController.getSpotifyPlaylistTracks(selectedPlaylistURI, completion: { (tracks) in
                var trackIDs = [String]()
                for track in tracks {
                    trackIDs.append(track.identifier)
                }
                TrackController.fetchInfo(forTracksWithIDs: trackIDs, completion: { (tracks) in
                    guard let tracks = tracks, currentUserQueue = PlaylistController.sharedController.hostedPlaylist else { return }
                    var counter = 0
                    for track in tracks {
                        counter += 1
                        PlaylistController.sharedController.addTrack(track, toQueue: currentUserQueue, completion: { (success) in
                            if counter == tracks.count {
                                self.dismissViewControllerAnimated(true, completion: {
                                    ProgressHUD.showSuccess("Added tracks to queue")
                                })
                            }
                        })
                    }
                })
            })
        }
    }
}

