//
//  PlaylistListViewController.swift
//  Disco
//
//  Created by Tim on 8/24/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class PlaylistListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            self.updateTableViewWithUser(user, withPlaylistType: .Hosting)
        }
    }
    
    var playlists: [Playlist] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func updateTableViewWithUser(user: User, withPlaylistType: PlaylistType) {
        PlaylistController.sharedController.fetchPlaylistsForUser(user.FBID, ofType: withPlaylistType) { (playlists, success) in
            if success {
                guard let playlists = playlists else {
                    print("No playlists found for current user")
                    return
                }
                self.playlists = playlists
                self.tableView.reloadData()
            } else {
                print("Error fetching playlists")
            }
        }
    }
    
    // MARK: - UITableViewDataSource Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlists.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("hostingPlaylistCell", forIndexPath: indexPath)
        
        let playlist = self.playlists[indexPath.row]
        
        cell.textLabel?.text = playlist.name
        
        return cell
    }
    
    
    
    
}
