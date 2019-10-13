//
//  ProfileDropdownTableViewCell.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 9/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class ProfileDropdownTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(dataArray:[String], index:Int) {
        self.titleLabel.text = "\(dataArray[index])\n***"
        
        var iconName = "DropDown_\(dataArray[index])"
        iconName = iconName.replacingOccurrences(of: " ", with: "_")
        self.iconView.image = UIImage(named: iconName)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
