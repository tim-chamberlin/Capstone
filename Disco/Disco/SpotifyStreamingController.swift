//
//  SpotifyStreamingController.swift
//  Disco
//
//  Created by Tim on 8/30/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import Foundation


class SpotifyStreamingController {
    
    static func toggleIsPlaying(isPlaying: Bool, completion: (isPlaying: Bool) -> Void) {
        if isPlaying {
            spotifyPlayer.setIsPlaying(false, callback: { (error) in
                if error != nil {
                    print(error)
                    completion(isPlaying: true)
                } else {
                    completion(isPlaying: false)
                }
            })
        } else {
            spotifyPlayer.setIsPlaying(true, callback: { (error) in
                if error != nil {
                    print(error)
                    completion(isPlaying: false)
                } else {
                    completion(isPlaying: true)
                }
            })
        }
    }
    
    static func playSongWithURI(spotifyURI: String) {
        let url = NSURL(string: spotifyURI)
        if let player = spotifyPlayer {
            player.playURI(url, startingWithIndex: 0) { (error) in
                if error != nil {
                    print("Error playing track")
                } else {
                    print("Success")
                    //                    self.addNextSongToQueue()
                    spotifyPlayer.setIsPlaying(false, callback: { (error) in
                        if error != nil {
                            print(error)
                        }
                    })
                }
            }
        }
    }
    
    static func addNextSongToQueue(upNext: Track) {
        guard let spotifyURI = NSURL(string: upNext.spotifyURI) else { return }
        spotifyPlayer.queueURI(spotifyURI, callback: { (error) in
            if error != nil {
                print(error)
            }
        })
    }
}

