//
//  PlaylistListViewController.swift
//  Disco
//
//  Created by Tim on 8/24/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class PlaylistListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var user: User?
    var playlists: [Playlist] = []
    
    weak var delegate: PlaylistTableViewDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyPlaylistsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updatePlaylistViewWithUser(user: User, withPlaylistType: PlaylistType, withNoPlaylistsText: String) {
        
        PlaylistController.sharedController.fetchPlaylistsForUser(user.FBID, ofType: withPlaylistType) { (playlists, success) in
            if success {
                guard let playlists = playlists else {
                    self.updateInfoLabelWith(withNoPlaylistsText, playlists: self.playlists)
                    return
                }
                self.user = user
                self.playlists = playlists
                self.updateInfoLabelWith(withNoPlaylistsText, playlists: self.playlists)
                self.tableView.reloadData()
            } else {
                print("Error fetching playlists")
            }
        }
    }
    
    func updateInfoLabelWith(text: String, playlists: [Playlist]) {
        emptyPlaylistsLabel.text = text
        if playlists.isEmpty {
            tableView.hidden = true
            emptyPlaylistsLabel.hidden = false
        } else {
            tableView.hidden = false
            emptyPlaylistsLabel.hidden = true
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
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.didSelectRowAtIndexPathInPlaylistTableView(indexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.didDeselectRowAtIndexPathInPlaylistTableView(indexPath: indexPath)
    }
}

protocol PlaylistTableViewDataSource: class {
    func updatePlaylistTableView()
    
}

@objc protocol PlaylistTableViewDelegate: class {
    func didSelectRowAtIndexPathInPlaylistTableView(indexPath indexPath: NSIndexPath)
    func didDeselectRowAtIndexPathInPlaylistTableView(indexPath indexPath: NSIndexPath)
}
