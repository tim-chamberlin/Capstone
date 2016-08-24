//
//  FriendsListTableViewController.swift
//  Disco
//
//  Created by Tim on 8/21/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class FriendsListTableViewController: UITableViewController {

    var friends = UserController.sharedController.currentUser?.friends
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    
        
    }
    
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friends?.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath)

        guard let friend = friends?[indexPath.row] else { return UITableViewCell() }
        cell.textLabel?.text = friend.name
        // TODO: Custom friend cell with number of hosted playlists
        
        return cell
    }

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "playlistTVEmbedSegue" {
            guard let destinationVC = segue.destinationViewController as? PlaylistListViewController else { return }
            if let indexPath = tableView.indexPathForSelectedRow, selectedUser = self.friends?[indexPath.row] {
                destinationVC.updateTableViewWithUser(selectedUser, withPlaylistType: .Hosting)
            }
        }
    }

    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
