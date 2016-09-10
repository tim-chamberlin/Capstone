//
//  FriendTableViewCell.swift
//  A-Side
//
//  Created by Tim on 9/3/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

let friendTableViewCellHeight: CGFloat = 50

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var friendProfilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        friendProfilePicture.layer.masksToBounds = true
        friendProfilePicture.layer.cornerRadius = friendProfilePicture.frame.height/2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        if selected {
            self.selectionStyle = .None
        }
    }
    
    func updateCellWithFriend(facebookUser: FacebookUser) {
        self.nameLabel.text = facebookUser.name
        
        UserController.sharedController.getProfilePictureForUserWithID(facebookUser.fbid) { (profilePicture) in
            guard let profilePicture = profilePicture else { return }
            self.friendProfilePicture.image = profilePicture
        }
    }
    
}

protocol FriendCellDelegate {
    func friendCellTapped()
}