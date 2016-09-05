//
//  AuthenticationViewController.swift
//  Disco
//
//  Created by Tim on 8/21/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth

class AuthenticationViewController: UIViewController, FBSDKLoginButtonDelegate{
    
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginWithFacebookButton: FBSDKLoginButton!
    @IBOutlet weak var loginWithFacebookView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.hidesWhenStopped = true
        
        loginWithFacebookView.hidden = true
        loadingIndicator.startAnimating()
        
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
            if let user = user {
                
                // Set user of current session
                guard let name = user.displayName else { return }
                UserController.sharedController.getCurrentUserFBID({ (ID, success) in
                    if let FBID = ID {
                        let currentUser = User(FBID: FBID, name: name)
                        UserController.sharedController.currentUser = currentUser
                        
                        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let homeVC = mainStoryboard.instantiateViewControllerWithIdentifier("HomeNavView")
                        
                        self.presentViewController(homeVC, animated: true, completion: nil)
                    }
                })
                
            } else {
                self.loginWithFacebookButton.delegate = self
                self.loginWithFacebookButton.readPermissions = ["public_profile", "email", "user_friends"]
                
                self.loginWithFacebookView.hidden = false
                self.loadingIndicator.stopAnimating()
            }
        })
        
        
        
        loadingIndicator.hidden = false
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        self.loadingIndicator.startAnimating()
        self.loginWithFacebookView.hidden = true
        
        if error != nil {
            loginWithFacebookView.hidden = false
            loadingIndicator.stopAnimating()
            print(error.localizedDescription)
            return
        }
        if result.isCancelled {
            loginWithFacebookView.hidden = false
            loadingIndicator.stopAnimating()
            print("User cancelled login")
            return
        }
        
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        UserController.sharedController.loginFirebaseUserWithFacebookCredential(credential) { (success) in
            dispatch_async(dispatch_get_main_queue(), {
                
            })
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    // MARK: - IBActions
    
    @IBAction func privacyPolicyTapped(sender: AnyObject) {
        guard let privacyPolicyURL = NSURL(string: "http://static1.squarespace.com/static/5795a3a42e69cf39f3b84ce4/t/57cda01ce6f2e166971b75c1/1473093660454/A-Side-privacy-policy-september-05-2016.pdf") else {
            return
        }
        UIApplication.sharedApplication().openURL(privacyPolicyURL)
    }
    
    
}
