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
    @IBOutlet weak var songProgressView: UIProgressView!
    
    weak var delegate: NowPlayingTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Make progress bar size of cell
        self.sendSubviewToBack(songProgressView)
        self.bringSubviewToFront(albumArtworkImage)
        self.bringSubviewToFront(trackLabel)
        self.bringSubviewToFront(artistLabel)
        songProgressView.transform = CGAffineTransformScale(songProgressView.transform, 1, 50)
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
        getAlbumArtworkForTrack(track)
    }
    
    func getAlbumArtworkForTrack(track: Track) {
        guard let imageURL = NSURL(string: track.artworkURL) else {
            return
        }
        ImageController.getImageFromURL(imageURL) { (image, success) in
            self.albumArtworkImage.image = image
        }
    }
}

protocol NowPlayingTableViewCellDelegate: class {
    func trackDidChangePlaybackPosition()
}
