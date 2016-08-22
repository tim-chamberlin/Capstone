//
//  AuthenticationViewController.swift
//  Disco
//
//  Created by Tim on 8/21/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class AuthenticationViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var loginWithFacebookButton: FBSDKLoginButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var testLoginWithFbButton: UIButton!
    private let loginSegueString = "loginSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginWithFacebookButton.delegate = self
        
        loadingIndicator.hidden = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        UserController.sharedController.checkUserAuth { (success) in
            dispatch_async(dispatch_get_main_queue(), {
                if success {
                    self.performSegueWithIdentifier(self.loginSegueString, sender: self)
                } else {
                    self.loadingIndicator.hidden = true
                    self.loginWithFacebookButton.hidden = false
                }
            })
        }
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        self.loginWithFacebookButton.hidden = true
        self.loadingIndicator.hidden = false
        if error != nil {
            print(error.localizedDescription)
            return
        }
        
        if result.isCancelled {
            print("User cancelled login")
            return
        }
        UserController.sharedController.loginFirebaseUser { (success) in
            dispatch_async(dispatch_get_main_queue(), {
                print("Firebase login called")
                self.performSegueWithIdentifier(self.loginSegueString, sender: self)
            })
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        // logout Firebase user
        UserController.sharedController.logoutCurrentUser { (success) in
            print("User logged out")
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func loginWithFB(sender: AnyObject) {
        UserController.sharedController.loginWithFacebook(self) { (success) in
            if success {
                UserController.sharedController.loginFirebaseUser({ (success) in
                    if success {
                        self.performSegueWithIdentifier(self.loginSegueString, sender: self)
                        print("Logged in!")
                    }
                })
            }
        }
    }
    
}
