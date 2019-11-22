//
//  SubscriptionBaseViewController.swift
//  ViaYou
//
//  Created by Arya S on 10/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class SubscriptionBaseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var memberTypeLabel: UILabel!
    var isPurchased: Int = 0
    
    let notificationName_UpgradeSoloHostViewControllerHideAfterPayment = Notification.Name("UpgradeSoloHostViewControllerHideAfterPayment")
    let notificationName_UpgradeGrowthHostViewControllerHideAfterPayment = Notification.Name("UpgradeGrowthHostViewControllerHideAfterPayment")
    let notificationName_UpgradeProHostViewControllerHideAfterPayment = Notification.Name("UpgradeProHostViewControllerHideAfterPayment")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        
        isPurchased = DefaultWrapper().getPaymentTypePurchased()
        
        if isPurchased == 0 {
            self.memberTypeLabel.text = "You are a Solo Host"
        }
        else if isPurchased == 1 {
            self.memberTypeLabel.text = "You are a Growth Host"
        }
        else if isPurchased == 2 {
            self.memberTypeLabel.text = "You are a Pro Host"
        }
        else {
            self.memberTypeLabel.text = "You are a Free Member"
        }
        
        //isPurchased = -1 => 3 cells
        //isPurchased = 0  => 2 cells
        //isPurchased = 1 => 1 cells
        //isPurchased = 2 => 0 cells
        let isPurchasedAndCells:[String:Int] = ["-1":3,
                                                "0":2,
                                                "1":1,
                                                "2":0]
        
        //isPurchased = 2 //For testing
        if (isPurchased >= 0) {
            let numberOfDisplayedCells:Int = isPurchasedAndCells["\(isPurchased)"] ?? 0
            print(numberOfDisplayedCells)
            DispatchQueue.main.async {
                self.tableViewHeightConstraint.constant = CGFloat(numberOfDisplayedCells*60)
            }
        }
        
        
        
        
        
        tableView.reloadData()
        // Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.resetScrollViewAccordingToPayment), userInfo: nil, repeats: false)
    }
    
    @objc func resetScrollViewAccordingToPayment() {
        print("resetScrollViewAccordingToPayment...")
        
        let paymentTypePurchased = DefaultWrapper().getPaymentTypePurchased()
        print("paymentTypePurchased ====> \(paymentTypePurchased)")
        
        if (paymentTypePurchased == -1) {
            DispatchQueue.main.async {
            }
        }else {
            if (paymentTypePurchased == 0) {// Purchased solo
                DispatchQueue.main.async {
                }
                NotificationCenter.default.post(name: self.notificationName_UpgradeGrowthHostViewControllerHideAfterPayment, object:nil)
            }else if (paymentTypePurchased == 1 || paymentTypePurchased == 2) {// Purchased growth OR Purchased pro
                DispatchQueue.main.async {
                }
                NotificationCenter.default.post(name: self.notificationName_UpgradeProHostViewControllerHideAfterPayment, object:nil)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row != 2 && isPurchased >= indexPath.row {
            return 0
        }
        else {
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionBaseViewTableViewCell", for: indexPath) as! SubscriptionBaseViewTableViewCell
        if (indexPath.row == 0) {
            cell.mainTitleLabel.text = "Upgrade To"
            cell.subTitleLabel.text = "Solo Host"
            //cell.offerLabel.text = " save 15%"
        }else if (indexPath.row == 1) {
            cell.mainTitleLabel.text = "Upgrade To"
            cell.subTitleLabel.text = "Growth Host"
            //cell.offerLabel.text = " save 10%"
        }else { //if (indexPath.row == 2){
            cell.mainTitleLabel.text = "Upgrade To"
            cell.subTitleLabel.text = "Pro Host"
            // cell.offerLabel.text = " save 25%"
        }
        //        else {
        //            cell.mainTitleLabel.text = "Upgrade To"
        //            cell.subTitleLabel.text = "Enterprise"
        //           // cell.offerLabel.text = " save 30%"
        //            cell.learnMoreButton.setTitle("Contact Us", for: .normal)
        //        }
        
        cell.learnMoreButton.tag = indexPath.row
        cell.learnMoreButton.addTarget(self, action: #selector(learnMoreButtonClicked), for: UIControl.Event.touchUpInside)
        
        return cell
    }
    
    
    @objc func learnMoreButtonClicked(_ sender:UIButton) {
        if (sender.tag == 3) {
            print("Contact us button clicked...")
            if let url = URL(string: "http://www.apple.com") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
            return
        } else {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "SubscriptionsListViewController") as! SubscriptionsListViewController
            nextVC.openedSection = sender.tag
            let navVC = UINavigationController(rootViewController: nextVC)
            navVC.isNavigationBarHidden = true
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        
    }
    
    //    @IBAction func upgrageButtonClicked() {
    //        navigationController?.popToViewController(ofClass: UpgradeAndSubscriptionBaseViewController.self, animated: true)
    //    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
