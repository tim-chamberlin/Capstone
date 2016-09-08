//
//  SpotifyUser.swift
//  A-Side
//
//  Created by Tim on 9/4/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import Foundation


class SpotifyUser {
    
    var displayName: String?
    var canonicalUserName: String?
    var imageURL: NSURL?
    
    init(displayName: String?, canonicalUserName: String?, imageURL: NSURL?) {
        self.displayName = displayName
        self.canonicalUserName = canonicalUserName
        self.imageURL = imageURL
    }
    
}