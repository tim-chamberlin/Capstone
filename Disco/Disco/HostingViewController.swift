//
//  HostingViewController.swift
//  Disco
//
//  Created by Tim on 8/22/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit



class HostingViewController: UIViewController {
    
    var streamingVC: StreamingViewController!
    
    @IBOutlet weak var streamingContainerView: UIView!
    @IBOutlet weak var spotifyLoginView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedStreamingController" {
            streamingVC = segue.destinationViewController as? StreamingViewController
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func startQueue(sender: AnyObject) {
        
    }
}