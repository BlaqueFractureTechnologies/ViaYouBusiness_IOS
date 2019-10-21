//
//  BecomeGrowthHostPopUpViewController.swift
//  ViaYou
//
//  Created by Arya S on 10/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

@objc protocol BecomeGrowthHostPopUpViewControllerDelegate{
    @objc optional func becomeGrowthHostPopUpVC_UpgradeAndSubscriptionBaseViewControllerButtonClicked()
    @objc optional func becomeGrowthHostPopUpVC_SubscriptionBaseViewControllerrButtonClicked()
}

class BecomeGrowthHostPopUpViewController: UIViewController {
    
    @IBOutlet weak var crownButton: UIButton!
    var delegate:BecomeGrowthHostPopUpViewControllerDelegate?
    @IBOutlet weak var tryGrowthButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        crownButton.layer.borderColor = UIColor.white.cgColor
        crownButton.layer.borderWidth = 5.0
        
        DispatchQueue.main.async {
            self.tryGrowthButton.addAppGradient()
        }
    }
    
    
    @IBAction func closeButtonClicked() {
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func goToUpgradeAndSubscriptionBaseViewControllerButtonClicked() {
        self.dismiss(animated: true) {
            self.delegate?.becomeGrowthHostPopUpVC_SubscriptionBaseViewControllerrButtonClicked!()
            
        }
    }
    
    @IBAction func goToSubscriptionBaseViewControllerrButtonClicked() {
        self.dismiss(animated: true) {
            self.delegate?.becomeGrowthHostPopUpVC_UpgradeAndSubscriptionBaseViewControllerButtonClicked!()
            
        }
    }
    
}
