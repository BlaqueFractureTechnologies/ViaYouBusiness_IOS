//
//  SubscriptionBaseViewController.swift
//  ViaYou
//
//  Created by Arya S on 10/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class SubscriptionBaseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionBaseViewTableViewCell", for: indexPath) as! SubscriptionBaseViewTableViewCell
        
        if (indexPath.row == 0) {
            cell.mainTitleLabel.text = "Upgrade To"
            cell.subTitleLabel.text = "Solo Host"
            cell.offerLabel.text = " save 15%"
        }else if (indexPath.row == 1) {
            cell.mainTitleLabel.text = "Upgrade To"
            cell.subTitleLabel.text = "Growth Host"
            cell.offerLabel.text = " save 10%"
        }else if (indexPath.row == 2){
            cell.mainTitleLabel.text = "Upgrade To"
            cell.subTitleLabel.text = "Pro Host"
            cell.offerLabel.text = " save 25%"
        }
        else {
            cell.mainTitleLabel.text = "Upgrade To"
            cell.subTitleLabel.text = "Enterprise"
            cell.offerLabel.text = " save 30%"
            cell.learnMoreButton.setTitle("Contact Us", for: .normal)
        }
        
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
