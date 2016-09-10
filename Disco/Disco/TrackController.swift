//
//  TrackController.swift
//  Disco
//
//  Created by Tim on 8/25/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import Foundation


class TrackController {
    
    static let spotifyBaseURL = NSURL(string: "https://api.spotify.com/v1")
    
    static func searchSpotifyForItemWithText(text: String, responseLimit: Int, filterByType type: String, completion: (items: (trackNames: [String], artists: [String], ids: [String])?, success: Bool) -> Void) {
        let searchBaseURL = spotifyBaseURL?.URLByAppendingPathComponent("search")
        guard let spotifySearchBaseURL = searchBaseURL else {
            print("Optional URL return nil")
            completion(items: nil, success: false)
            return
        }
        
        // Spotify Web API search documentation: https://developer.spotify.com/web-api/search-item/
        let urlParameters = ["q":text,
                             "limit":String(responseLimit),
                             "type":type]
        
        NetworkController.performRequestForURL(spotifySearchBaseURL, httpMethod: .Get, urlParameters: urlParameters) { (data, error) in
            if let data = data, jsonDictionary = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [String: AnyObject] {
                dispatch_async(dispatch_get_main_queue(), {
                    
                    guard let tracksDictionary = jsonDictionary["tracks"] as? [String: AnyObject], itemsDictionary = tracksDictionary["items"] as? [[String : AnyObject]] else {
                        print("Error formatting data")
                        completion(items: nil, success: false)
                        return
                    }
                    
                    let names = itemsDictionary.flatMap { $0["name"] as? String }
                    let ids = itemsDictionary.flatMap { $0["id"] as? String }
                    
                    let artists = itemsDictionary.flatMap { $0["artists"] as? [[String: AnyObject]] }
                    var artistsGroupedByTrack = [String]()
                    for artistDictionaryArray in artists {
                        var trackArtists = [String]()
                        for artistDictionary in artistDictionaryArray {
                            let artistName = artistDictionary["name"] as! String
                            trackArtists.append(artistName)
                        }
                        let trackArtistsString = trackArtists.joinWithSeparator(", ")
                        artistsGroupedByTrack.append(trackArtistsString)
                    }
                    completion(items: (names, artistsGroupedByTrack, ids), success: true)
                })
            }
        }
    }

    static func fetchTrackInfo(forTrackWithID spotifyID: String, completion:(track: Track?) -> Void) {
        let trackBaseURL = spotifyBaseURL?.URLByAppendingPathComponent("tracks").URLByAppendingPathComponent(spotifyID)
        guard let trackURL = trackBaseURL else {
            print("Optional URL return nil")
            completion(track: nil)
            return
        }
        
        NetworkController.performRequestForURL(trackURL, httpMethod: NetworkController.HTTPMethod.Get) { (data, error) in
            if let data = data, jsonDictionary = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [String: AnyObject] {
                let track = Track(spotifyDictionary: jsonDictionary)
                completion(track: track)
            } else {
                print("Error serializing JSON")
                completion(track: nil)
            }
        }
    }
    
    // MARK: - Vote Listener Methods
    
    static func attachVoteListener(forTrack track: Track, inPlaylist playlist: Playlist, completion: (newVoteCount: Int, success: Bool) -> Void) {
        // TODO: Will tracks have UIDs at this point?
        firebaseRef.child(Playlist.parentDirectory).child(playlist.uid).child(Playlist.kUpNext).child(track.firebaseUID).child(Track.kVoteCount).observeEventType(.Value, withBlock: { (snapshot) in
            guard let voteCount = snapshot.value as? Int else { return }
            completion(newVoteCount: voteCount, success: true)
        }) { (error) in
            //
        }
    }
    
    static func removeVoteListenerFromTrack(track: Track, inQueue queue: Playlist, completion: (() -> Void)? = nil) {
        firebaseRef.child(Playlist.parentDirectory).child(queue.uid).child(Playlist.kUpNext).child(track.firebaseUID).child(Track.kVoteCount).removeAllObservers()
    }
    
    // MARK: - Get Vote Status for User
    
    static func getVoteStatusForTrackWithID(trackID: String, inPlaylistWithID playlistID: String, ofType playlistType: PlaylistType, user: User, completion:(voteStatus: VoteType, success: Bool) -> Void) {
        firebaseRef.child(User.parentDirectory).child(user.FBID).child(playlistType.rawValue).child(playlistID).child(trackID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
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
    
    static func user(user: User, didVoteWithType voteType: VoteType, withVoteStatus voteStatus: VoteType, onTrack track: Track, inPlaylist playlist: Playlist, ofPlaylistType playlistType: PlaylistType, completion: (success: Bool) -> Void) {
        // get track's current votecount
        firebaseRef.child(Playlist.parentDirectory).child(playlist.uid).child(Playlist.kUpNext).child(track.firebaseUID).child(Track.kVoteCount).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
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
            firebaseRef.child(Playlist.parentDirectory).child(playlist.uid).child(Playlist.kUpNext).child(track.firebaseUID).child(Track.kVoteCount).setValue(voteCount, withCompletionBlock: { (error, _) in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    // set user's vote in the user model
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
    
    // MARK: - Helper Functions
    
    static func sortTracklistByVoteCount(trackList: [Track]) -> [Track] {
        let sortedTracks = trackList.sort { (a, b) -> Bool in
            return a.voteCount > b.voteCount
        }
        return sortedTracks
    }
}