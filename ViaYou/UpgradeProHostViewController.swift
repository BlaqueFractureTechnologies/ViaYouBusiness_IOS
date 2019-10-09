//
//  UpgradeProHostViewController.swift
//  ViaYou
//
//  Created by Arya S on 09/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class UpgradeProHostViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func prevButtonClicked(_ sender: UIButton) {
        let parentVC = parent as! UpgradeAndSubscriptionBaseViewController
        parentVC.proVCNextAndPrevButtonsClicked(index: 0)
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        let parentVC = parent as! UpgradeAndSubscriptionBaseViewController
        parentVC.proVCNextAndPrevButtonsClicked(index: 1)
    }
    
}
