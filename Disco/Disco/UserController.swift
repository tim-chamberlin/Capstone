//
//  UserController.swift
//  Disco
//
//  Created by Tim on 8/21/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import Foundation
import FirebaseAuth
import FBSDKCoreKit

class UserController {
    
    static let sharedController = UserController()
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    private let facebookPermissions = ["public_profile","user_friends"]
    
    // Spotify Constants
    static let spotifyClientID = "a0578e15af3a46baa2dbabf176f60952"
    static let spotifyRedirectURL = NSURL(string: "disco-login://callback")
    static let spotifyRefreshServiceURL = NSURL(string: "https://aqueous-crag-42337.herokuapp.com/refresh")
    static let spotifySwapServiceURL = NSURL(string: "https://aqueous-crag-42337.herokuapp.com/swap")
    
    
    var currentUser: User?
    
    // Check authentication
    
    func checkFirebaseUserAuth(completion: (success: Bool) -> Void) {
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
            if let user = user {
                // Set user of current session
                guard let name = user.displayName else { return }
                // Check Facebook token
                if let _ = FBSDKAccessToken.currentAccessToken() {
                    self.getCurrentUserFBID({ (ID, success) in
                        if let FBID = ID {
                            let currentUser = User(FBID: FBID, name: name)
                            self.currentUser = currentUser
                            completion(success: true)
                        }
                    })
                } else {
                    print("No Facebook access token")
                    completion(success: false)
                }
            } else {
                completion(success: false)
            }
        })
    }
    
    // login
    
    func loginFirebaseUserWithFacebookCredential(credential: FIRAuthCredential, completion: (success: Bool) -> Void) {
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
    
    func logoutCurrentUser() {
        // Logout Firebase
        try! FIRAuth.auth()!.signOut()
        // Logout Facebook
        FBSDKAccessToken.setCurrentAccessToken(nil)
    }
}

// MARK: - Facebook

extension UserController {
    
    // Login
    
//    func loginWithFacebook(viewController: UIViewController, completion: (success: Bool) -> Void) {
//        let fbLoginManager = FBSDKLoginManager()
//        fbLoginManager.logInWithReadPermissions(facebookPermissions, fromViewController: viewController) { (result, error) in
//            if error == nil {
//                if result.isCancelled {
//                    completion(success: false)
//                    return
//                } else {
//                    completion(success: true)
//                }
//            }
//        }
//    }
    
    // Retrieve profile picture
    
    func getCurrentUserProfilePicture(forUser user: User, completion: (profilePicture: UIImage?) -> Void) {
        guard let url = NSURL(string: "https://graph.facebook.com/\(user.FBID)/picture?type=small") else {
            completion(profilePicture: nil)
            return
        }
        ImageController.getImageFromURL(url) { (image, success) in
            guard let image = image else {
                completion(profilePicture: nil)
                return
            }
            completion(profilePicture: image)
        }
    }
    
//    func getCurrentUserProfilePicture(forUser user: User, completion: () -> Void) {
//        let facebookRequest = FBSDKGraphRequest(graphPath: "me/picture", parameters: [:], HTTPMethod: NetworkController.HTTPMethod.Get.rawValue)
//        facebookRequest.startWithCompletionHandler { (connection, result, error) in
//            print(result)
//            completion()
//        }
//    }
    
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
        let request = FBSDKGraphRequest(graphPath: "me/friends", parameters: [:], HTTPMethod: "GET")
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
    
    func getCurrentSpotifyUserData(session: SPTSession, completion: (spotifyUser: SpotifyUser?, success: Bool) -> Void) {
        SPTUser.requestCurrentUserWithAccessToken(session.accessToken) { (error, user) in
            if error != nil {
                print(error.localizedDescription)
                completion(spotifyUser: nil, success: false)
            } else {
                guard let sptUser = user as? SPTUser else {
                    completion(spotifyUser: nil, success: false)
                    return
                }
                
                let spotifyUser = SpotifyUser(displayName: nil, canonicalUserName: nil, imageURL: nil)
                
                // Check for Spotify data. They have to at least have a canonical name
                if let displayName = sptUser.displayName {
                    spotifyUser.displayName = displayName
                }
                
                if let canonicalName = sptUser.canonicalUserName {
                    spotifyUser.canonicalUserName = canonicalName
                }
                
                if let userImageURL = sptUser.smallestImage?.imageURL {
                    spotifyUser.imageURL = userImageURL
                }
                
                completion(spotifyUser: spotifyUser, success: true)
            }
        }
    }
    
    func setupSPTAuth() {
        guard let currentUser = UserController.sharedController.currentUser else { return }
        // Set properties for SPTAuth singleton
        SPTAuth.defaultInstance().clientID = UserController.spotifyClientID
        SPTAuth.defaultInstance().redirectURL = UserController.spotifyRedirectURL
//        SPTAuth.defaultInstance().tokenRefreshURL = UserController.spotifyRefreshServiceURL
//        SPTAuth.defaultInstance().tokenSwapURL = UserController.spotifySwapServiceURL
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope]
        SPTAuth.defaultInstance().sessionUserDefaultsKey = currentUser.FBID
        SPTAuth.defaultInstance().allowNativeLogin = true
    }
    
    func checkSpotifyUserAuth(completion: (loggedIn: Bool, session: SPTSession?) -> Void) {
        // Check for valid session in NSUserDefaults
        if let sessionObject: AnyObject = userDefaults.objectForKey(SPTAuth.defaultInstance().sessionUserDefaultsKey) {
            if let sessionDataObject = sessionObject as? NSData, session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionDataObject) as? SPTSession {
                // Check if session is valid
                if !session.isValid() { // session isn't valid
                    completion(loggedIn: false, session: nil)
                    
                    // TODO: If there's a valid token refresh service, renew the token
//                    if SPTAuth.defaultInstance().hasTokenRefreshService {
//                        renewToken({ (success, session) in
//                            if success {
//                                guard let session = session else {
//                                    completion(loggedIn: false, session: nil)
//                                    return
//                                }
//                                completion(loggedIn: true, session: session)
//                                return
//                            } else {
//                                completion(loggedIn: false, session: nil)
//                            }
//                        })
//                    } else { // No token refresh service specified
//                        completion(loggedIn: false, session: nil)
//                    }
                } else { // Valid existing token
                    print("Spotify user already logged in")
                    completion(loggedIn: true, session: session)
                }
            } else {
                completion(loggedIn: false, session: nil)
            }
        } else { // Not logged in (token is nil)
            print("Spotify user not logged in")
            completion(loggedIn: false, session: nil)
        }
    }
    
    func renewToken(completion: (success: Bool, session: SPTSession?) -> Void) {
        let auth = SPTAuth.defaultInstance()
        auth.renewSession(auth.session) { (error, session) in
            if error != nil {
                print("Error while refreshing Spotify token: \(error)")
                completion(success: false, session: nil)
                return
            } else {
                completion(success: true, session: session)
            }
        }
    }
    
    // Called when the user segues to the SPTAudioStreamingDelegate
    func loginToSpotifyUsingSession(session: SPTSession) {
        do {
            try spotifyPlayer.startWithClientId(UserController.spotifyClientID)
            spotifyPlayer.loginWithAccessToken(session.accessToken)
            saveSessionToUserDefaults(session)
        } catch {
            print(error)
        }
    }
    
    func logoutOfSpotify(completion:() -> Void) {
        spotifyPlayer.logout()
        deleteSessionFromUserDefaults()
        completion()
    }
    
    // MARK: Spotify - NSUserDefaults
    
    func saveSessionToUserDefaults(session: SPTSession) {
        // Convert to NSData
        let sessionData = NSKeyedArchiver.archivedDataWithRootObject(session)
        userDefaults.setObject(sessionData, forKey: SPTAuth.defaultInstance().sessionUserDefaultsKey)
        userDefaults.synchronize()
    }
    
    func deleteSessionFromUserDefaults() {
        userDefaults.removeObjectForKey(SPTAuth.defaultInstance().sessionUserDefaultsKey)
        userDefaults.synchronize()
    }
    
}



