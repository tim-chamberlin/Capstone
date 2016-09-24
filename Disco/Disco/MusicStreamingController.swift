//
//  MusicStreamingController.swift
//  Disco
//
//  Created by Tim on 8/30/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import Foundation
import MediaPlayer

class MusicStreamingController {
    
    // Allows for changing playback from lock screen
    static func initializeMPRemoteCommandCenterForQueue(queue: Playlist) {
        
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        let rcc = MPRemoteCommandCenter.sharedCommandCenter()
        
        rcc.playCommand.enabled = true
        rcc.playCommand.addTargetWithHandler { (event) -> MPRemoteCommandHandlerStatus in
            spotifyPlayer.setIsPlaying(!spotifyPlayer.playbackState.isPlaying, callback: { (error) in
                
            })
            return .Success
        }
        
        rcc.pauseCommand.enabled = true
        rcc.pauseCommand.addTargetWithHandler { (event) -> MPRemoteCommandHandlerStatus in
            spotifyPlayer.setIsPlaying(!spotifyPlayer.playbackState.isPlaying, callback: { (error) in
                
            })
            return .Success
        }
        
        rcc.nextTrackCommand.enabled = true
        rcc.nextTrackCommand.addTargetWithHandler { (event) -> MPRemoteCommandHandlerStatus in
            MusicStreamingController.skipToNextTrack(inQueue: queue, completion: { 
                //
            })
            return .Success
        }
    }
    
    static func setMPNowPlayingInfoCenterForTrack(track: Track?) {
        guard let track = track else { return }
        
        var trackInfo = [String: AnyObject]()
        
        trackInfo = [MPMediaItemPropertyTitle:track.name, MPMediaItemPropertyArtist:track.artist, MPNowPlayingInfoPropertyElapsedPlaybackTime: spotifyPlayer.playbackState.position]
        
        // Check for artwork
        if let artwork = track.artwork {
            let mediaArtworkImage = MPMediaItemArtwork(image: artwork)
            trackInfo[MPMediaItemPropertyArtwork] = mediaArtworkImage
        }
        
        // Check for duration
        if let trackDuration = spotifyPlayer.metadata.currentTrack?.duration {
            trackInfo[MPMediaItemPropertyPlaybackDuration] = trackDuration
        }
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = trackInfo
    }
    
    // MARK: Setup spotifyPlayer for Streaming
    
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
    
    // MARK: - Play/Pause
    
    static func play(queue: Playlist) {
        spotifyPlayer.setIsPlaying(true) { (error) in
            if error == nil {
                PlaylistController.sharedController.setIsLive(true, forQueue: queue, completion: nil)
            }
        }
    }
    
    static func pause(queue: Playlist) {
        spotifyPlayer.setIsPlaying(false) { (error) in
            if error == nil {
                PlaylistController.sharedController.setIsLive(false, forQueue: queue, completion: nil)
            }
        }
    }
    
    // Toggle play/pause
    
    static func toggleIsPlaying(forQueue queue: Playlist, completion: () -> Void) {
        spotifyPlayer.setIsPlaying(!spotifyPlayer.playbackState.isPlaying, callback: nil)
        
        if spotifyPlayer.playbackState.isPlaying {
            PlaylistController.sharedController.setIsLive(false, forQueue: queue, completion: nil)
        } else if !spotifyPlayer.playbackState.isPlaying {
            PlaylistController.sharedController.setIsLive(true, forQueue: queue, completion: nil)
        }
    }
    
    
    // MARK: Skip to next track
    
    // Delete track from playlist in Firebase, set playing to false, set next playing track, popQueue, set player with new nowPlaying
    static func skipToNextTrack(inQueue queue: Playlist, completion:() -> Void) {
        if !queue.upNext.isEmpty {
            PlaylistController.sharedController.changeQueueInFirebase(queue, oldNowPlaying: queue.nowPlaying, newNowPlaying: queue.upNext[0], completion: { (newNowPlaying) in
                spotifyPlayer.playSpotifyURI(newNowPlaying?.spotifyURI, startingWithIndex: 0, startingWithPosition: 0, callback: { (error) in
                    if error == nil {
                        print("Started playing \(newNowPlaying?.name)")
                        dispatch_async(dispatch_get_main_queue(), {
                            completion()
                        })
                    }
                })
            })
        } else { // there are no songs in the queue
            PlaylistController.sharedController.changeQueueInFirebase(queue, oldNowPlaying: queue.nowPlaying, newNowPlaying: nil, completion: { (newNowPlaying) in
                // stop playing
                spotifyPlayer.skipNext({ (error) in
                    if error != nil {
                        print(error.localizedDescription)
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            PlaylistController.sharedController.setIsLive(false, forQueue: queue, completion: nil)
                            completion()
                        })
                    }
                })
            })
        }
    }
}

