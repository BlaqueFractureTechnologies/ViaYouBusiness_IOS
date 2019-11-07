//
//  LibraryFeedsCollectionViewCell.swift
//  ViaYou
//
//  Created by Arya S on 29/09/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class LibraryFeedsCollectionViewCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var infoTableView: UITableView!
    @IBOutlet weak var infoSliderCloseButton: UIButton!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var infoPopUpHeight: NSLayoutConstraint!
    @IBOutlet weak var deleteVideoButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    
    var cellDataDict: FeedDataArrayObject = FeedDataArrayObject([:])
    
    override func awakeFromNib() {
        infoTableView.delegate = self
        infoTableView.dataSource = self
        videoImageView.image = nil
        
        infoTableView.estimatedRowHeight = 83.0
        infoTableView.rowHeight = UITableView.automaticDimension
        
    }
    
    func configureCell(dataDict:FeedDataArrayObject) {
        if (dataDict.isInfoPopUpDisplaying == false) {
            self.infoPopUpHeight.constant = 0
    }else {
            UIView.animate(withDuration: 0.4) {
                self.infoPopUpHeight.constant = 170
                self.layoutIfNeeded()
            }
        }
        self.videoImageView.image = dataDict.user.videoImage
        self.videoTitleLabel.text = dataDict.title
        // time calc starts
        let interval = dataDict.user.duration
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .short
        
        let formattedString = formatter.string(from: TimeInterval(interval) ?? 1.0)!
        print(formattedString)
        self.durationLabel.text = formattedString
        //time calc ends
      //  self.durationLabel.text = dataDict.user.duration
        cellDataDict = dataDict
        infoTableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeInfoTableViewCell", for: indexPath) as! HomeInfoTableViewCell
        if (indexPath.row == 0) {
            cell.titleLabel.text = cellDataDict.fileName
            cell.arrowIconHeightConstraint.constant = 15
        }else if (indexPath.row == 1) {
            cell.titleLabel.text = cellDataDict.createdDateTime.getReadableDateString()
            cell.arrowIconHeightConstraint.constant = 15
        }else {
            cell.titleLabel.text = cellDataDict.videoFileSize
            cell.arrowIconHeightConstraint.constant = 15
        }
        return cell
    }
    
    
    
    
}

