//
//  User.swift
//  Disco
//
//  Created by Tim on 8/21/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import Foundation

struct User {
    
    let FBID: String
    let name: String
    
    
    init(FBID: String, name: String){
        self.FBID = FBID
        self.name = name
    }
}