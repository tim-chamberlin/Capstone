//
//  NowPlayingTableViewCell.swift
//  Disco
//
//  Created by Tim on 9/2/16.
//  Copyright © 2016 Tim Chamberlin. All rights reserved.
//

import UIKit

class NowPlayingTableViewCell: UITableViewCell {

    @IBOutlet weak var albumArtworkImage: UIImageView!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var voteCountLabel: UILabel!
    
    weak var delegate: NowPlayingTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .charcoalColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            self.selectionStyle = .None
        }
    }
    
    func updateCellWithTrack(track: Track) {
        self.trackLabel.text = track.name
        self.artistLabel.text = track.artist
        if track.voteCount == 1 {
            voteCountLabel.text = "1 vote"
        } else {
            voteCountLabel.text = "\(track.voteCount) votes"
        }
        getAlbumArtworkForTrack(track)
    }
    
    func getAlbumArtworkForTrack(track: Track) {
        guard let imageURL = NSURL(string: track.artworkURL) else {
            return
        }
        ImageController.getImageFromURL(imageURL) { (image, success) in
            self.albumArtworkImage.image = image
            track.artwork = image
        }
    }
}

protocol NowPlayingTableViewCellDelegate: class {
    func trackDidChangePlaybackPosition()
}
