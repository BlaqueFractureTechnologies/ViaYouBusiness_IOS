//
//  DeletedVideosCollectionViewCell.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 22/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class DeletedVideosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    
    var cellDataDict: FeedDataArrayObject = FeedDataArrayObject([:])
    
    override func awakeFromNib() {
        
        videoImageView.image = nil
        
    }
    
    func configureCell(dataDict:FeedDataArrayObject) {
        
        self.videoImageView.image = dataDict.user.videoImage
        self.videoTitleLabel.text = dataDict.title
        //self.durationLabel.text = dataDict.user.duration //k*
        let interval = dataDict.duration //k*
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated //k*
        
        if (interval.count > 0 && Double(interval)?.isNaN == false) { //k*
            if let timeInterval = TimeInterval(interval) {
                if let formattedString = formatter.string(from: timeInterval) {
                    self.durationLabel.text = formattedString //k*
                    cellDataDict = dataDict
                }
            }
        }
        cellDataDict = dataDict
        
    }
}
