//
//  SignUpMobileEntryViewController.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 26/9/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class SignUpMobileEntryViewController: UIViewController {
    
    @IBOutlet weak var segmentButtonsContainer: UIView!
    @IBOutlet weak var segmentEmailButton: UIButton!
    @IBOutlet weak var segmentPhoneButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var countryCodeField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var emailFieldContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var phoneFieldContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollContainer: UIView!
    @IBOutlet weak var segmentButonsContainerTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nextButtonContainer: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    var emailButtonGradient:CAGradientLayer = CAGradientLayer()
    var phoneButtonGradient:CAGradientLayer = CAGradientLayer()
    
    var topMargin: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideKeyboardWhenTappedAround()
        self.emailField.makeDarkGrayPlaceholder()
        self.countryCodeField.makeDarkGrayPlaceholder()
        self.phoneField.makeDarkGrayPlaceholder()
        self.hideKeyboardWhenTappedAround()
        self.scrollView.backgroundColor = UIColor.clear
        self.segmentButtonsContainer.layer.borderColor = self.view.themeRedColor().cgColor
        self.segmentButtonsContainer.layer.borderWidth = 1.0
        
        DispatchQueue.main.async {
            self.nextButton.addAppGradient()
            self.phoneButtonGradient = self.segmentPhoneButton.addAppGradientAndGetIt()
        }
        setUpView()
    }
    
    //    override func viewWillLayoutSubviews() {
    //        setUpView()
    //    }
    
    func setUpView() {
        let scrollViewHeight = scrollView.frame.size.height
        let nextButtonContainerOriginY = nextButtonContainer.frame.origin.y
        //        print("scrollContainer.height====>\(scrollView.frame.size.height)")
        //        print("nextButtonContainerOriginY====>\(nextButtonContainerOriginY)")
        //
        //        scrollContainer.layoutIfNeeded()
        //        print("scrollView.frame.size.height====>\(scrollView.frame.size.height)")
        //        print("scrollView.frame.size.height*====>\(scrollView.frame.size.height-(nextButtonContainer.frame.origin.y+nextButtonContainer.frame.size.height+10))")
        //
        self.emailFieldContainerHeightConstraint.constant = 0
        topMargin = scrollViewHeight-(nextButtonContainerOriginY+40+10)
        self.segmentButonsContainerTopMarginConstraint.constant = topMargin
        
    }
    
    @IBAction func segmentButtonClicked(_ sender: UIButton) {
        if (sender.tag == 0) {
            //segmentEmailButton.backgroundColor = self.view.themeRedColor()
            DispatchQueue.main.async {
                self.phoneButtonGradient.removeFromSuperlayer()
                self.emailButtonGradient = self.segmentEmailButton.addAppGradientAndGetIt()
            }
            
            segmentEmailButton.setTitleColor(UIColor.white, for: .normal)
            segmentPhoneButton.backgroundColor = UIColor.clear
            segmentPhoneButton.setTitleColor(UIColor.gray, for: .normal)
            UIView.animate(withDuration: 0.4) {
                self.phoneFieldContainerHeightConstraint.constant = 0
                self.emailFieldContainerHeightConstraint.constant = 44
                self.view.layoutIfNeeded()
            }
        }else {
            segmentEmailButton.backgroundColor = UIColor.clear
            segmentEmailButton.setTitleColor(UIColor.gray, for: .normal)
            //segmentPhoneButton.backgroundColor = self.view.themeRedColor()
            DispatchQueue.main.async {
                self.emailButtonGradient.removeFromSuperlayer()
                self.phoneButtonGradient = self.segmentPhoneButton.addAppGradientAndGetIt()
            }
            
            segmentPhoneButton.setTitleColor(UIColor.white, for: .normal)
            
            UIView.animate(withDuration: 0.4) {
                self.emailFieldContainerHeightConstraint.constant = 0
                self.phoneFieldContainerHeightConstraint.constant = 44
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        
        let email = emailField.text ?? ""
        if email.count == 0 {
            self.displaySingleButtonAlert(message: "Please enter your email")
        }
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "SignUpPasswordEntryViewController") as! SignUpPasswordEntryViewController
        nextVC.topMargin = self.topMargin
        nextVC.passedEmailAddress = email
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func alreadyHaveAnAccountButtonClicked(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "NewSignInViewController") as! NewSignInViewController
        nextVC.isFromSignUpPage = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}
