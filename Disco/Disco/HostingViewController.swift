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

class HostingViewController: UIViewController, PlaylistTableViewDataSource, PlaylistTableViewDelegate, SPTAuthViewDelegate {
    
    var playlistsTableView: PlaylistListViewController!
    
//    var session: SPTSession?
    
    @IBOutlet weak var spotifyLoginView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playlistsTableView.delegate = self
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
            self.updatePlaylistTableView()
        } else {
            self.spotifyLoginView.hidden = false
        }
    }
    
    func updatePlaylistTableView() {
        // Specify PlaylistTableView's user
        guard let currentUser = UserController.sharedController.currentUser else { return }
        playlistsTableView.updatePlaylistViewWithUser(currentUser, withPlaylistType: .Hosting, withNoPlaylistsText: "You aren't currently hosting any playlists.")
    }
    
    func didSelectRowAtIndexPathInPlaylistTableView(indexPath indexPath: NSIndexPath) {
        self.parentViewController?.performSegueWithIdentifier("toStreamingController", sender: self)
    }
    
    func didDeselectRowAtIndexPathInPlaylistTableView(indexPath indexPath: NSIndexPath) {
        //
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
        if segue.identifier == "playlistTVEmbedSegue" {
            playlistsTableView = segue.destinationViewController as? PlaylistListViewController
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func loginToSpotifyTapped(sender: AnyObject) {
        presentSPTAuthViewController()
    }
    
    @IBAction func hostNewPlaylistTapped(sender: AnyObject) {
        self.parentViewController?.performSegueWithIdentifier("hostPlaylistSegue", sender: self)
    }
}