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
    @IBOutlet weak var inviteButtonWidthConstraints: NSLayoutConstraint!
    var documentInteractionController: UIDocumentInteractionController = UIDocumentInteractionController()
    @IBOutlet weak var radioButton: UIButton!
    @IBOutlet weak var radioButtonWidthConstraints: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(dataDict:PhoneContact) {
        let boolVal = UserDefaults.standard.bool(forKey: "isTappedFromSingleVideo")
        if boolVal == true {
            inviteButton.titleLabel?.text = "Send"
        }
        else {
            inviteButton.titleLabel?.text = "Invite"
        }
        
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
        
        if (dataDict.isSelectedForShare == true) {
            radioButton.setBackgroundImage(UIImage(named: "radio_ON"), for: .normal)
        }else {
            radioButton.setBackgroundImage(UIImage(named: "radio_OFF"), for: .normal)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
