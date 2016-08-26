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
    
    let spotifyURI: String
    var playlistID: String
    var voteCount: Int
    
    let name: String
    let artist: String
    
    var jsonValue: [String: AnyObject] {
        return [Track.kSpotifyURI: self.spotifyURI, Track.kPlaylistID: self.playlistID, Track.kVoteCount: self.voteCount, Track.kName: self.name, Track.kArtist: self.artist]
    }
    
    init(spotifyID: String, playlistID: String, voteCount: Int = 0, name: String = "", artist: String = "") {
        self.spotifyURI = spotifyID
        self.playlistID = playlistID
        self.voteCount = voteCount
        self.name = name
        self.artist = artist
    }
    
    
    // Init from Firebase
    init?(dictionary: [String: AnyObject], uid: String) {
        guard let spotifyID = dictionary[Track.kSpotifyURI] as? String, playlistID = dictionary[Track.kPlaylistID] as? String, voteCount = dictionary[Track.kVoteCount] as? Int else { return nil }
        
        self.spotifyURI = spotifyID
        self.playlistID = playlistID
        self.voteCount = voteCount
        
        
        if let name = dictionary[Track.kName] as? String, artist = dictionary[Track.kArtist] as? String {
            self.name = name
            self.artist = artist
        } else {
            self.name = ""
            self.artist = ""
        }
    }
    
    // Init from Spotify API
    init?(dictionary: [String:AnyObject]) {
        guard let spotifyURI = dictionary["uri"] as? String, trackName = dictionary["name"] as? String else { return nil }
        
        guard let artistsInfo = dictionary["artists"] as? [[String: AnyObject]] else { return nil }
        let artistNames = artistsInfo.flatMap({ $0["name"] as? String })
        let test = artistNames.joinWithSeparator(", ")
        
        self.spotifyURI = spotifyURI
        self.name = trackName
        self.artist = test
        
        self.playlistID = ""
        self.voteCount = 0
    }
     
    
    
    
}
