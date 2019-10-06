//
//  ContactsTableViewCell.swift
//  ViaYou
//
//  Created by Arya S on 04/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    var documentInteractionController: UIDocumentInteractionController = UIDocumentInteractionController()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(dataDict:PhoneContact) {
        nameLabel.text = dataDict.fullName
        
        var phoneNumbers = ""
        for i in 0..<dataDict.phoneNumbers.count {
            phoneNumbers = "\(phoneNumbers) \(dataDict.phoneNumbers[i])"
            if(i != (dataDict.phoneNumbers.count - 1)) {
                phoneNumbers = "\(phoneNumbers), "
            }
        }
        numberLabel.text = phoneNumbers
        
        profilePicView.image = UIImage(named: "defaultProfilePic")
        if (dataDict.isProfilePicAvailable == true) {
            profilePicView.image = dataDict.profilePic
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
