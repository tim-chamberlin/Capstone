//
//  PlaylistViewController.swift
//  Disco
//
//  Created by Tim on 8/23/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class PlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var playlistTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = playlistTableView.dequeueReusableCellWithIdentifier("trackCell", forIndexPath: indexPath)
        
        return cell
    }
    

    @IBAction func requestSongTapped(sender: AnyObject) {
        
    }
}
