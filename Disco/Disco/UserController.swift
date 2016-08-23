//
//  UserController.swift
//  Disco
//
//  Created by Tim on 8/21/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import Foundation
import FirebaseAuth
import FBSDKLoginKit

class UserController {
    
    static let sharedController = UserController()
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    private let facebookPermissions = ["public_profile","user_friends"]
    
    // Spotify Constants
    static let spotifyClientID = "a0578e15af3a46baa2dbabf176f60952"
    static let spotifyRedirectURL = NSURL(string: "disco-login://callback")
    static let spotifyUserDefaultsSessionKey = "SpotifySession"
    
    var currentUser: User?
    
    // Check authentication
    
    func checkUserAuth(completion: (success: Bool) -> Void) {
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
            if let user = user {
                // Set user of current session
                guard let name = user.displayName else { return }
                
                // Check Facebook token
                if let fbAccessToken = FBSDKAccessToken.currentAccessToken() {
                    print("Access token valid")
                    self.getCurrentUserFBID({ (ID, success) in
                        if let FBID = ID {
                            let currentUser = User(FBID: FBID, name: name)
                            self.currentUser = currentUser
                            completion(success: true)
                        }
                    })
                    
                } else {
                    print("No access token")
                    completion(success: false)
                }
            } else {
                completion(success: false)
            }
        })
    }
    
    
    // login
    
    func loginWithFacebook(viewController: UIViewController, completion: (success: Bool) -> Void) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logInWithReadPermissions(facebookPermissions, fromViewController: viewController) { (result, error) in
            if error == nil {
                if result.isCancelled {
                    completion(success: false)
                    return
                } else {
                    completion(success: true)
                }
            }
        }
    }
    
    func loginFirebaseUser(completion: (success: Bool) -> Void) {
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
            let success = user != nil && error == nil
            if let user = user, name = user.displayName {
                self.getCurrentUserFBID({ (ID, success) in
                    if let FBID = ID {
                        let currentUser = User(FBID: FBID, name: name)
                        self.currentUser = currentUser
                        completion(success: success)
                    }
                })
            } else {
                print(error?.localizedDescription)
                completion(success: success)
            }
        })
    }
    
    // logout
    
    func logoutCurrentUser(completion: (success: Bool) -> Void) {
        // Logout Firebase
        try! FIRAuth.auth()!.signOut()
        // Logout Facebook
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logOut()
        completion(success: true)
    }
    
    
    
    
    
    // Retrieve current Facebook User ID
    
    func getCurrentUserFBID(completion: (ID: String?, success: Bool) -> Void) {
        let request = FBSDKGraphRequest(graphPath: "me", parameters: nil, HTTPMethod: "GET")
        request.startWithCompletionHandler { (connection, result, error) in
            if let currentUserID = result["id"] as? String {
                completion(ID: currentUserID, success: true)
            } else {
                completion(ID: nil, success: false)
            }
        }
    }
    
    
    // Retrieve Friends List
    
    func getFriends(completion: (friends: [User]?, success: Bool) -> Void) {
        let request = FBSDKGraphRequest(graphPath: "me/friends", parameters: nil, HTTPMethod: "GET")
        request.startWithCompletionHandler { (connection, result, error) in
            if let data = result["data"] as? [[String: AnyObject]] {
                let friends = data.flatMap { User(dictionary: $0) }
                completion(friends: friends, success: true)
            } else {
                completion(friends: nil, success: false)
            }
        }
    }
    
}


// MARK: - Spotify Auth

extension UserController {
    
    func checkSpotifyUserAuth(completion: (loggedIn: Bool, session: SPTSession?) -> Void) {
        // Check for valid session
        if let sessionObject: AnyObject = userDefaults.objectForKey(UserController.spotifyUserDefaultsSessionKey) {
            guard let sessionDataObject = sessionObject as? NSData, session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionDataObject) as? SPTSession else { return }
            
            // If session has expired, renew session
            if !session.isValid() {
                SPTAuth.defaultInstance().renewSession(session, callback: { (error, session) in
                    if error == nil {
                        self.saveSessionToUserDefaults(session)
                        completion(loggedIn: true, session: session)
                    }
                })
            } else {
                print("Session is valid")
                completion(loggedIn: true, session: session)
            }
        } else { // Not logged in (token is nil)
            completion(loggedIn: false, session: nil)
        }
    }
    
    func saveSessionToUserDefaults(session: SPTSession) {
        // Convert to NSData
        let sessionData = NSKeyedArchiver.archivedDataWithRootObject(session)
        userDefaults.setObject(sessionData, forKey: UserController.spotifyUserDefaultsSessionKey)
        userDefaults.synchronize()
    }
    
    func setupSPTAuth() {
        // Set properties for SPTAuth singleton
        SPTAuth.defaultInstance().clientID = UserController.spotifyClientID
        SPTAuth.defaultInstance().redirectURL = UserController.spotifyRedirectURL
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope]
        SPTAuth.defaultInstance().sessionUserDefaultsKey = UserController.spotifyUserDefaultsSessionKey
        SPTAuth.defaultInstance().allowNativeLogin = true
    }
    
//    func logoutOfSpotify(session: SPTSession) {
//        session.accessToken = nil
//    }
    
}





