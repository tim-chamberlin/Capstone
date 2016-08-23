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
    
    let uid: String
    let name: String
    var trackIDs: [String]
    
    var isLive: Bool = false
    
    init(uid: String, name: String, trackIDs: [String] = []) {
        self.uid = uid
        self.name = name
        self.trackIDs = trackIDs
    }
    
}