//
//  UpgradeAndSubscriptionBaseViewController.swift
//  ViaYou
//
//  Created by Arya S on 09/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class UpgradeAndSubscriptionBaseViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var containersCollection: [UIView]!
    
    var isFromViewAllButtonClick:Bool = false
    var isFromPaymentConfirmedPage:Bool = false
    
    let notificationName_UpgradeSoloHostViewControllerHideAfterPayment = Notification.Name("UpgradeSoloHostViewControllerHideAfterPayment")
    let notificationName_UpgradeGrowthHostViewControllerHideAfterPayment = Notification.Name("UpgradeGrowthHostViewControllerHideAfterPayment")
    let notificationName_UpgradeProHostViewControllerHideAfterPayment = Notification.Name("UpgradeProHostViewControllerHideAfterPayment")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.scrollView.backgroundColor = UIColor.white
            //self.scrollView.alpha = 0
        }
        Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.resetScrollViewAccordingToPayment), userInfo: nil, repeats: false)
    }
    
    @objc func resetScrollViewAccordingToPayment() {
        print("resetScrollViewAccordingToPayment...")
        
        let paymentTypePurchased = DefaultWrapper().getPaymentTypePurchased()
        print("paymentTypePurchased ====> \(paymentTypePurchased)")
        
        if (paymentTypePurchased == -1) {
            DispatchQueue.main.async {
                self.soloVCNextAndPrevButtonsClicked(index: 1)
            }
        }else {
            if (paymentTypePurchased == 0) {// Purchased solo
                DispatchQueue.main.async {
                    self.soloVCNextAndPrevButtonsClicked(index: 1)
                }
                NotificationCenter.default.post(name: self.notificationName_UpgradeGrowthHostViewControllerHideAfterPayment, object:nil)
            }else if (paymentTypePurchased == 1 || paymentTypePurchased == 2) {// Purchased growth OR Purchased pro
                DispatchQueue.main.async {
                    self.growthVCNextAndPrevButtonsClicked(index: 1)
                }
                NotificationCenter.default.post(name: self.notificationName_UpgradeProHostViewControllerHideAfterPayment, object:nil)
            }
        }
        
        self.scrollView.alpha = 1
        
        
    }
    
    func soloVCNextAndPrevButtonsClicked(index:Int) {
        let _w = UIScreen.main.bounds.size.width
        if (index == 0) {
            scrollView.setContentOffset(CGPoint(x: (_w*2), y: 0), animated: false)
        }else {
            scrollView.setContentOffset(CGPoint(x: _w, y: 0), animated: false)
        }
    }
    
    func growthVCNextAndPrevButtonsClicked(index:Int) {
        let _w = UIScreen.main.bounds.size.width
        if (index == 0) {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }else {
            scrollView.setContentOffset(CGPoint(x: (_w*2), y: 0), animated: false)
        }
    }
    
    func proVCNextAndPrevButtonsClicked(index:Int) {
        let _w = UIScreen.main.bounds.size.width
        if (index == 0) {
            scrollView.setContentOffset(CGPoint(x: _w, y: 0), animated: false)
        }else {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
    }
    
    @IBAction func subscriptionButtonClicked() {
        if (isFromViewAllButtonClick == true) {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "SubscriptionsListViewController") as! SubscriptionsListViewController
            nextVC.isFromViewAllButtonClickAndFromUpgradePage = true
            let navVC = UINavigationController(rootViewController: nextVC)
            navVC.isNavigationBarHidden = true
            self.navigationController?.pushViewController(nextVC, animated: false)
        }else {
            self.navigationController?.popViewController(animated: false)
        }
        
        
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        if (isFromViewAllButtonClick == true) {
            self.navigationController?.popViewController(animated: true)
        } else if (isFromPaymentConfirmedPage == true) {
            self.navigationController?.popViewControllers(viewsToPop: 3)
        }else {
            self.navigationController?.popViewControllers(viewsToPop: 2)
        }
        
        
    }
}
