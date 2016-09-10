//
//  ContributingViewController.swift
//  Disco
//
//  Created by Tim on 8/22/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class ContributingViewController: UIViewController, PlaylistTableViewDataSource, PlaylistTableViewDelegate {

    var contributingPlaylistsTableView: PlaylistListViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contributingPlaylistsTableView.delegate = self
        updatePlaylistTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    // MARK: - PlaylistTableViewDataSource
    
    func updatePlaylistTableView() {
        // Specify PlaylistTableView's user
        guard let currentUser = UserController.sharedController.currentUser else { return }
        contributingPlaylistsTableView.updatePlaylistViewWithUser(currentUser, withPlaylistType: .Contributing, withNoPlaylistsText: "You aren't currently contributing to any queues.")
    }
    
    // MARK: -  PlaylistTableViewDelegate Methods
    
    func didSelectRowAtIndexPathInPlaylistTableView(indexPath indexPath: NSIndexPath) {
        guard let cell = contributingPlaylistsTableView.tableView.cellForRowAtIndexPath(indexPath) else {
            return
        }
        self.parentViewController?.performSegueWithIdentifier("toTrackList", sender: cell)
    }
    
    func didDeselectRowAtIndexPathInPlaylistTableView(indexPath indexPath: NSIndexPath) {
        //
    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "playlistTVEmbedSegue" {
            contributingPlaylistsTableView = segue.destinationViewController as? PlaylistListViewController
        }
    }
    
    // MARK: - IBActions

    @IBAction func contributeToPlaylistButtonTapped(sender: AnyObject) {
        self.parentViewController?.parentViewController?.performSegueWithIdentifier("toFriendsListSegue", sender: self)
    }
}
