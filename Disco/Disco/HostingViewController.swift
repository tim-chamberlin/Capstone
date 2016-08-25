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

class HostingViewController: UIViewController, SPTAudioStreamingDelegate, PlaylistTableViewDataSource {
    
    private var playlistsTableView: PlaylistListViewController!
    private var spotifyLoginVC: SpotifyLoginViewController!
    
    @IBOutlet weak var spotifyLoginView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Provides SPTAuth information for SPTAuthViewController
        UserController.sharedController.setupSPTAuth()
        checkSpotifyAuth()
        
        // Listen for when Spotify user logs in successfully
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HostingViewController.checkSpotifyAuth), name: spotifyLoginNotificationKey, object: nil)
        // Listen for when Spotify user logs out successfully
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HostingViewController.checkSpotifyAuth), name: spotifyLogoutNotificationKey, object: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        updatePlaylistTableView()
    }
    
    func updatePlaylistTableView() {
        // Specify PlaylistTableView's user
        guard let currentUser = UserController.sharedController.currentUser else { return }
        playlistsTableView.updatePlaylistViewWithUser(currentUser, withPlaylistType: .Hosting, withNoPlaylistsText: "You aren't currently hosting any playlists.")
    }
    
    // MARK: - Spotify Authentication
    
    func checkSpotifyAuth() {
        UserController.sharedController.checkSpotifyUserAuth { (loggedIn, session) in
            if loggedIn {
                if let _ = session {
                    self.spotifyLoginView.hidden = true
                    self.updatePlaylistTableView()
                }
            } else {
                self.spotifyLoginView.hidden = false
            }
        }
    }
    
    // MARK: - Spotify Streaming
    
    func audioStreamingDidLogin(audioStreaming: SPTAudioStreamingController!) {
        let url = NSURL(string: "spotify:track:0j0DNujXWeupLpZobbABoo")
        if let player = spotifyPlayer {
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
        } else if segue.identifier == "spotifyLoginEmbeddedSegue" {
            spotifyLoginVC = segue.destinationViewController as? SpotifyLoginViewController
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func hostNewPlaylistTapped(sender: AnyObject) {
        self.parentViewController?.performSegueWithIdentifier("hostPlaylistSegue", sender: self)
    }
}