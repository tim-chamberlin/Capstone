//
//  SpotifyStreamingController.swift
//  Disco
//
//  Created by Tim on 8/30/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import Foundation


class SpotifyStreamingController {
    
    static func toggleIsPlaying(isPlaying: Bool, forQueue queue: Playlist, completion: (isPlaying: Bool) -> Void) {
        if isPlaying {
            spotifyPlayer.setIsPlaying(false, callback: { (error) in
                if error != nil {
                    print(error)
                    completion(isPlaying: true)
                } else {
                    PlaylistController.sharedController.setIsLive(false, forQueue: queue, completion: { 
                        //
                    })
                    completion(isPlaying: false)
                }
            })
        } else {
            spotifyPlayer.setIsPlaying(true, callback: { (error) in
                if error != nil {
                    print(error)
                    completion(isPlaying: false)
                } else {
                    PlaylistController.sharedController.setIsLive(true, forQueue: queue, completion: {
                        //
                    })
                    completion(isPlaying: true)
                }
            })
        }
    }
    
    static func initializePlayerWithURI(spotifyURI: String) {
        if let player = spotifyPlayer {
            player.playSpotifyURI(spotifyURI, startingWithIndex: 0, startingWithPosition: 0, callback: { (error) in
                if error != nil {
                    print("Error playing track")
                } else {
                    print("Success")
                    spotifyPlayer.setIsPlaying(false, callback: { (error) in
                        if error != nil {
                            print(error)
                        }
                    })
                }
            })
        }
    }

    static func manuallySwitchToNextSong(nowPlaying: Track?, upNext: Track?, completion: (nowPlaying: Track?) -> Void) {
        spotifyPlayer.setIsPlaying(false, callback: { (error) in
            if error == nil {
                spotifyPlayer.playSpotifyURI(upNext?.spotifyURI, startingWithIndex: 0, startingWithPosition: 0, callback: { (error) in
                    if error == nil {
                        print("Started playing next track")
                        completion(nowPlaying: nowPlaying)
                    }
                })
            }
        })
    }
}

