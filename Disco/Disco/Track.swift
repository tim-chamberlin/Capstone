//
//  Track.swift
//  Disco
//
//  Created by Tim on 8/25/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import Foundation

class Track {
    
    static let kSpotifyID = "spotifyID"
    static let kPlaylistID = "playlistID"
    static let kVoteCount = "voteCount"
    static let kName = "name"
    static let kArtist = "artist"
    
    let spotifyID: String
    let playlistID: String
    var voteCount: Int
    
    let name: String
    let artist: String
    
    var jsonValue: [String: AnyObject] {
        return [Track.kSpotifyID: self.spotifyID, Track.kPlaylistID: self.playlistID, Track.kVoteCount: self.voteCount, Track.kName: self.name, Track.kArtist: self.artist]
    }
    
    init(spotifyID: String, playlistID: String, voteCount: Int = 0, name: String = "", artist: String = "") {
        self.spotifyID = spotifyID
        self.playlistID = playlistID
        self.voteCount = voteCount
        self.name = name
        self.artist = artist
    }
    
    init?(dictionary: [String: AnyObject], playlistID: String) {
        guard let spotifyID = dictionary[Track.kSpotifyID] as? String, playlistID = dictionary[Track.kPlaylistID] as? String, voteCount = dictionary[Track.kVoteCount] as? Int else { return nil }
        
        self.spotifyID = spotifyID
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
}