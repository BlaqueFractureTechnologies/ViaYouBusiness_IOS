//
//  SplashViewController.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 26/9/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var logoYPositionConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration:2.0,
                       delay: 0.4,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
                        self.logoImageView.layoutIfNeeded()
                        self.logoYPositionConstraint.constant = 0
                        self.logoImageView.transform = CGAffineTransform(rotationAngle: .pi*2)
        }, completion: { (value: Bool) in
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.goToLoginOrHomeVC), userInfo: nil, repeats: false)
        })
        
        //Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(goToLoginOrHomeVC), userInfo: nil, repeats: false)
        
    }
    //adding splash screen
    // TODO:- (If Login - case pending)
    @objc func goToLoginOrHomeVC() {
        
        // If Login
        //        if (UserDefaults.standard.bool(forKey: "IsUserLoggedIn") == true) {
        //            // .. GO To Inner page (Pending)
        //            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //            let homeVC = storyBoard.instantiateViewController(withIdentifier: "NewsFeedsFullGridViewController") as! NewsFeedsFullGridViewController
        //            self.navigationController?.pushViewController(homeVC, animated: true)
        //        }else {
        //Else
        // .. Go To Registration Page
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "NewLaunchViewController") as! NewLaunchViewController
        let navVC = UINavigationController(rootViewController: nextVC)
        navVC.isNavigationBarHidden = true
        self.present(navVC, animated: true, completion: nil)
        // self.navigationController?.pushViewController(nextVC, animated: true)
        //}
    }
}

