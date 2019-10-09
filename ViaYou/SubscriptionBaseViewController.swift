//
//  SubscriptionBaseViewController.swift
//  ViaYou
//
//  Created by Arya S on 10/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class SubscriptionBaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func upgrageButtonClicked() {
        navigationController?.popToViewController(ofClass: UpgradeAndSubscriptionBaseViewController.self, animated: true)
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        navigationController?.popViewControllers(viewsToPop: 2)
    }
    
}
