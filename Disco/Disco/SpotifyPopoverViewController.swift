//
//  SpotifyPopoverViewController.swift
//  A-Side
//
//  Created by Tim on 9/5/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class SpotifyPopoverViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var label: UILabel!
    
    weak var delegate: SpotifyLogoutDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.setTitleColor(UIColor.goldColor(), forState: .Normal)
        okButton.setTitleColor(UIColor.goldColor(), forState: .Normal)
        label.textColor = .offWhiteColor()
        self.preferredContentSize = CGSizeMake(170, 90)
//        view.backgroundColor = .lightCharcoalColor()
    }

    @IBAction func okAction(sender: AnyObject) {
        // Logout of Spotify, dismiss view on completion
        delegate?.popoverViewDidLogoutSpotifyUser()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

protocol SpotifyLogoutDelegate: class {
    func popoverViewDidLogoutSpotifyUser()
}
