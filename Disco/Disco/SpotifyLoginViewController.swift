//
//  SpotifyLoginViewController.swift
//  Disco
//
//  Created by Tim on 8/24/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class SpotifyLoginViewController: UIViewController, SPTAuthViewDelegate {
    
    @IBOutlet weak var loginWithSpotifyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func presentSPTAuthViewController() {
        
        // Authenticate with Spotify's authenticationViewController
        let authVC = SPTAuthViewController.authenticationViewController()
        authVC.delegate = self
        authVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        authVC.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.definesPresentationContext = true
        self.presentViewController(authVC, animated: false, completion: nil)
        
        // Uncomment to perform authentication in Safari
        //        let loginURL = SPTAuth.defaultInstance().loginURL
        //        UIApplication.sharedApplication().openURL(loginURL)
    }
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        print("Spotify user logged in")
        // Post notification so HostViewController knows about successful login
        NSNotificationCenter.defaultCenter().postNotificationName(spotifyLoginNotificationKey, object: nil)
        
        UserController.sharedController.loginToSpotifyUsingSession(session)
        authenticationViewController.clearCookies(nil)
    }
    
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didFailToLogin error: NSError!) {
        print("spotify user failed to login")
        print(error)
        authenticationViewController.clearCookies(nil)
    }
    
    func authenticationViewControllerDidCancelLogin(authenticationViewController: SPTAuthViewController!) {
        print("Spotify user cancelled login")
        authenticationViewController.clearCookies(nil)
    }
    
    @IBAction func loginWithSpotifyButtonTapped(sender: AnyObject) {
        presentSPTAuthViewController()
    }
    
}
