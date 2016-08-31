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
        if let player = spotifyPlayer {
            player.playSpotifyURI(spotifyURI, startingWithIndex: 0, startingWithPosition: 0, callback: { (error) in
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
            })
        }
    }
    
    static func addNextSongToQueue(upNext: Track, completion: () -> Void) {
        spotifyPlayer.queueSpotifyURI(upNext.spotifyURI) { (error) in
            if error != nil {
                print(error)
            }
            completion()
        }
    }
}

