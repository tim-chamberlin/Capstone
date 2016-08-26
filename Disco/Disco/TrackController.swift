//
//  TrackController.swift
//  Disco
//
//  Created by Tim on 8/25/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import Foundation


class TrackController {
    
    static let spotifySearchBaseURL = NSURL(string: "https://api.spotify.com/v1/search")
    
    static func searchSpotifyForTrackWithText(text: String, responseLimit: String, filterByType type: String, completion: (tracks: [Track], success: Bool) -> Void) {
        guard let spotifySearchBaseURL = spotifySearchBaseURL else {
            print("Optional URL return nil")
            completion(tracks: [], success: false)
            return
        }
        let urlParameters = ["q":text,
                             "limit":responseLimit,
                             "type":type]
    
        NetworkController.performRequestForURL(spotifySearchBaseURL, httpMethod: .Get, urlParameters: urlParameters) { (data, error) in
            if let data = data, jsonDictionary = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [String: AnyObject] {
                
                guard let tracksDictionary = jsonDictionary["tracks"] as? [String: AnyObject], itemsDictionary = tracksDictionary["items"] as? [[String : AnyObject]] else {
                    print("Error formatting data")
                    completion(tracks: [], success: false)
                    return
                }
                let tracks = itemsDictionary.flatMap { Track(dictionary: $0) }
                completion(tracks: tracks, success: true)
            }
        }
    }
    
}