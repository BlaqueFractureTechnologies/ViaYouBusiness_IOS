//
//  SubscriptionsListViewController.swift
//  ViaYou
//
//  Created by Arya S on 11/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class SubscriptionsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, StripePaymentViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    let subTitles = ["Solo Host save 15%", "Growth Host save 10%", "Pro Host save 25%"]
    let redTitles = ["save 15%", "save 10%", "save 25%"]
    var openedSection = -1
    var isPurchased: Int = 0

    
    var isFromViewAllButtonClickAndFromUpgradePage:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (openedSection != -1) {
            let indexPath = IndexPath(row: 0, section: openedSection)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerBg = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60))
        headerBg.backgroundColor = UIColor.white
        
        let mainTitle = UILabel(frame: CGRect(x: 10, y: 5, width: tableView.frame.size.width-130, height: 25))
        mainTitle.backgroundColor = UIColor.clear
        mainTitle.text = "Upgrade To"
        mainTitle.font = UIFont(name: "MonarchaW01-Regular", size: 16)
        headerBg.addSubview(mainTitle)
        
        let subTitle = UILabel(frame: CGRect(x: 10, y: 30, width: tableView.frame.size.width-130, height: 24))
        subTitle.backgroundColor = UIColor.clear
        subTitle.text = subTitles[section]
        subTitle.font = UIFont(name: "MonarchaW01-Regular", size: 14)
        subTitle.textColor = UIColor.gray
        headerBg.addSubview(subTitle)
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: subTitles[section])
        attributedString.setColor(color: UIColor.red, forText: redTitles[section])
        subTitle.attributedText = attributedString
        
        let learnMoreButton = UIButton(type: .custom)
        learnMoreButton.frame = CGRect(x: tableView.frame.size.width-140, y: 15, width: 130, height: 35)
        learnMoreButton.titleLabel?.font = UIFont(name: "MonarchaW01-Regular", size: 12)
        learnMoreButton.setTitle("Learn More", for: .normal)
        learnMoreButton.setBackgroundImage(UIImage(named: "Invite Button Bubble"), for: .normal)
        headerBg.addSubview(learnMoreButton)
        
        if (section == 3) {
            learnMoreButton.setTitle("Contact Us", for: .normal)
        }
        
        if (openedSection == section) {
            learnMoreButton.alpha = 0
        }
        
        let overlayButton = UIButton(type: .custom)
        overlayButton.frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60)
        overlayButton.backgroundColor = UIColor.clear
        headerBg.addSubview(overlayButton)
        
        overlayButton.tag = section
        overlayButton.addTarget(self, action: #selector(overlayButtonClicked), for: UIControl.Event.touchUpInside)
        
        return headerBg
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 3) {
            return 0
        }
        if (openedSection == section) {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionListSoloTableViewCell", for: indexPath) as! SubscriptionListSoloTableViewCell
            cell.upgradeToSoloHostButton.addTarget(self, action: #selector(upgradeToSoloHostButtonClicked), for: UIControl.Event.touchUpInside)
            return cell
        }else if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionListGrowthTableViewCell", for: indexPath) as! SubscriptionListGrowthTableViewCell
            cell.upgradeToGrowthHost.addTarget(self, action: #selector(upgradeToGrowthHostButtonClicked), for: UIControl.Event.touchUpInside)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionListProTableViewCell", for: indexPath) as! SubscriptionListProTableViewCell
            cell.upgadeToProHost.addTarget(self, action: #selector(upgadeToProHostButtonClicked), for: UIControl.Event.touchUpInside)
            return cell
        }
    }
    @objc func upgradeToSoloHostButtonClicked() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let homeVC = storyBoard.instantiateViewController(withIdentifier: "StripePaymentViewController") as! StripePaymentViewController
        homeVC.passedTypeOfPayment = "SOLO"
        homeVC.selectedPlanName = "Solo Host"
        homeVC.selectedPlanCharge = "$9.95"
        homeVC.delegate = self
        let navVC = UINavigationController(rootViewController: homeVC)
        navVC.isNavigationBarHidden = true
        self.navigationController?.present(navVC, animated: true, completion: nil)
    }
    @objc func upgradeToGrowthHostButtonClicked() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let homeVC = storyBoard.instantiateViewController(withIdentifier: "StripePaymentViewController") as! StripePaymentViewController
        homeVC.passedTypeOfPayment = "GROWTH"
        homeVC.selectedPlanName = "Growth Host"
        homeVC.selectedPlanCharge = "$7.75"
        homeVC.delegate = self
        let navVC = UINavigationController(rootViewController: homeVC)
        navVC.isNavigationBarHidden = true
        self.navigationController?.present(navVC, animated: true, completion: nil)
    }
    @objc func upgadeToProHostButtonClicked() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let homeVC = storyBoard.instantiateViewController(withIdentifier: "StripePaymentViewController") as! StripePaymentViewController
        homeVC.passedTypeOfPayment = "PRO"
        homeVC.selectedPlanName = "Pro Host"
        homeVC.selectedPlanCharge = "$18.90"
        homeVC.delegate = self
        let navVC = UINavigationController(rootViewController: homeVC)
        navVC.isNavigationBarHidden = true
        self.navigationController?.present(navVC, animated: true, completion: nil)
    }
    
    func transactionSuccessful(passedTypeOfPayment: String) {
        print("UpgradeSoloHostViewController :: transactionSuccessful... passedTypeOfPayment = \(passedTypeOfPayment)")
        
        if (passedTypeOfPayment == "SOLO") {
            DefaultWrapper().setPaymentTypePurchased(type: 0) //0=> Solo
        }else if (passedTypeOfPayment == "GROWTH") {
            DefaultWrapper().setPaymentTypePurchased(type: 1) //1=> Growth
        }else if (passedTypeOfPayment == "PRO") {
            DefaultWrapper().setPaymentTypePurchased(type: 2) //2=> Pro
        }
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "PaymentCompletedViewController") as! PaymentCompletedViewController
        self.navigationController?.pushViewController(nextVC, animated: false)
    }
    
    func transactionFailed() {
        print("UpgradeSoloHostViewController :: transactionFailed...")
    }
    
    @objc func overlayButtonClicked(_ sender:UIButton) {
        if (sender.tag == 3) {
            print("Contact us button clicked...")
            if let url = URL(string: "http://www.apple.com") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
            return
        }
        
        if (openedSection == sender.tag) {
            openedSection = -1
        }else {
            openedSection = sender.tag
        }
        tableView.reloadData()
        
        if (openedSection != -1) {
            let indexPath = IndexPath(row: 0, section: openedSection)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
        
    }
    
    @IBAction func upgrageButtonClicked() {
        if (isFromViewAllButtonClickAndFromUpgradePage == true) {
            self.navigationController?.popViewController(animated: false)
        }else {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "UpgradeAndSubscriptionBaseViewController") as! UpgradeAndSubscriptionBaseViewController
            let navVC = UINavigationController(rootViewController: nextVC)
            navVC.isNavigationBarHidden = true
            self.navigationController?.pushViewController(nextVC, animated: false)
        }
        
    }
    
    
    @IBAction func backButtonClicked(_ sender: Any) {
        if (isFromViewAllButtonClickAndFromUpgradePage == true) {
            self.navigationController?.popViewControllers(viewsToPop: 2)
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
}

