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
    private var streamingVC: StreamingViewController!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var contributingContainerView: UIView!
    @IBOutlet weak var streamingContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = UserController.sharedController.currentUser?.name
        
        setupSegmentedCcontroller()
        segmentedControl.addTarget(self, action: #selector(HomeViewController.segmentedControlChanged(_:)), forControlEvents: .ValueChanged)
        
        contributingVC.updatePlaylistTableView()
        

    }
    
//    func setupNavigationBar() {
//        
//        // Get facebook prof pic
//        if let currentUser = UserController.sharedController.currentUser {
//            UserController.sharedController.getCurrentUserProfilePicture(forUser: currentUser, completion: { (profilePicture) in
//                guard let image = profilePicture else { return }
//                self.navigationItem.titleView = UIImageView(image: image)
//                
//                let titleView = UIView(frame: CGRectMake(0,0, UIScreen.mainScreen().bounds.width/2, 30))
////                titleView.backgroundColor = .blueColor()
//                let imageView = UIImageView(frame: CGRectMake(0, 0, 30, 30))
//                imageView.image = image
//                imageView.center = titleView.center
//                imageView.contentMode = .ScaleAspectFit
//                imageView.layer.cornerRadius = 20
//                titleView.addSubview(imageView)
//                
//                let titleLabel = UILabel(frame: CGRectMake(40, 0, 1000, 30))
//                titleLabel.text = "Tim Chamberlin"
//                titleLabel.font = UIFont.navigationBarFont()
//                titleLabel.textColor = UIColor.offWhiteColor()
//                titleView.addSubview(titleLabel)
//                
//                
//                self.navigationItem.titleView = titleView
//            })
//        }
//    }

    func setupSegmentedCcontroller() {
        segmentedControl.selectedSegmentIndex == 0
        contributingContainerView.hidden = false
        streamingContainerView.hidden = true
    }
    
    func segmentedControlChanged(segmentedControl: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            contributingContainerView.hidden = false
            streamingContainerView.hidden = true
        } else if segmentedControl.selectedSegmentIndex == 1 {
            contributingContainerView.hidden = true
            streamingContainerView.hidden = false
        }
    }
    
    func presentLogoutActionSheet() {
        guard let currentUserName = UserController.sharedController.currentUser?.name else { return }
        let actionSheet = UIAlertController(title: "Logout \(currentUserName)?", message: "", preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in
            return
        }
        
        // Logout Current User
        let logoutAction = UIAlertAction(title: "Logout", style: .Destructive) { (_) in
            UserController.sharedController.logoutCurrentUser()
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let authVC = mainStoryboard.instantiateViewControllerWithIdentifier("AuthView")
            self.presentViewController(authVC, animated: true, completion: nil)
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
        } else if segue.identifier == "embedStreamingVC" {
            streamingVC = segue.destinationViewController as? StreamingViewController
        }
        
        // To playlist detail
        if segue.identifier == "toTrackList" {
            guard let destinationVC = segue.destinationViewController as? TrackListViewController else { return }
            if let indexPath = contributingVC.contributingPlaylistsTableView.tableView.indexPathForSelectedRow {
                destinationVC.playlist = contributingVC.contributingPlaylistsTableView.playlists[indexPath.row]
            }
        }
    }
    
    @IBAction func unwindToHomeViewController(segue: UIStoryboardSegue) {
        if let _ = segue.sourceViewController as? FriendPlaylistsViewController {
            contributingVC.updatePlaylistTableView()
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func logoutButtonTapped(sender: AnyObject) {
        presentLogoutActionSheet()
    }
    
    @IBAction func addTrackAction(sender: AnyObject) {
        self.performSegueWithIdentifier("addTrackSegue", sender: self)
    }
}
