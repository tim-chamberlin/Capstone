//
//  NewPlaylistViewController.swift
//  Disco
//
//  Created by Tim on 8/23/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class NewPlaylistViewController: UIViewController {

    @IBOutlet weak var playlistNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField()
        
    }
    
    func configureTextField() {
        let border = CALayer()
        let width = CGFloat(2.0)
//        border.borderColor = UIColor.darkGrayColor().CGColor
        border.borderColor = UIColor(red: 85/255.0, green: 85/255.0, blue: 85/255.0, alpha: 0.6).CGColor
        border.frame = CGRect(x: 0, y: playlistNameTextField.frame.size.height - width, width: playlistNameTextField.frame.size.width, height: playlistNameTextField.frame.size.height)
        
        border.borderWidth = width
        playlistNameTextField.layer.addSublayer(border)
        playlistNameTextField.layer.masksToBounds = true
    }

    
    @IBAction func createNewPlaylist(sender: AnyObject) {
        if let playlistName = playlistNameTextField.text where !playlistName.isEmpty {
            PlaylistController.sharedController.createPlaylist(playlistName, completion: { (success, playlist) in
                if success {
                    guard let playlist = playlist, currentUser = UserController.sharedController.currentUser else { return }
                    PlaylistController.sharedController.createPlaylistReferenceForUserID(playlist.uid, userID: currentUser.FBID, playlistType: .Hosting, completion: { (success) in
                        if success {
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                    })
                }
            })
        }
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
