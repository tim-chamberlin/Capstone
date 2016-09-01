//
//  HostingViewController.swift
//  Disco
//
//  Created by Tim on 8/22/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

public let spotifyLoginNotificationKey = "spotifyLoginSuccessful"
public let spotifyLogoutNotificationKey = "spotifyLogoutSuccessful"

class HostingViewController: UIViewController, SPTAuthViewDelegate {
    
    var streamingVC: StreamingViewController!
    
    @IBOutlet weak var streamingContainerView: UIView!
    @IBOutlet weak var spotifyLoginView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Provides SPTAuth information for SPTAuthViewController
        UserController.sharedController.setupSPTAuth()
        checkSpotifyAuth()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)

        checkSpotifyAuth()
    }
    
    func updateViewForLogin() {
        let session = SPTAuth.defaultInstance().session
        if session.isValid() {
            self.spotifyLoginView.hidden = true
        } else {
            self.spotifyLoginView.hidden = false
        }
    }
    
    
    // MARK: - Spotify Authentication
    
    func authenticationViewController(authenticationViewController: SPTAuthViewController!, didLoginWithSession session: SPTSession!) {
        print("Spotify user logged in")
        updateViewForLogin()
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
    
    func renewSpotifyTokenAndShowPlayer() {
        let auth = SPTAuth.defaultInstance()
        auth.renewSession(auth.session) { (error, session) in
            auth.session = session
            if (error != nil) {
                print("Error renewing Spotify session")
                return
            }
            // show player
            self.updateViewForLogin()
        }
    }
    
    func checkSpotifyAuth() {
        let auth = SPTAuth.defaultInstance()
        
        if auth.session == nil {
            return
        }
        
        if !auth.session.isValid() {
            // Should hide login
            updateViewForLogin()
            return
        }
        
        if auth.hasTokenRefreshService {
            self.renewSpotifyTokenAndShowPlayer()
        } else {
            // Should show login
            updateViewForLogin()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedStreamingController" {
            streamingVC = segue.destinationViewController as? StreamingViewController
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func startQueue(sender: AnyObject) {
        PlaylistController.sharedController.createPlaylist("test", completion: { (success, playlist) in
            if success {
                guard let playlist = playlist, currentUser = UserController.sharedController.currentUser else { return }
                PlaylistController.sharedController.createPlaylistReferenceForUserID(playlist, userID: currentUser.FBID, playlistType: .Hosting, completion: { (success) in
//                    self.performSegueWithIdentifier("unwindToHomeSegue", sender: self)
                    print("New queue created")
                })
            }
        })
    }
    
    @IBAction func loginToSpotifyTapped(sender: AnyObject) {
        presentSPTAuthViewController()
    }
}