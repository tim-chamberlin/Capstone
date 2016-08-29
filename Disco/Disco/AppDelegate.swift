//
//  AppDelegate.swift
//  Disco
//
//  Created by Tim on 8/21/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit

// Firebase Database Reference
let firebaseRef = FIRDatabase.database().reference()

var spotifyPlayer = SPTAudioStreamingController.sharedInstance()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Init Firebase
        FIRApp.configure()
        
        // Init Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        if SPTAuth.defaultInstance().canHandleURL(url) {
            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: { (error, session) in
                if error != nil {
                    print("Error logging in Spotify user: \(error.localizedDescription)")
                    return
                }
                
                
                print("Spotify user logged in")
//                HostingViewController.session = session
                //        // Post notification so HostViewController knows about successful login
                NSNotificationCenter.defaultCenter().postNotificationName(spotifyLoginNotificationKey, object: nil)
                
                UserController.sharedController.loginToSpotifyUsingSession(session)
            })
        }

        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }


}

