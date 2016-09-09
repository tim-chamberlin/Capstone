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
        AppearanceController.initializeAppearance()
        
        // Init Firebase
        FIRApp.configure()
        
        // Init Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Setup Spotify User
        UserController.sharedController.setupSPTAuth()
        
        return true
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if SPTAuth.defaultInstance().canHandleURL(url) {
            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: { (error, session) in
                if error != nil {
                    print(error.localizedDescription)
                    print(error)
                    return
                }
                
                if session != nil {
                    print(session)
                    NSNotificationCenter.defaultCenter().postNotificationName(kSpotifyLoginNotificationKey, object: nil, userInfo: [kSpotifyLoginNotificationKey:session])
                    print("Spotify user logged in natively")
                }
            })
            return true
        }
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationWillTerminate(application: UIApplication) {
        PlaylistController.sharedController.removeAllObserversFromFirebaseRef()
    }

}

