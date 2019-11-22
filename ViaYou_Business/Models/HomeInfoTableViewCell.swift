//
//  HomeInfoTableViewCell.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 9/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//
//
//  HomeInfoTableViewCell.swift
//  ViaYou
//
//  Created by Arya S on 07/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class HomeInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowIconHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.text = ""
        arrowIconHeightConstraint.constant = 0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
