//
//  SpotifySearchResultsTableViewController.swift
//  Disco
//
//  Created by Tim on 8/25/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class SpotifySearchResultsTableViewController: UITableViewController {

    var searchedTracks: [Track] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedTracks.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchedTrackCell", forIndexPath: indexPath)

        let track = searchedTracks[indexPath.row]
        cell.textLabel?.text = track.name
        cell.detailTextLabel?.text = track.artist

        return cell
    }

}
