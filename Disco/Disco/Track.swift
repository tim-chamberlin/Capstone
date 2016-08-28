//
//  Track.swift
//  Disco
//
//  Created by Tim on 8/25/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import Foundation

class Track {
    
    static let kSpotifyURI = "spotifyURI"
    static let kPlaylistID = "playlistID"
    static let kVoteCount = "voteCount"
    static let kName = "name"
    static let kArtist = "artist"
    
    let firebaseUID: String
    let spotifyURI: String
    var playlistID: String
    var voteCount: Int
    
    var currentUserVoteStatus: VoteType = .Neutral
    
    let name: String
    let artist: String
    
    var jsonValue: [String: AnyObject] {
        return [Track.kSpotifyURI: self.spotifyURI, Track.kPlaylistID: self.playlistID, Track.kVoteCount: self.voteCount, Track.kName: self.name, Track.kArtist: self.artist]
    }
    
    init(firebaseUID: String, spotifyID: String, playlistID: String, voteCount: Int = 0, name: String = "", artist: String = "") {
        self.firebaseUID = firebaseUID
        self.spotifyURI = spotifyID
        self.playlistID = playlistID
        self.voteCount = voteCount
        self.name = name
        self.artist = artist
    }
    
    // Init from Firebase
    init?(firebaseDictionary: [String: AnyObject], uid: String) {
        guard let spotifyID = firebaseDictionary[Track.kSpotifyURI] as? String, playlistID = firebaseDictionary[Track.kPlaylistID] as? String, voteCount = firebaseDictionary[Track.kVoteCount] as? Int else { return nil }
        self.firebaseUID = uid
        self.spotifyURI = spotifyID
        self.playlistID = playlistID
        self.voteCount = voteCount
        
        
        if let name = firebaseDictionary[Track.kName] as? String, artist = firebaseDictionary[Track.kArtist] as? String {
            self.name = name
            self.artist = artist
        } else {
            self.name = ""
            self.artist = ""
        }
        
        // Get current user's vote on the track
        TrackController.sharedController.getVoteStatusForTrackWithID(firebaseUID, inPlaylistWithID: playlistID, user: UserController.sharedController.currentUser!) { (voteStatus, success) in
            if success {
                self.currentUserVoteStatus = voteStatus
            } else {
                self.currentUserVoteStatus = .Neutral
            }
        }
    }
    
    // Init from Spotify API
    init?(spotifyDictionary: [String:AnyObject]) {
        guard let spotifyURI = spotifyDictionary["uri"] as? String, trackName = spotifyDictionary["name"] as? String else { return nil }
        
        guard let artistsInfo = spotifyDictionary["artists"] as? [[String: AnyObject]] else { return nil }
        let artistNames = artistsInfo.flatMap({ $0["name"] as? String })
        let test = artistNames.joinWithSeparator(", ")
        
        self.spotifyURI = spotifyURI
        self.name = trackName
        self.artist = test
        
        self.firebaseUID = ""
        self.playlistID = ""
        self.voteCount = 0
        self.currentUserVoteStatus = .Neutral
    }
     
    
    
    
}
