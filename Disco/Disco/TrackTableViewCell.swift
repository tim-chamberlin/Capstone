//
//  TrackTableViewCell.swift
//  Disco
//
//  Created by Tim on 8/26/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class TrackTableViewCell: UITableViewCell {

    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    
    weak var delegate: TrackTableViewCellDelegate?
    
    var voteStatus: VoteType = .Neutral
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            self.selectionStyle = .None
        }
    }
    
    func updateCellWithTrack(track: Track) {
        self.trackLabel.text = track.name
        self.artistLabel.text = track.artist
        self.voteCountLabel.text = String(track.voteCount)
    }
    
    func updateCellWithVoteAction(voteType: VoteType) {
        switch voteType {
        case .Up:
            upVoteButton.setImage(UIImage(named: "UpVoteSelected"), forState: .Normal)
            downVoteButton.setImage(UIImage(named: "DownVoteUnselected"), forState: .Normal)
        case .Down:
            upVoteButton.setImage(UIImage(named: "UpVoteUnselected"), forState: .Normal)
            downVoteButton.setImage(UIImage(named: "DownVoteSelected"), forState: .Normal)
        case .Neutral:
            upVoteButton.setImage(UIImage(named: "UpVoteUnselected"), forState: .Normal)
            downVoteButton.setImage(UIImage(named: "DownVoteUnselected"), forState: .Normal)
        }
    }
    
    @IBAction func upVoteButtonTapped(sender: AnyObject) {
        switch self.voteStatus {
        case .Neutral, .Down:
            updateCellWithVoteAction(.Up)
            delegate?.didPressVoteButton(.Up)
            self.voteStatus = .Up
        case .Up:
            updateCellWithVoteAction(.Neutral)
            delegate?.didPressVoteButton(.Neutral)
            self.voteStatus = .Neutral
        }
    }
    
    @IBAction func downVoteButtonTapped(sender: AnyObject) {
        switch self.voteStatus {
        case .Neutral, .Up:
            updateCellWithVoteAction(.Down)
            delegate?.didPressVoteButton(.Down)
            self.voteStatus = .Down
        case .Down:
            updateCellWithVoteAction(.Neutral)
            delegate?.didPressVoteButton(.Neutral)
            self.voteStatus = .Neutral
        }
    }
}

enum VoteType {
    case Up
    case Down
    case Neutral
}

protocol TrackTableViewCellDelegate: class {
    func didPressVoteButton(voteType: VoteType)
}