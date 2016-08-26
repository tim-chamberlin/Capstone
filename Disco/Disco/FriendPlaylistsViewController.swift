//
//  FriendPlaylistsViewController.swift
//  Disco
//
//  Created by Tim on 8/24/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class FriendPlaylistsViewController: UIViewController, PlaylistTableViewDataSource, PlaylistTableViewDelegate {

    
    var playlistView: PlaylistListViewController!
    
    var selectedUser: User?
    var selectedPlaylist: Playlist?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playlistView.delegate = self
        
        if selectedUser != nil {
            updatePlaylistTableView()
            self.title = "Contribute to playlist"
        }
    }

    // MARK: - PlaylistTableViewDataSource Methods
    
    func updatePlaylistTableView() {
        guard let selectedUser = selectedUser else { return }
        playlistView.updatePlaylistViewWithUser(selectedUser, withPlaylistType: .Hosting, withNoPlaylistsText: "\(selectedUser.name) isn't currently hosting any playlist.")   
    }
    
    // MARK: - PlaylistTableViewDelegate
    
    func didSelectRowAtIndexPathInPlaylistTableView(indexPath indexPath: NSIndexPath) {
        guard let selectedCell = playlistView.tableView.cellForRowAtIndexPath(indexPath) else { return }
        selectedPlaylist = playlistView.playlists[indexPath.row]
        selectedCell.accessoryType = .Checkmark
    }
    
    func didDeselectRowAtIndexPathInPlaylistTableView(indexPath indexPath: NSIndexPath) {
        guard let deSelectedCell = playlistView.tableView.cellForRowAtIndexPath(indexPath) else { return }
        deSelectedCell.accessoryType = .None
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedPlaylistTableViewSegue" {
            playlistView = segue.destinationViewController as? PlaylistListViewController
        }
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        guard let currentUser = UserController.sharedController.currentUser, playlist = selectedPlaylist else { return }
        PlaylistController.sharedController.addUserAsPlaylistContributor(playlist, user: currentUser) { (success) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
