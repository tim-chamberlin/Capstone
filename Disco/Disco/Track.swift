//
//  Track.swift
//  Disco
//
//  Created by Tim on 8/25/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import Foundation

class Track: Equatable {
    
    static let kSpotifyURI = "spotifyURI"
    static let kArtworkURL = "artworkURL"
    static let kPlaylistID = "playlistID"
    static let kVoteCount = "voteCount"
    static let kName = "name"
    static let kArtist = "artist"
    
    let firebaseUID: String
    let spotifyURI: String
    var artworkURL: String = ""
    var artwork: UIImage?
    var playlistID: String
    var voteCount: Int
    
    var currentUserVoteStatus: VoteType = .Neutral
    
    let name: String
    let artist: String
    
    var jsonValue: [String: AnyObject] {
        return [Track.kSpotifyURI: self.spotifyURI, Track.kPlaylistID: self.playlistID, Track.kArtworkURL: self.artworkURL, Track.kVoteCount: self.voteCount, Track.kName: self.name, Track.kArtist: self.artist]
    }
    
    init(firebaseUID: String, spotifyUID: String, spotifyURL: String, playlistID: String, voteCount: Int = 0, name: String = "", artist: String = "") {
        self.firebaseUID = firebaseUID
        self.spotifyURI = spotifyUID
        self.artworkURL = spotifyURL
        self.playlistID = playlistID
        self.voteCount = voteCount
        self.name = name
        self.artist = artist
    }
    
    // Init from Firebase
    init?(firebaseDictionary: [String: AnyObject], uid: String) {
        guard let spotifyUID = firebaseDictionary[Track.kSpotifyURI] as? String, artworkURL = firebaseDictionary[Track.kArtworkURL] as? String, playlistID = firebaseDictionary[Track.kPlaylistID] as? String, voteCount = firebaseDictionary[Track.kVoteCount] as? Int else { return nil }
        self.firebaseUID = uid
        self.artworkURL = artworkURL
        self.spotifyURI = spotifyUID
        self.playlistID = playlistID
        self.voteCount = voteCount
        
        
        if let name = firebaseDictionary[Track.kName] as? String, artist = firebaseDictionary[Track.kArtist] as? String {
            self.name = name
            self.artist = artist
        } else {
            self.name = ""
            self.artist = ""
        }
    }
    
    init?(withSimpleSpotifyDictionary: [String:AnyObject]) {
        guard let spotifyURI = withSimpleSpotifyDictionary["uri"] as? String, trackName = withSimpleSpotifyDictionary["name"] as? String else { return nil }
        
        guard let artistsInfo = withSimpleSpotifyDictionary["artists"] as? [[String: AnyObject]] else { return nil }
        let artistNamesArray = artistsInfo.flatMap({ $0["name"] as? String })
        let artistNames = artistNamesArray.joinWithSeparator(", ")
        
        self.spotifyURI = spotifyURI
        self.name = trackName
        self.artist = artistNames
        
        self.firebaseUID = ""
        self.playlistID = ""
        self.voteCount = 0
        self.currentUserVoteStatus = .Neutral
    }
    
    // Init from Spotify API
    init?(spotifyDictionary: [String:AnyObject]) {
        guard let spotifyURI = spotifyDictionary["uri"] as? String, trackName = spotifyDictionary["name"] as? String else { return nil }
        
        guard let artistsInfo = spotifyDictionary["artists"] as? [[String: AnyObject]] else { return nil }
        let artistNamesArray = artistsInfo.flatMap({ $0["name"] as? String })
        let artistNames = artistNamesArray.joinWithSeparator(", ")
        
        
        // get album artwork url
        if let albumDictionary = spotifyDictionary["album"] as? [String: AnyObject], imageDictionaryArrays = albumDictionary["images"] as? [[String: AnyObject]] {
            let imageDictionary = imageDictionaryArrays[1]
            if let imageURL = imageDictionary["url"] as? String {
                self.artworkURL = imageURL
            }
        }
        
        self.spotifyURI = spotifyURI
        self.name = trackName
        self.artist = artistNames
        
        self.firebaseUID = ""
        self.playlistID = ""
        self.voteCount = 0
        self.currentUserVoteStatus = .Neutral
    }
}


func == (lhs: Track, rhs: Track) -> Bool {
    return lhs.firebaseUID == rhs.firebaseUID
}
