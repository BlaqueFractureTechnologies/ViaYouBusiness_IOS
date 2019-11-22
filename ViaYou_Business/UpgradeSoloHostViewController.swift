//
//  UpgradeSoloHostViewController.swift
//  ViaYou
//
//  Created by Arya S on 09/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit
//import Stripe

class UpgradeSoloHostViewController: UIViewController {//},StripePaymentViewControllerDelegate {
    @IBOutlet weak var trySoloHostButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup payment card text field
        
        
        // Add payment card text field to view
        //  view.addSubview(paymentCardTextField)
        
    }
    
    let notificationName_UpgradeSoloHostViewControllerHideAfterPayment = Notification.Name("UpgradeSoloHostViewControllerHideAfterPayment")
    
    @objc func handleNotification(withNotification notification : NSNotification) {
        //print("Received data in EventsCategoryFilterViewController :: notification.name = \(notification.name)")
        if (notification.name == notificationName_UpgradeSoloHostViewControllerHideAfterPayment) {
            print("notificationName_UpgradeSoloHostViewControllerHideAfterPayment...")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotification(withNotification:)), name: notificationName_UpgradeSoloHostViewControllerHideAfterPayment, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: notificationName_UpgradeSoloHostViewControllerHideAfterPayment, object: nil)
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
//        homeVC.passedTypeOfPayment = "SOLO"
//        homeVC.selectedPlanName = "Solo Host"
//        homeVC.selectedPlanCharge = "$9.95"
//        homeVC.selectedSlogan = "Go Solo! with Solo Host"
//        homeVC.delegate = self
        let navVC = UINavigationController(rootViewController: homeVC)
        navVC.isNavigationBarHidden = true
        self.navigationController?.present(navVC, animated: true, completion: nil)
        
    }
    
    func transactionSuccessful(passedTypeOfPayment: String) {
        print("UpgradeSoloHostViewController :: transactionSuccessful... passedTypeOfPayment = \(passedTypeOfPayment)")
        DefaultWrapper().setPaymentTypePurchased(type: 0) //0=> Solo
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "PaymentCompletedViewController") as! PaymentCompletedViewController
        self.navigationController?.pushViewController(nextVC, animated: false)
    }
    
    func transactionFailed() {
        print("UpgradeSoloHostViewController :: transactionFailed...")
    }
    // MARK: STPAddCardViewControllerDelegate
    
    
    
}
