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
    static let kNowPlaying = "nowPlaying"
    static let kUpNext = "upNext"
    static let kHostID = "hostID"
    static let kContributorsList = "contributorIDs"
    
    let uid: String
    let name: String
    let hostID: String
    var trackUids: [String]

    var tracks: [Track] = []
    
    var upNext: [Track] = []
    var nowPlaying: Track?
    var isLive: Bool = false
    
    var contributorIDs: [String]
    var contributors: [User] = []
    
    var votesDictionary: [String: AnyObject] {
        var dictionary = [String:AnyObject]()
        for trackUid in self.trackUids {
            dictionary[trackUid] = 0
        }
        return dictionary
    }
    
    
    
    var jsonValue: [String: AnyObject] {
        return [Playlist.kPlaylistName:self.name, Playlist.kUpNext: self.upNext, Playlist.kHostID: self.hostID, Playlist.kContributorsList: self.contributorIDs]
    }
    
    init(uid: String, name: String, trackIDs: [String] = [], contributorIDs: [String] = [], hostID: String = (UserController.sharedController.currentUser?.FBID)!) {
        self.uid = uid
        self.name = name
        self.trackUids = trackIDs
        self.hostID = hostID
        self.contributorIDs = contributorIDs
    }
    
    init?(dictionary: [String: AnyObject], uid: String) {
        guard let name = dictionary[Playlist.kPlaylistName] as? String, hostID = dictionary[Playlist.kHostID] as? String else {
            return nil
        }
        
        self.uid = uid
        self.name = name
        self.hostID = hostID
        
        // There might not be any contributors
        if let contributorsDictionary = dictionary[Playlist.kContributorsList] as? [String:AnyObject] {
            self.contributorIDs = contributorsDictionary.flatMap { $0.0 }
        } else {
            self.contributorIDs = []
        }
        
        self.trackUids = []
        self.tracks = []
        
        self.nowPlaying = nil
        self.upNext = []
    }    
}

enum PlaylistType: String {
    case Hosting = "hostingPlaylists"
    case Contributing = "contributingPlaylists"
}

