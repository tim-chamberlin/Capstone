//
//  SpotifyUser.swift
//  A-Side
//
//  Created by Tim on 9/4/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import Foundation


class SpotifyUser {
    
    let displayName: String
    let imageURL: NSURL
    
    init(displayName: String, imageURL: NSURL) {
        self.displayName = displayName
        self.imageURL = imageURL
    }
    
}