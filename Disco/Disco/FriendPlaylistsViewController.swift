//
//  FriendPlaylistsViewController.swift
//  Disco
//
//  Created by Tim on 8/24/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class FriendPlaylistsViewController: UIViewController, PlaylistTableViewDataSource {

    
    var playlistView: PlaylistListViewController!
    
    var selectedUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let selectedUser = selectedUser {
            updatePlaylistTableView()
            self.title = selectedUser.name
        }
    }

    
    func updatePlaylistTableView() {
        guard let selectedUser = selectedUser else { return }
        playlistView.updatePlaylistViewWithUser(selectedUser, withPlaylistType: .Hosting, withNoPlaylistsText: "\(selectedUser.name) isn't currently hosting any playlist.")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedPlaylistTableViewSegue" {
            playlistView = segue.destinationViewController as? PlaylistListViewController
        }
    }
}
