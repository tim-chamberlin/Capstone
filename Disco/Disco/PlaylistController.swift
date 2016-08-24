//
//  PlaylistController.swift
//  Disco
//
//  Created by Tim on 8/23/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import Foundation
import FirebaseDatabase


class PlaylistController {
    
    static let sharedController = PlaylistController()
    
    var playlists: [Playlist] = []
    
    
    // MARK: - Create Playlist
    
    func createPlaylist(name: String, completion: (success: Bool, playlist: Playlist?) -> Void) {
        // Generate new uid in Playlists directory
        let key = firebaseRef.child(Playlist.parentDirectory).childByAutoId().key
        let playlist = Playlist(uid: key, name: name)
        firebaseRef.child(Playlist.parentDirectory).child(key).setValue(playlist.jsonValue) { (error, _) in
            if error == nil {
                print("Create new playlist")
                completion(success: true, playlist: playlist)
            } else {
                print("Error creating new playlist in Firebase: \(error?.localizedDescription)")
                completion(success: false, playlist: nil)
            }
        }
    }
    
    func createPlaylistReferenceForUserID(playlistID: String, userID: String, completion:(success: Bool) -> Void) {
        firebaseRef.child(User.parentDirectory).child(userID).child(User.kHostingPlaylists).child(playlistID).setValue(true) { (error, _) in
            if error == nil {
                completion(success: true)
            } else {
                completion(success: false)
            }
        }
    }
    
    // MARK: - Fetch Playlists
    
    func fetchPlaylistsForUser(FBID: String, ofType: PlaylistType, completion:(playlists: [Playlist]?, success: Bool) -> Void) {
        guard let currentUser = UserController.sharedController.currentUser else { return }
        
        firebaseRef.child(User.parentDirectory).child(currentUser.FBID).child(ofType.rawValue).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            guard let playlistIDsDictionary = snapshot.value as? [String: AnyObject] else {
                completion(playlists: nil, success: true)
                return
            }
            let playlistIDs = playlistIDsDictionary.flatMap { $0.0 }
            
            var playlistsArray: [Playlist] = []
            // Now fetch playlistsByID
            for playlistID in playlistIDs {
                firebaseRef.child(Playlist.parentDirectory).child(playlistID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    guard let playlistDictionary = snapshot.value as? [String: AnyObject] else {
                        completion(playlists: nil, success: false)
                        return
                    }
                    guard let playlist = Playlist(dictionary: playlistDictionary, uid: playlistID) else {
                        completion(playlists: nil, success: false)
                        return
                    }
                    playlistsArray.append(playlist)
                    
                    if playlistsArray.count == playlistIDs.count {
                        completion(playlists: playlistsArray, success: true)
                    }
                    }, withCancelBlock: { (error) in
                        //
                })   
            }
            
        }) { (error) in
            //
        }
    }
    
    func addTrackToPlaylist() {
        
    }
    
    func removeTrackFromPlaylist() {
        
    }
    
    func deletePlaylist() {
        
    }
    
    func addUserAsPlaylistContributor() {
        
    }
    
    func removeUserAsPlaylistContributor() {
        
    }
}