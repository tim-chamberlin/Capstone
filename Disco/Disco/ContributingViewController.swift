//
//  ContributingViewController.swift
//  Disco
//
//  Created by Tim on 8/22/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class ContributingViewController: UIViewController, PlaylistTableViewDataSource {

    
    var contributingPlaylistsTableView: PlaylistListViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        updatePlaylistTableView()
    }
    
    
    
    func updatePlaylistTableView() {
        // Specify PlaylistTableView's user
        guard let currentUser = UserController.sharedController.currentUser else { return }
        contributingPlaylistsTableView.updatePlaylistViewWithUser(currentUser, withPlaylistType: .Contributing, withNoPlaylistsText: "You aren't currently contributing to any playlists.")
        
    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "playlistTVEmbedSegue" {
            contributingPlaylistsTableView = segue.destinationViewController as? PlaylistListViewController
        }
    }
    
    
    // MARK: - IBActions

    @IBAction func contributeToPlaylistButtonTapped(sender: AnyObject) {
        // TODO: Setup delegate to pass info?
        UserController.sharedController.getFriends { (friends, success) in
            if let friends = friends {
                UserController.sharedController.currentUser?.friends = friends
                self.parentViewController?.performSegueWithIdentifier("toFriendsListSegue", sender: self)
            }
        }
    }
}
