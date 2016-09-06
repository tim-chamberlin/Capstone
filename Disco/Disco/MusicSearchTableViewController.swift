//
//  MusicSearchTableViewController.swift
//  Disco
//
//  Created by Tim on 8/25/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class MusicSearchTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    var searchedTracks: [Track] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var musicSearchController: UISearchController?
    
    var selectedTrack: Track?
    var selectedTrackIndexPath: NSIndexPath?
    
    weak var delegate: AddTrackToPlaylistDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        selectedTrack = nil
        selectedTrackIndexPath = nil
    }
    
    
    func setupSearchController() {
        musicSearchController = UISearchController(searchResultsController: nil)
        guard let searchController = musicSearchController else { return }
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for a track on Spotify..."
        searchController.definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.barTintColor = UIColor.lightCharcoalColor()
        tableView.tableHeaderView = searchController.searchBar
    }
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        if let text = searchController.searchBar.text {
            if !text.isEmpty {
                TrackController.searchSpotifyForTrackWithText(text, responseLimit: "20", filterByType: "track") { (tracks, success) in
                    if !tracks.isEmpty {
                        self.searchedTracks = tracks
                    }
                }
            } else {
                self.searchedTracks = []
            }
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // Clear check mark when search text changes
        if let selectedCellIndexPath = tableView.indexPathForSelectedRow, cell = tableView.cellForRowAtIndexPath(selectedCellIndexPath) {
            cell.accessoryType = .None
            self.selectedTrackIndexPath = nil
            self.selectedTrack = nil
        }
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedTracks.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchedTrackCell", forIndexPath: indexPath)
        cell.selectionStyle = .None
        cell.textLabel?.textColor = UIColor.offWhiteColor()
        cell.detailTextLabel?.textColor = UIColor.offWhiteColor()
        if searchedTracks.count == 0 {
            cell.textLabel?.text = ""
            cell.detailTextLabel?.text = ""
        } else {
            let track = searchedTracks[indexPath.row]
            cell.textLabel?.text = track.name
            cell.detailTextLabel?.text = track.artist
        }
        
        if indexPath == selectedTrackIndexPath {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return }
        selectedTrack = searchedTracks[indexPath.row]
        selectedTrackIndexPath = indexPath
        cell.accessoryType = .Checkmark
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return }
        cell.accessoryType = .None
    }
    
    
    
    // MARK: - IBActions
    
    @IBAction func addTrackButtonTapped(sender: AnyObject) {
        musicSearchController?.active = false
        if let selectedTrack = selectedTrack {
            delegate?.willAddTrackToPlaylist(selectedTrack)
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            return
        }
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        musicSearchController?.active = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

protocol AddTrackToPlaylistDelegate: class {
    func willAddTrackToPlaylist(track: Track)
}
