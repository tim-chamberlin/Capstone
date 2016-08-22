//
//  HomeViewController.swift
//  Disco
//
//  Created by Tim on 8/21/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = UserController.sharedController.currentUser?.name
        print((UserController.sharedController.currentUser?.FBID)! as String)
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
    
    @IBAction func logoutButtonTapped(sender: AnyObject) {
        presentLogoutActionSheet()
    }
    
    @IBAction func friendsListButtonTapped(sender: AnyObject) {
        UserController.sharedController.getFriends { (success) in
            //
        }
    }
}
