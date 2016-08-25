//
//  SpotifySearchTableViewController.swift
//  Disco
//
//  Created by Tim on 8/25/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class SpotifySearchTableViewController: UITableViewController, UISearchResultsUpdating {

    var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
    }
    
    // MARK: - SearchController Methods
    
    func setupSearchController() {
        let resultsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ResultsTVC")
        searchController = UISearchController(searchResultsController: resultsController)
        guard let searchController = searchController else { return }
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for a song on Spotify..."
        searchController.definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let text = searchController.searchBar.text, resultsController = searchController.searchResultsController as? SpotifySearchResultsTableViewController else { return }
        
        TrackController.searchSpotifyForTrackWithText(text, responseLimit: "20", filterByType: "track") { (tracks, success) in
            if let tracks = tracks {
//                print("Track: \(tracks[0].name), artist: \(tracks[0].artist)")
                resultsController.searchedTracks = tracks
            }
        }
        resultsController.tableView.reloadData()
    }
    

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }

}
