//
//  MergeTagPopUpTableViewCell.swift
//  Promptchu
//
//  Created by Arya S on 20/09/19.
//  Copyright © 2019 AryaSreenivasan. All rights reserved.
//

import UIKit

class MergeTagPopUpTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var tickIcon: UIImageView!
    
    let profileImageUrlHeader:String = "https://dev-promptchu.s3.us-east-2.amazonaws.com/"
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
//    func configureCell(dataDict:UserShadowsArrayObject) {
//        nameLabel.text = dataDict.name
//        
//        let userIdString = dataDict._id
//        var profilePicUrlString = "\(profileImageUrlHeader)users/\(userIdString)/profile.jpg"
//        profilePicUrlString = profilePicUrlString.replacingOccurrences(of: " ", with: "%20")
//        JMImageCache.shared()?.image(for: URL(string: profilePicUrlString), completionBlock: { (image) in
//            self.profilePic.image = image
//        }, failureBlock: { (request, respsonse, error) in
//            
//        })
//        
//        if (dataDict.isSelectedForTag == true) {
//            tickIcon.backgroundColor = UIColor.red
//            tickIcon.alpha = 1.0
//        }else {
//            tickIcon.backgroundColor = UIColor.white
//            tickIcon.alpha = 0.5
//        }
//    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
