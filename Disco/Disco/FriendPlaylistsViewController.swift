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
        fetchAllPlaylists()
    }
    
    func fetchAllPlaylists() {
        PlaylistController.sharedController.fetchAllPlaylists { (playlists, success) in
            guard let playlists = playlists else { return }
            if let currentUserHostedPlaylist = PlaylistController.sharedController.hostedPlaylist {
                self.playlistView.playlists = playlists.filter { $0.uid != currentUserHostedPlaylist.uid }
            } else {
                self.playlistView.playlists = playlists
            }
            self.playlistView.tableView.reloadData()
        }
    }

    // MARK: - PlaylistTableViewDataSource Methods
    
    func updatePlaylistTableView() {
        guard let selectedUser = selectedUser else { return }
        playlistView.updatePlaylistViewWithUser(selectedUser, withPlaylistType: .Hosting, withNoPlaylistsText: "\(selectedUser.name) isn't currently hosting a queue.")
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
    
    @IBAction func doneAction(sender: AnyObject) {
        guard let currentUser = UserController.sharedController.currentUser, playlist = selectedPlaylist else { return }
        PlaylistController.sharedController.addContributor(currentUser, toPlaylist: playlist, completion: { (success) in
            self.performSegueWithIdentifier("unwindToHomeVC", sender: self)
        })
    }
    @IBAction func cancelTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
