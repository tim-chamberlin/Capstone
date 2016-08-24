//
//  Playlist.swift
//  Disco
//
//  Created by Tim on 8/23/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import Foundation

class Playlist {
    
    static let parentDirectory = "playlists"
    
    static let kPlaylistName = "name"
    static let kTrackList = "tracks"
    static let kContributorsList = "contributors"
    
    let uid: String
    let name: String
    var trackIDs: [String]
    var contributorIDs: [String]
    var contributors: [User] = []
    
    var isLive: Bool = false
    
    var jsonValue: [String: AnyObject] {
        return [Playlist.kPlaylistName:self.name, Playlist.kTrackList:self.trackIDs, Playlist.kContributorsList: self.contributorIDs]
    }
    
    init(uid: String, name: String, trackIDs: [String] = [], contributorIDs: [String] = [(UserController.sharedController.currentUser?.FBID)!]) {
        self.uid = uid
        self.name = name
        self.trackIDs = trackIDs
        self.contributorIDs = contributorIDs
    }
    
    init?(dictionary: [String: AnyObject], uid: String) {
        guard let name = dictionary[Playlist.kPlaylistName] as? String, contributorIDs = dictionary[Playlist.kContributorsList] as? [String] else {
            return nil
        }
        
        self.uid = uid
        self.name = name
        self.contributorIDs = contributorIDs
        
        // TrackIDs array might be empty in Firebase
        if let trackIDs = dictionary[Playlist.kTrackList] as? [String] {
            self.trackIDs = trackIDs
        } else {
            self.trackIDs = []
        }
    }    
}

enum PlaylistType: String {
    case Hosting = "hostingPlaylist"
    case Contributing = "contributingPlaylists"
}

