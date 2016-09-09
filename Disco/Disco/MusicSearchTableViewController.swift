//
//  MusicSearchTableViewController.swift
//  Disco
//
//  Created by Tim on 8/25/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class MusicSearchTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    var searchedTracks: (trackNames: [String], artists: [String], ids: [String]) = ([], [], []) {
        didSet {
            tableView.reloadData()
        }
    }
    
    var musicSearchController: UISearchController?
    var selectedTrackIndexPath: NSIndexPath?
    
    weak var delegate: AddTrackToPlaylistDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
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
        searchController.searchBar.delegate = self
        tableView.tableHeaderView = searchController.searchBar
    }
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        // Initial search
        if let text = searchController.searchBar.text {
            if !text.isEmpty {
                TrackController.searchSpotifyForItemWithText(text, responseLimit: 40, filterByType: "track", completion: { (items, success) in
                    if success {
                        guard let items = items else { return }
                        self.searchedTracks = items
                    }
                })
            } else {
                self.searchedTracks = ([], [], [])
            }
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // Clear check mark when search text changes
        if let selectedCellIndexPath = tableView.indexPathForSelectedRow, cell = tableView.cellForRowAtIndexPath(selectedCellIndexPath) {
            cell.accessoryType = .None
            self.selectedTrackIndexPath = nil
        }
    }
    
    // MARK: - Table view DataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedTracks.trackNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchedTrackCell", forIndexPath: indexPath)
        cell.selectionStyle = .None
        cell.textLabel?.textColor = UIColor.offWhiteColor()
        cell.detailTextLabel?.textColor = UIColor.offWhiteColor()
        if searchedTracks.trackNames.count == 0 {
            cell.textLabel?.text = ""
            cell.detailTextLabel?.text = ""
        } else {
            cell.textLabel?.text = searchedTracks.trackNames[indexPath.row]
            cell.detailTextLabel?.text = searchedTracks.artists[indexPath.row]
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
        selectedTrackIndexPath = indexPath
        cell.accessoryType = .Checkmark
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return }
        cell.accessoryType = .None
    }
    
    
    
    // MARK: - IBActions
    
    @IBAction func addTrackButtonTapped(sender: AnyObject) {
        if let selectedTrackIndexPath = selectedTrackIndexPath {
            TrackController.fetchTrackInfo(forTrackWithID: searchedTracks.ids[selectedTrackIndexPath.row]) { (track) in
                if let track = track {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.musicSearchController?.active = false
                        self.delegate?.willAddTrackToPlaylist(track)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
            }
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
