//
//  FacebookUser.swift
//  A-Side
//
//  Created by Tim on 9/9/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import Foundation

class FacebookUser: Equatable {
    
    let name: String
    let fbid: String
    
    var image: UIImage?
    
    init(name: String, fbid: String) {
        self.name = name
        self.fbid = fbid
    }
    
    init?(dictionary: [String: AnyObject]) {
        guard let fbid = dictionary["id"] as? String, name = dictionary["name"] as? String else { return nil }
        self.fbid = fbid
        self.name = name
    }
    
}

func == (lhs: FacebookUser, rhs: FacebookUser) -> Bool {
    return lhs.fbid == rhs.fbid
}