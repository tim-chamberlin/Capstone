//
//  FriendTableViewCell.swift
//  A-Side
//
//  Created by Tim on 9/3/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCellWithFriend() {
        
    }
    
}

protocol FriendCellDelegate {
    func friendCellTapped()
}