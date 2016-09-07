//
//  HomeViewController.swift
//  Disco
//
//  Created by Tim on 8/21/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UIPageViewControllerDelegate {

    var pageViewController: MainPageViewController!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = UserController.sharedController.currentUser?.name
        setupSegmentedController()
        setupPageViewController()
    }

    func setupPageViewController() {
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! MainPageViewController
        self.pageViewController.view.frame = CGRectMake(0, 60, self.view.frame.width, self.view.frame.height - 60)
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        pageViewController.delegate = self
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            return
        }
        if let _ = previousViewControllers.first as? StreamingViewController {
            segmentedControl.selectedSegmentIndex = 0
        } else if let _ = previousViewControllers.first as? ContributingViewController {
            segmentedControl.selectedSegmentIndex = 1
        }
    }

    func setupSegmentedController() {
        segmentedControl.addTarget(self, action: #selector(HomeViewController.segmentedControlChanged(_:)), forControlEvents: .ValueChanged)
        segmentedControl.selectedSegmentIndex == 0
    }
    
    func segmentedControlChanged(segmentedControl: UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            pageViewController.setViewControllers([pageViewController.firstVC], direction: .Reverse, animated: true, completion: nil)
        } else if segmentedControl.selectedSegmentIndex == 1 {
            pageViewController.setViewControllers([pageViewController.secondVC], direction: .Forward, animated: true, completion: nil)
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
    
    // MARK: - IBActions

    @IBAction func unwindToHomeViewController(segue: UIStoryboardSegue) {
        if let _ = segue.sourceViewController as? FriendPlaylistsViewController {
            if let contributingVC = pageViewController.firstVC as? ContributingViewController {
                contributingVC.updatePlaylistTableView()
            }
            
        }
    }
    
    @IBAction func logoutButtonTapped(sender: AnyObject) {
        presentLogoutActionSheet()
    }
}
