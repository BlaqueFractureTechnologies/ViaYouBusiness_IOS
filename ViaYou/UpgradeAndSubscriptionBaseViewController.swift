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
    
    var isFromViewAllButtonClick:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.scrollView.backgroundColor = UIColor.white
            let _w = UIScreen.main.bounds.size.width
            self.scrollView.setContentOffset(CGPoint(x: _w, y: 0), animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        }else {
            self.navigationController?.popViewControllers(viewsToPop: 2)
        }
    }
}
