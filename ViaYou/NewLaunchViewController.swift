//
//  NewSignUpViewController.swift
//  Promptchu
//
//  Created by Arya S on 14/09/19.
//  Copyright © 2019 AryaSreenivasan. All rights reserved.
//

import UIKit

class NewLaunchViewController: UIViewController {
    
    
    @IBOutlet weak var arrowIcon: UIButton!
    @IBOutlet weak var arrowButtonBottomConstraints: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
