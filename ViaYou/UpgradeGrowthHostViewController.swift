//
//  UpgradeGrowthHostViewController.swift
//  ViaYou
//
//  Created by Arya S on 09/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class UpgradeGrowthHostViewController: UIViewController, StripePaymentViewControllerDelegate {
    
    @IBOutlet weak var mostPopularLabelContainer: UIView!
    @IBOutlet weak var tryGrowthHostButton: UIView!
    @IBOutlet weak var prevButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    let notificationName_UpgradeGrowthHostViewControllerHideAfterPayment = Notification.Name("UpgradeGrowthHostViewControllerHideAfterPayment")
    
    @objc func handleNotification(withNotification notification : NSNotification) {
        //print("Received data in EventsCategoryFilterViewController :: notification.name = \(notification.name)")
        if (notification.name == notificationName_UpgradeGrowthHostViewControllerHideAfterPayment) {
            print("notificationName_UpgradeGrowthHostViewControllerHideAfterPayment...")
            self.prevButton.alpha = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.mostPopularLabelContainer.addAppGradient()
            self.tryGrowthHostButton.addAppGradient()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotification(withNotification:)), name: notificationName_UpgradeGrowthHostViewControllerHideAfterPayment, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: notificationName_UpgradeGrowthHostViewControllerHideAfterPayment, object: nil)
    }
    
    @IBAction func prevButtonClicked(_ sender: UIButton) {
        let parentVC = parent as! UpgradeAndSubscriptionBaseViewController
        parentVC.growthVCNextAndPrevButtonsClicked(index: 0)
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        let parentVC = parent as! UpgradeAndSubscriptionBaseViewController
        parentVC.growthVCNextAndPrevButtonsClicked(index: 1)
    }
    
    @IBAction func tryGrowthHostButtonClicked(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let homeVC = storyBoard.instantiateViewController(withIdentifier: "StripePaymentViewController") as! StripePaymentViewController
        homeVC.passedTypeOfPayment = "GROWTH"
        homeVC.selectedPlanName = "Growth Host"
        homeVC.selectedPlanCharge = "$75.50"
        homeVC.selectedSlogan = "Scale Up! with Growth Host"
        homeVC.delegate = self
        let navVC = UINavigationController(rootViewController: homeVC)
        navVC.isNavigationBarHidden = true
        self.navigationController?.present(navVC, animated: true, completion: nil)
    }
    
    func transactionSuccessful(passedTypeOfPayment: String) {
        print("UpgradeSoloHostViewController :: transactionSuccessful... passedTypeOfPayment = \(passedTypeOfPayment)")
        DefaultWrapper().setPaymentTypePurchased(type: 1) //1=> Growth
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "PaymentCompletedViewController") as! PaymentCompletedViewController
        self.navigationController?.pushViewController(nextVC, animated: false)
        
    }
    
    func transactionFailed() {
        print("UpgradeGrowthHostViewController :: transactionFailed...")
    }
    
}
