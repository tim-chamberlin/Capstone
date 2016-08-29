//
//  HomeViewController.swift
//  Disco
//
//  Created by Tim on 8/21/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    private var contributingVC: ContributingViewController!
    private var hostingVC: HostingViewController!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var contributingContainerView: UIView!
    @IBOutlet weak var hostingContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = UserController.sharedController.currentUser?.name
        
        setupSegmentedCcontroller()
        segmentedControl.addTarget(self, action: #selector(HomeViewController.segmentedControlChanged(_:)), forControlEvents: .ValueChanged)
        
        contributingVC.updatePlaylistTableView()
        hostingVC.updatePlaylistTableView()
    }

    func setupSegmentedCcontroller() {
        segmentedControl.selectedSegmentIndex == 0
        contributingContainerView.hidden = false
        hostingContainerView.hidden = true
    }
    
    func segmentedControlChanged(segmentedControl: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            contributingContainerView.hidden = false
            hostingContainerView.hidden = true
        } else if segmentedControl.selectedSegmentIndex == 1 {
            contributingContainerView.hidden = true
            hostingContainerView.hidden = false
        }
    }
    
    func presentLogoutActionSheet() {
        guard let currentUserName = UserController.sharedController.currentUser?.name else { return }
        let actionSheet = UIAlertController(title: "Logout \(currentUserName)?", message: "", preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in
            return
        }
        let logoutAction = UIAlertAction(title: "Logout", style: .Destructive) { (_) in
            UserController.sharedController.logoutCurrentUser { (success) in
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
        actionSheet.addAction(cancelAction)
        actionSheet.addAction(logoutAction)
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Embedded Views
        if segue.identifier == "contributingEmbedSegue" {
            contributingVC = segue.destinationViewController as? ContributingViewController
        } else if segue.identifier == "hostingEmbedSegue" {
            hostingVC = segue.destinationViewController as? HostingViewController
        }
        
        // To playlist detail
        if segue.identifier == "toTrackList" {
            guard let destinationVC = segue.destinationViewController as? TrackListViewController else { return }
            if let indexPath = contributingVC.contributingPlaylistsTableView.tableView.indexPathForSelectedRow {
                destinationVC.playlist = contributingVC.contributingPlaylistsTableView.playlists[indexPath.row]
            }
        } else if segue.identifier == "toStreamingController" {
            guard let destinationVC = segue.destinationViewController as? StreamingViewController else { return }
            if let indexPath = hostingVC.playlistsTableView.tableView.indexPathForSelectedRow {
                destinationVC.playlist = hostingVC.playlistsTableView.playlists[indexPath.row]
            }
        }
    }
    
    @IBAction func unwindToHomeViewController(segue: UIStoryboardSegue) {
        if let _ = segue.sourceViewController as? FriendPlaylistsViewController {
            contributingVC.updatePlaylistTableView()
        } else if let _ = segue.sourceViewController as? NewPlaylistViewController {
            hostingVC.updatePlaylistTableView()
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func logoutButtonTapped(sender: AnyObject) {
        presentLogoutActionSheet()
    }
    
    @IBAction func friendsListButtonTapped(sender: AnyObject) {
        UserController.sharedController.getFriends { (friends, success) in
            guard let friends = friends else { return }
            UserController.sharedController.currentUser?.friends = friends
            self.performSegueWithIdentifier("toFriendsListSegue", sender: self)
        }
    }
}
