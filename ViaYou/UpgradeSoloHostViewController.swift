//
//  UpgradeSoloHostViewController.swift
//  ViaYou
//
//  Created by Arya S on 09/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit
import Stripe

class UpgradeSoloHostViewController: UIViewController {
    @IBOutlet weak var trySoloHostButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup payment card text field
        
        
        // Add payment card text field to view
        //  view.addSubview(paymentCardTextField)
        
    }
    //    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
    //        // Toggle buy button state
    //        trySoloHostButton.isEnabled = textField.isValid
    //    }
    @IBAction func prevButtonClicked(_ sender: UIButton) {
        let parentVC = parent as! UpgradeAndSubscriptionBaseViewController
        parentVC.soloVCNextAndPrevButtonsClicked(index: 0)
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        let parentVC = parent as! UpgradeAndSubscriptionBaseViewController
        parentVC.soloVCNextAndPrevButtonsClicked(index: 1)
    }
    @IBAction func trySoloHostButtonClicked(_ sender: Any) {
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let homeVC = storyBoard.instantiateViewController(withIdentifier: "StripePaymentViewController") as! StripePaymentViewController
        homeVC.passedTypeOfPayment = "SOLO"
        homeVC.selectedPlanName = "Solo Host"
        homeVC.selectedPlanCharge = "$9.95"
        let navVC = UINavigationController(rootViewController: homeVC)
        navVC.isNavigationBarHidden = true
        self.navigationController?.present(navVC, animated: true, completion: nil)
        
    }
    
    
    // MARK: STPAddCardViewControllerDelegate
    
    
    
}
