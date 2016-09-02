//
//  PlaylistController.swift
//  Disco
//
//  Created by Tim on 8/23/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import Foundation
import FirebaseDatabase

let kDidSetHostedPlaylist = "DidSetHostedPlaylist"

class PlaylistController {
    
    static let sharedController = PlaylistController()
    var hostedPlaylist: Playlist? {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(kDidSetHostedPlaylist, object: nil)
        }
    }
    
    init () {
        guard let currentUser = UserController.sharedController.currentUser else { return }
        fetchHostedPlaylistForUser(currentUser.FBID) { (playlist, success) in
            guard let playlist = playlist else { return }
            self.hostedPlaylist = playlist
        }
    }
    
    deinit {
        self.hostedPlaylist = nil
    }
    
    // MARK: - Create Playlist
    
    func createPlaylist(name: String, completion: (success: Bool, playlist: Playlist?) -> Void) {
        // Generate new uid in Playlists directory
        let key = firebaseRef.child(Playlist.parentDirectory).childByAutoId().key
        let playlist = Playlist(uid: key)
        firebaseRef.child(Playlist.parentDirectory).child(key).setValue(playlist.jsonValue) { (error, _) in
            if error == nil {
                print("Created new playlist")
                completion(success: true, playlist: playlist)
            } else {
                print("Error creating new playlist in Firebase: \(error?.localizedDescription)")
                completion(success: false, playlist: nil)
            }
        }
    }
    
    func createPlaylistReferenceForUserID(playlist: Playlist, userID: String, playlistType: PlaylistType, completion:(success: Bool) -> Void) {
        firebaseRef.child(User.parentDirectory).child(userID).child(playlistType.rawValue).child(playlist.uid).setValue(true) { (error, _) in
            if error == nil {
                completion(success: true)
            } else {
                completion(success: false)
            }
        }
    }
    
    // MARK: - Fetch Playlist
    
    func fetchHostedPlaylistForUser(FBID: String, completion:(playlist: Playlist?, success: Bool) -> Void) {
        firebaseRef.child(User.parentDirectory).child(FBID).child(PlaylistType.Hosting.rawValue).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            guard let playlistDictionary = snapshot.value as? [String: AnyObject] else {
                completion(playlist: nil, success: true)
                return
            }
            let playlistID = playlistDictionary.first!.0
            
            firebaseRef.child(Playlist.parentDirectory).child(playlistID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                guard let playlistDictionary = snapshot.value as? [String: AnyObject] else {
                    completion(playlist: nil, success: false)
                    return
                }
                guard let playlist = Playlist(dictionary: playlistDictionary, uid: playlistID) else {
                    completion(playlist: nil, success: false)
                    return
                }
                completion(playlist: playlist, success: true)
            })
        })
    }
    
    
    func fetchPlaylistsForUser(FBID: String, ofType: PlaylistType, completion:(playlists: [Playlist]?, success: Bool) -> Void) {
        firebaseRef.child(User.parentDirectory).child(FBID).child(ofType.rawValue).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
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
        })
    }
    
    
    // MARK: - Add/Remove a track
    func addTrack(track: Track, toPlaylist playlist: Playlist, completion: (success: Bool) -> Void) {
        firebaseRef.child(Playlist.parentDirectory).child(playlist.uid).child(Playlist.kUpNext).childByAutoId().setValue(track.jsonValue) { (error, _) in
            if error == nil {
                completion(success: true)
            } else {
                print(error?.localizedDescription)
                completion(success: false)
            }
        }
    }
    
    func removeTrack(track: Track, fromPlaylist playlist: Playlist, completion: (error: NSError?) -> Void) {
        firebaseRef.child(Playlist.parentDirectory).child(playlist.uid).child(Playlist.kTrackList).child(track.firebaseUID).removeValueWithCompletionBlock { (error, _) in
            if error == nil {
                completion(error: nil)
            } else {
                completion(error: error)
            }
        }
    }
    
    // MARK: - Fetch Tracks
    
    func fetchTrackIDsForPlaylist(playlist: Playlist, completion: (trackID: [String]?, success: Bool) -> Void) {
        firebaseRef.child(Playlist.parentDirectory).child(playlist.uid).child(Playlist.kTrackList).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            guard let tracksArray = snapshot.value as? [String: [String: AnyObject]] else { return }
            let trackIDs = tracksArray.flatMap { $0.0 }
            completion(trackID: trackIDs, success: true)
        })
    }
    
    func fetchTracksForPlaylist(playlist: Playlist, completion: (tracks: [Track]?, success: Bool) -> Void) {
        firebaseRef.child(Playlist.parentDirectory).child(playlist.uid).child(Playlist.kTrackList).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            
            guard let trackDictionaryArray = snapshot.value as? [String: [String: AnyObject]] else { return }
            let tracks = trackDictionaryArray.flatMap { Track(firebaseDictionary: $0.1, uid: $0.0) }
            completion(tracks: tracks, success: true)
            
        }) { (error) in
            //
        }
    }
    
    func addTrackObserverForPlaylist(playlist: Playlist, completion: (track: Track?, didAdd: Bool) -> Void) {
        
        firebaseRef.child(Playlist.parentDirectory).child(playlist.uid).child(Playlist.kTrackList).observeEventType(.ChildAdded, withBlock: { (snapshot) in
            guard let trackDictionary = snapshot.value as? [String: AnyObject] else { return }
            let track = Track(firebaseDictionary: trackDictionary, uid: snapshot.key)
            completion(track: track, didAdd: true)
        })
        
        // Observe deletions
        firebaseRef.child(Playlist.parentDirectory).child(playlist.uid).child(Playlist.kTrackList).observeEventType(.ChildRemoved, withBlock: { (snapshot) in
            guard let trackDictionary = snapshot.value as? [String: AnyObject] else {
                print("error")
                return
            }
            let track = Track(firebaseDictionary: trackDictionary, uid: snapshot.key)
            completion(track: track, didAdd: false)
        })
    }
    
    func removeTrackObserverForPlaylist(playlist: Playlist, completion: (success: Bool) -> Void) {
        firebaseRef.child(Playlist.parentDirectory).child(playlist.uid).child(Playlist.kTrackList).removeAllObservers()
        completion(success: true)
    }
    
    
    
    func deletePlaylist() {
        
    }
    
    
    // MARK: - Manage Playlist Contributors
    
    func addContributor(user: User, toPlaylist playlist: Playlist, completion: (success: Bool) -> Void) {
        // Add contributor to playlist object's contributors array
        firebaseRef.child(Playlist.parentDirectory).child(playlist.uid).child(Playlist.kContributorsList).updateChildValues([user.FBID: true], withCompletionBlock: { (error, _) in
            if error != nil {
                print(error?.localizedDescription)
                completion(success: false)
            } else {
                // Add to user object
                firebaseRef.child(User.parentDirectory).child(user.FBID).child(PlaylistType.Contributing.rawValue).child(playlist.uid).setValue(true, withCompletionBlock: { (error, _) in
                    if error == nil {
                        completion(success: true)
                    } else {
                        print("Error saving playlist to user object in Firebase: \(error?.localizedDescription)")
                    }
                })
            }
        })
    }
    
    func removeContributor(user: User, fromPlaylist playlist: Playlist, completion:(success: Bool) -> Void) {
        
    }
    
    
}

