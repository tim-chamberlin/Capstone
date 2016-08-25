//
//  TrackListViewController.swift
//  Disco
//
//  Created by Tim on 8/25/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class TrackListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var playlist: Playlist!
//    var tracks: [Track] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = playlist.name
        print("Playlist: \(playlist.name)")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist.trackIDs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("trackCell", forIndexPath: indexPath)
        
        
        
        
        return cell
    }
    
}
