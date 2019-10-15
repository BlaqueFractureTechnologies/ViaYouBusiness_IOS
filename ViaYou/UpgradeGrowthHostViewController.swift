//
//  UpgradeGrowthHostViewController.swift
//  ViaYou
//
//  Created by Arya S on 09/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class UpgradeGrowthHostViewController: UIViewController {
    
    @IBOutlet weak var mostPopularLabelContainer: UIView!
    @IBOutlet weak var tryGrowthHostButton: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.mostPopularLabelContainer.addAppGradient()
            self.tryGrowthHostButton.addAppGradient()
        }
    }
    
    @IBAction func prevButtonClicked(_ sender: UIButton) {
        let parentVC = parent as! UpgradeAndSubscriptionBaseViewController
        parentVC.growthVCNextAndPrevButtonsClicked(index: 0)
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        let parentVC = parent as! UpgradeAndSubscriptionBaseViewController
        parentVC.growthVCNextAndPrevButtonsClicked(index: 1)
    }
    
}
