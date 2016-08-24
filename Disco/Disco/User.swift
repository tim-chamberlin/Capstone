//
//  User.swift
//  Disco
//
//  Created by Tim on 8/21/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import Foundation

struct User {
    
    static let parentDirectory = "users"
    
    static let kFBID = "id"
    static let kName = "name"
    static let kContributingPlaylists = "contributingPlaylists"
    static let kHostingPlaylists = "hostingPlaylist"
    
    let FBID: String
    let name: String
    var friends: [User] = []
//    var contributingPlaylists: [Playlist] = []
    var hostingPlaylists: [Playlist]?
    
    
    init(FBID: String, name: String){
        self.FBID = FBID
        self.name = name
    }
    
    init?(dictionary: [String:AnyObject]) {
        guard let FBID = dictionary[User.kFBID] as? String, name = dictionary[User.kName] as? String else { return nil }
        self.FBID = FBID
        self.name = name
    }
}