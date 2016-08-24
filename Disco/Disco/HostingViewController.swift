//
//  HostingViewController.swift
//  Disco
//
//  Created by Tim on 8/22/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class HostingViewController: UIViewController, SPTAuthViewDelegate, SPTAudioStreamingDelegate {
    
    @IBOutlet weak var spotifyLoginView: UIView!
    @IBOutlet weak var loginWithSpotifyButton: UIButton!
    
    private var playlistsTableView: PlaylistListViewController!
    
    var session: SPTSession?
    
    let spotifyLoginNotificationKey = "spotifyLoginSuccessful"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Specify PlaylistTableView's user
        guard let currentUser = UserController.sharedController.currentUser else { return }
        playlistsTableView.user = currentUser
        
        // Provides SPTAuth information for SPTAuthViewController
        UserController.sharedController.setupSPTAuth()
        
        UserController.sharedController.checkSpotifyUserAuth { (loggedIn, session) in
            if loggedIn {
                if let session = session {
                    self.session = session
                    self.updateViewWithLoginStatus()
                }
            } else {
                print("No spotify user logged in")
                self.updateViewWithLoginStatus()
            }
        }
        
        // Listen for when Spotify user logs in successfully
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HostingViewController.updateViewWithLoginStatus), name: spotifyLoginNotificationKey, object: nil)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
    }
    
    
    // MARK: - Spotify Authentication
    
    func updateViewWithLoginStatus() {
        if session != nil {
            spotifyLoginView.hidden = true
        } else {
            spotifyLoginView.hidden = false
        }
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
        self.session = session
        // Post notification so HostViewController knows about successful login
        NSNotificationCenter.defaultCenter().postNotificationName(spotifyLoginNotificationKey, object: nil)
        
        self.loginUsingSession(session)
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
    
    // MARK: - Spotify Streaming
    
    func loginUsingSession(session: SPTSession) {
        player.delegate = self
        do {
            try player.startWithClientId(UserController.spotifyClientID)
        } catch {
            print(error)
        }
        player.loginWithAccessToken(session.accessToken)
    }
    
    
    func audioStreamingDidLogin(audioStreaming: SPTAudioStreamingController!) {
        let url = NSURL(string: "spotify:track:0j0DNujXWeupLpZobbABoo")
        if let player = player {
            player.playURI(url, startingWithIndex: 0) { (error) in
                if error != nil {
                    print("Error playing track.")
                } else {
                    print("Success")
                }
            }
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "playlistTVEmbedSegue" {
            playlistsTableView = segue.destinationViewController as? PlaylistListViewController
        }
    }
    
    
    // MARK: - IBActions
    
    @IBAction func loginWithSpotifyButtonTapped(sender: AnyObject) {
        presentSPTAuthViewController()
    }
    
    @IBAction func hostNewPlaylistTapped(sender: AnyObject) {
        self.parentViewController?.performSegueWithIdentifier("hostPlaylistSegue", sender: self)
    }
    
}
