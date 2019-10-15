//
//  NewSignUpViewController.swift
//  Promptchu
//
//  Created by Arya S on 14/09/19.
//  Copyright © 2019 AryaSreenivasan. All rights reserved.
//

import UIKit

class NewLaunchViewController: UIViewController {
    
    
    @IBOutlet weak var bgImageView: UIView!
    @IBOutlet weak var logoImageContainer: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var logoInmageYPositionConstraint: NSLayoutConstraint!
    @IBOutlet weak var baseButtonsContainersBg: UIView!
    @IBOutlet weak var baseButtonsContainer: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var bottomButtonGradientBg: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bgImageView.transform = CGAffineTransform(scaleX: 5.0, y: 5.0)
        logoInmageYPositionConstraint.constant = 100
        baseButtonsContainer.alpha = 0
        baseButtonsContainer.alpha = 0
        infoLabel.alpha = 0
        
        UIView.animate(withDuration: 1.5, delay: 0.4, options: .curveEaseInOut, animations: {
            self.logoImageContainer.layoutIfNeeded()
            self.logoInmageYPositionConstraint.constant = 0
            self.bgImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.baseButtonsContainersBg.alpha = 1
            self.baseButtonsContainer.alpha = 1
            self.infoLabel.alpha = 1
        }) { (completed) in
            
        }
        
        DispatchQueue.main.async {
            self.bottomButtonGradientBg.addAppGradient()
        }
    }
    
    
    @IBAction func signInButtonClicked(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        let navVC = UINavigationController(rootViewController: nextVC)
        navVC.isNavigationBarHidden = true
        self.navigationController?.present(navVC, animated: true, completion: nil)
    }
    
    @IBAction func signUpButtonClicked(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        let navVC = UINavigationController(rootViewController: nextVC)
        navVC.isNavigationBarHidden = true
        self.navigationController?.present(navVC, animated: true, completion: nil)
    }
    
    @IBAction func upArrowClicked(_ sender: Any) {
        
    }
    
}
