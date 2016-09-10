//
//  FriendsListTableViewController.swift
//  Disco
//
//  Created by Tim on 8/21/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class FriendsListTableViewController: UITableViewController {
    
    var playlistView: PlaylistListViewController!
    
    var selectedFriendIndexPath: NSIndexPath?
    
    var friends = [FacebookUser]() {
        didSet {
            //            orderTableViewByFirstName(friends)
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "FriendTableViewCell", bundle: nil), forCellReuseIdentifier: "friendCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as? FriendTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .None
        let friend = friends[indexPath.row]
        cell.updateCellWithFriend(friend)
        if indexPath == selectedFriendIndexPath {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return friendTableViewCellHeight
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return }
        selectedFriendIndexPath = indexPath
        cell.accessoryType = .Checkmark
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return }
        cell.accessoryType = .None
    }
    
    
    // MARK: - IBActions
    
    @IBAction func doneAction(sender: AnyObject) {
        if let selectedFriendIndexPath = selectedFriendIndexPath {
            let selectedFriend = friends[selectedFriendIndexPath.row]
            guard let currentUser = UserController.sharedController.currentUser else { return }
            PlaylistController.sharedController.addContributor(currentUser, toPlaylistWithID: selectedFriend.fbid, completion: { (success) in
                self.performSegueWithIdentifier("unwindToHomeVC", sender: self)
            })
        }
    }
    
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
