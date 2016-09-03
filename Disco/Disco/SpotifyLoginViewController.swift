//
//  SpotifyLoginViewController.swift
//  Disco
//
//  Created by Tim on 9/2/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit


public let kSpotifyLoginNotificationKey = "spotifyLoginSuccessful"
public let spotifyLogoutNotificationKey = "spotifyLogoutSuccessful"

class SpotifyLoginViewController: UIViewController, SPTAuthViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Provides SPTAuth information for SPTAuthViewController
        UserController.sharedController.setupSPTAuth()
    }
    
    // MARK: - Spotify Authentication
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        print("Spotify user logged in")
        
        NSNotificationCenter.defaultCenter().postNotificationName(kSpotifyLoginNotificationKey, object: nil, userInfo: [kSpotifyLoginNotificationKey:session])
        
        //        self.session = session
        //        authenticationViewController.clearCookies(nil)
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
    
    func presentSPTAuthViewController() {
        
        // Authenticate with Spotify's authenticationViewController
        let spotifyAuthViewController = SPTAuthViewController.authenticationViewController()
        spotifyAuthViewController.delegate = self
        spotifyAuthViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        spotifyAuthViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.definesPresentationContext = true
        self.presentViewController(spotifyAuthViewController, animated: false, completion: nil)
        
        // Uncomment to perform authentication in Safari
        //        let loginURL = SPTAuth.defaultInstance().loginURL
        //        UIApplication.sharedApplication().openURL(loginURL)
    }
    
    
    
    

    @IBAction func loginToSpotifyTapped(sender: AnyObject) {
        presentSPTAuthViewController()
    }
}
