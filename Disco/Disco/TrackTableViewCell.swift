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
    @IBOutlet weak var votingStackView: UIStackView!
    
    weak var delegate: TrackTableViewCellDelegate?
    
    var track: Track?
    var voteStatus: VoteType = .Neutral
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            self.selectionStyle = .None
        }
    }
    
    func setupView() {
        // Label colors
        trackLabel.textColor = UIColor.offWhiteColor()
        artistLabel.textColor = UIColor.offWhiteColor()
        voteCountLabel.textColor = UIColor.deepBlueColor()
        
        // Label fonts
        trackLabel.font = UIFont.largeLabelFont()
        artistLabel.font = UIFont.mediumLabelFont()
        voteCountLabel.font = UIFont.largeLabelFont()
    }
    
    func updateCellWithTrack(track: Track) {
        self.trackLabel.text = track.name
        self.artistLabel.text = track.artist
        self.voteCountLabel.text = String(track.voteCount)
        
        updateCellWithVoteType(track.currentUserVoteStatus)
    }
    
    func updateCellWithVoteType(voteType: VoteType) {
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
            updateCellWithVoteType(.Up)
            delegate?.didPressVoteButton(self, voteType: .Up)
            track?.currentUserVoteStatus = .Up
        case .Up:
            updateCellWithVoteType(.Neutral)
            delegate?.didPressVoteButton(self, voteType: .Neutral)
            track?.currentUserVoteStatus = .Neutral
        }
    }
    
    @IBAction func downVoteButtonTapped(sender: AnyObject) {
        switch self.voteStatus {
        case .Neutral, .Up:
            updateCellWithVoteType(.Down)
            delegate?.didPressVoteButton(self, voteType: .Down)
            track?.currentUserVoteStatus = .Down
        case .Down:
            updateCellWithVoteType(.Neutral)
            delegate?.didPressVoteButton(self, voteType: .Neutral)
            track?.currentUserVoteStatus = .Neutral
        }
    }
}

enum VoteType {
    case Up
    case Down
    case Neutral
}

protocol TrackTableViewCellDelegate: class {
    func didPressVoteButton(sender: TrackTableViewCell, voteType: VoteType)
}