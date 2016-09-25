//
//  PlaylistSearchTableViewController.swift
//  A-Side
//
//  Created by Tim on 9/24/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class PlaylistSearchTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {

    var playlists: [String] = []
    
    var musicSearchController: UISearchController?
    var selectedTrackIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        
        PlaylistController.sharedController.getSpotifyPlaylistList { (playlists) in
            //
        }
    }

    func setupSearchController() {
        musicSearchController = UISearchController(searchResultsController: nil)
        guard let searchController = musicSearchController else { return }
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for a playlist on Spotify..."
        searchController.definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.barTintColor = UIColor.lightCharcoalColor()
        searchController.searchBar.delegate = self
        tableView.tableHeaderView = searchController.searchBar
    }

    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            
        }
    }
    
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("playlistCell", forIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: - IBActions
    
    @IBAction func cancelAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        
    }
    
    

}
