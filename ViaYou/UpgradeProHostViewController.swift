//
//  UpgradeProHostViewController.swift
//  ViaYou
//
//  Created by Arya S on 09/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class UpgradeProHostViewController: UIViewController {//}, StripePaymentViewControllerDelegate {
    
    @IBOutlet weak var prevButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    let notificationName_UpgradeProHostViewControllerHideAfterPayment = Notification.Name("UpgradeProHostViewControllerHideAfterPayment")
    
    @objc func handleNotification(withNotification notification : NSNotification) {
        //print("Received data in EventsCategoryFilterViewController :: notification.name = \(notification.name)")
        if (notification.name == notificationName_UpgradeProHostViewControllerHideAfterPayment) {
            print("notificationName_UpgradeProHostViewControllerHideAfterPayment...")
            self.prevButton.alpha = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotification(withNotification:)), name: notificationName_UpgradeProHostViewControllerHideAfterPayment, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: notificationName_UpgradeProHostViewControllerHideAfterPayment, object: nil)
    }
    
    @IBAction func prevButtonClicked(_ sender: UIButton) {
        let parentVC = parent as! UpgradeAndSubscriptionBaseViewController
        parentVC.proVCNextAndPrevButtonsClicked(index: 0)
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        let parentVC = parent as! UpgradeAndSubscriptionBaseViewController
        parentVC.proVCNextAndPrevButtonsClicked(index: 1)
    }
    
    @IBAction func tryProHostButtonClicked(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let homeVC = storyBoard.instantiateViewController(withIdentifier: "StripePaymentViewController") as! StripePaymentViewController
//        homeVC.passedTypeOfPayment = "PRO"
//        homeVC.selectedPlanName = "Pro Host"
//        homeVC.selectedPlanCharge = "$18.90"
//        homeVC.selectedSlogan = "Go Pro! with Pro Host"
//        homeVC.delegate = self
        let navVC = UINavigationController(rootViewController: homeVC)
        navVC.isNavigationBarHidden = true
        self.navigationController?.present(navVC, animated: true, completion: nil)
    }
    
    func transactionSuccessful(passedTypeOfPayment: String) {
        print("UpgradeProHostViewController :: transactionSuccessful...")
        DefaultWrapper().setPaymentTypePurchased(type: 2) //2=> Pro
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "PaymentCompletedViewController") as! PaymentCompletedViewController
        self.navigationController?.pushViewController(nextVC, animated: false)
    }
    
    func transactionFailed() {
        print("UpgradeProHostViewController :: transactionFailed...")
    }
    
}
