//
//  TrackController.swift
//  Disco
//
//  Created by Tim on 8/25/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import Foundation


class TrackController {
    
    // TODO: Do I need a singleton for this?
    static let sharedController = TrackController()
    static let spotifySearchBaseURL = NSURL(string: "https://api.spotify.com/v1/search")
    
    static func searchSpotifyForTrackWithText(text: String, responseLimit: String, filterByType type: String, completion: (tracks: [Track], success: Bool) -> Void) {
        guard let spotifySearchBaseURL = spotifySearchBaseURL else {
            print("Optional URL return nil")
            completion(tracks: [], success: false)
            return
        }
        
        // Spotify Web API search documentation: https://developer.spotify.com/web-api/search-item/
        let urlParameters = ["q":text,
                             "limit":responseLimit,
                             "type":type]
        
        NetworkController.performRequestForURL(spotifySearchBaseURL, httpMethod: .Get, urlParameters: urlParameters) { (data, error) in
            if let data = data, jsonDictionary = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [String: AnyObject] {
                dispatch_async(dispatch_get_main_queue(), {
                    guard let tracksDictionary = jsonDictionary["tracks"] as? [String: AnyObject], itemsDictionary = tracksDictionary["items"] as? [[String : AnyObject]] else {
                        print("Error formatting data")
                        completion(tracks: [], success: false)
                        return
                    }
                    let tracks = itemsDictionary.flatMap { Track(spotifyDictionary: $0) }
                    completion(tracks: tracks, success: true)
                })
            }
        }
    }
    
    
    func attachVoteListener(forTrack track: Track, inPlaylist playlist: Playlist, completion: (newVoteCount: Int, success: Bool) -> Void) {
        // TODO: Will tracks have UIDs at this point?
        firebaseRef.child(Playlist.parentDirectory).child(playlist.uid).child(Playlist.kTrackList).child(track.firebaseUID).child(Track.kVoteCount).observeEventType(.Value, withBlock: { (snapshot) in
            guard let voteCount = snapshot.value as? Int else { return }
            completion(newVoteCount: voteCount, success: true)
        }) { (error) in
            //
        }
    }
    
    func getVoteStatusForTrackWithID(trackID: String, inPlaylistWithID playlistID: String, user: User, completion:(voteStatus: VoteType, success: Bool) -> Void) {
        firebaseRef.child(User.parentDirectory).child(user.FBID).child(User.kContributingPlaylists).child(playlistID).child(trackID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            guard let voteStatus = snapshot.value as? Int else {
                completion(voteStatus: .Neutral, success: true)
                return
            }
            switch voteStatus {
            case -1:
                completion(voteStatus: .Down, success: true)
            case 0:
                completion(voteStatus: .Neutral, success: true)
            case 1:
                completion(voteStatus: .Up, success: true)
            default:
                break
            }
        }) { (error) in
            //
        }
    }
    
    
    func user(user: User, didVoteWithType voteType: VoteType, withVoteStatus voteStatus: VoteType, onTrack track: Track, inPlaylist playlist: Playlist, ofPlaylistType playlistType: PlaylistType, completion: (success: Bool) -> Void) {
        // get track's current votecount
        firebaseRef.child(Playlist.parentDirectory).child(playlist.uid).child(Playlist.kTrackList).child(track.firebaseUID).child(Track.kVoteCount).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            guard var voteCount = snapshot.value as? Int else { return }
            
            switch voteStatus {
            case .Up:
                switch voteType {
                case .Up: break
                case .Down: voteCount -= 2
                case .Neutral: voteCount -= 1
                }
            case .Down:
                switch voteType {
                case .Up: voteCount += 2
                case .Down: break
                case .Neutral: voteCount += 1
                }
            case .Neutral:
                switch voteType {
                case .Up: voteCount += 1
                case .Down: voteCount -= 1
                case .Neutral: break
                }
            }
            
            // set track's votecount in playlist model
            firebaseRef.child(Playlist.parentDirectory).child(playlist.uid).child(Playlist.kTrackList).child(track.firebaseUID).child(Track.kVoteCount).setValue(voteCount, withCompletionBlock: { (error, _) in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    switch voteType {
                    case .Up:
                        firebaseRef.child(User.parentDirectory).child(user.FBID).child(playlistType.rawValue).child(playlist.uid).child(track.firebaseUID).setValue(1)
                    case .Down:
                        firebaseRef.child(User.parentDirectory).child(user.FBID).child(playlistType.rawValue).child(playlist.uid).child(track.firebaseUID).setValue(-1)
                    case .Neutral:
                        firebaseRef.child(User.parentDirectory).child(user.FBID).child(playlistType.rawValue).child(playlist.uid).child(track.firebaseUID).setValue(0)
                    }
                }
            })
        }) { (error) in
            //
        }
    }
}