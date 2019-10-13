//
//  SubscriptionsListViewController.swift
//  ViaYou
//
//  Created by Arya S on 11/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class SubscriptionsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    let subTitles = ["Solo Host save 15%", "Growth Host save 10%", "Pro Host save 25%", "Enterprise save 30%"]
    let redTitles = ["save 15%", "save 10%", "save 25%", "save 30%"]
    var openedSection = -1
    
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
        return 4
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
        learnMoreButton.frame = CGRect(x: tableView.frame.size.width-110, y: 15, width: 90, height: 30)
        learnMoreButton.backgroundColor = #colorLiteral(red: 0.8779210448, green: 0.4265037179, blue: 0.4941398501, alpha: 1)
        learnMoreButton.titleLabel?.font = UIFont(name: "MonarchaW01-Regular", size: 12)
        learnMoreButton.setTitle("Learn More", for: .normal)
        learnMoreButton.layer.cornerRadius = 5
        learnMoreButton.clipsToBounds = true
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
            return cell
        }else if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionListGrowthTableViewCell", for: indexPath) as! SubscriptionListGrowthTableViewCell
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionListProTableViewCell", for: indexPath) as! SubscriptionListProTableViewCell
            return cell
        }
    }
    
    @objc func overlayButtonClicked(_ sender:UIButton) {
        if (sender.tag == 3) {
            print("Contact us button clicked...")
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
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "UpgradeAndSubscriptionBaseViewController") as! UpgradeAndSubscriptionBaseViewController
        let navVC = UINavigationController(rootViewController: nextVC)
        navVC.isNavigationBarHidden = true
        self.navigationController?.pushViewController(nextVC, animated: false)
    }
    
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

