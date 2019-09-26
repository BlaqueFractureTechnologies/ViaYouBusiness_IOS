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
        
        UIView.animate(withDuration: 2.0, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            self.arrowIcon.frame = CGRect(x: self.arrowIcon.frame.origin.x, y: self.arrowIcon.frame.origin.y-10, width: self.arrowIcon.frame.size.width, height: self.arrowIcon.frame.size.height)
            
        }, completion: nil)
        
    }
    
    
    @IBAction func signInButtonClicked(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "NewSignInViewController") as! NewSignInViewController
        let navVC = UINavigationController(rootViewController: nextVC)
        navVC.isNavigationBarHidden = true
        self.present(navVC, animated: true, completion: nil)
    }
    
    @IBAction func signUpButtonClicked(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        let navVC = UINavigationController(rootViewController: nextVC)
        navVC.isNavigationBarHidden = true
        self.present(navVC, animated: true, completion: nil)
    }
    
    @IBAction func upArrowClicked(_ sender: Any) {
        
    }
    
}
