//
//  ContributingViewController.swift
//  Disco
//
//  Created by Tim on 8/22/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class ContributingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Navigation

    @IBAction func contributeToPlaylistButtonTapped(sender: AnyObject) {
        
        UserController.sharedController.getFriends { (friends, success) in
            if let friends = friends {
                UserController.sharedController.currentUser?.friends = friends
                self.parentViewController?.performSegueWithIdentifier("toFriendsListSegue", sender: self)
            }
        }
        
        
    }
}
