//
//  SignUpPasswordEntryViewController.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 26/9/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class SignUpPasswordEntryViewController: UIViewController {
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var scrollContainer: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nextButtonContainer: UIView!
    @IBOutlet weak var passwordFieldContainerTopMarginConstraint: NSLayoutConstraint!
    
    var isPasswordFieldTypeIsSecure: Bool = true
    var topMargin: CGFloat = 0.0
    var passedEmailAddress: String = ""
    var generatedUserToken: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.scrollView.backgroundColor = UIColor.clear
        self.passwordField.makeWhitePlaceholder()
        self.hideKeyboardWhenTappedAround()
        setUpView()
    }
    
    
    func setUpView() {
        //        let scrollViewHeight = scrollView.frame.size.height
        //        let nextButtonContainerOriginY = nextButtonContainer.frame.origin.y
        //        print("scrollContainer.height====>\(scrollView.frame.size.height)")
        //        print("nextButtonContainerOriginY====>\(nextButtonContainerOriginY)")
        //
        //        scrollContainer.layoutIfNeeded()
        //        print("scrollView.frame.size.height====>\(scrollView.frame.size.height)")
        //        print("scrollView.frame.size.height*====>\(scrollView.frame.size.height-(nextButtonContainer.frame.origin.y+nextButtonContainer.frame.size.height+10))")
        
        self.passwordFieldContainerTopMarginConstraint.constant = topMargin+75//scrollViewHeight-(nextButtonContainerOriginY+nextButtonContainer.frame.size.height+10)
    }
    
    @IBAction func togglePasswordVisibilityButtonClicked(_ sender: Any) {
        if (isPasswordFieldTypeIsSecure == true) {
            isPasswordFieldTypeIsSecure = false
            passwordField.isSecureTextEntry = false
        }else {
            isPasswordFieldTypeIsSecure = true
            passwordField.isSecureTextEntry = true
        }
    }
    
    @IBAction func alreadyHaveAnAccountButtonClicked(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "NewSignInViewController") as! NewSignInViewController
        nextVC.isFromSignUpPage = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func signUpButtonClicked(_ sender: Any) {
        let password = passwordField.text ?? ""
        if password.count < 8 {
            self.displaySingleButtonAlert(message: "Please enter a valid password")
        }
        //edit starts
//        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
//        SVProgressHUD.show()
//        ApiManager().callRegistrationAPI( email: self.passedEmailAddress, password: password, gender: "Female") { (responseDict, error) in
//            if (error == nil) {
//                if (responseDict.success == true) {
//                    print(responseDict.message)
//                    if (responseDict.message.count>0) {
//                        print(responseDict.message)
//                        self.generatedUserToken = ""
//                        UserDefaults.standard.set(self.generatedUserToken, forKey: "GeneratedUserToken")
//                        DispatchQueue.main.async {
//                            let alert = UIAlertController(title: "Alert", message: responseDict.message, preferredStyle: .alert)
//                            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
//                                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//                                let homeVC = storyBoard.instantiateViewController(withIdentifier: "NewSignInViewController") as! NewSignInViewController
//                                self.navigationController?.pushViewController(homeVC, animated: true)
//                            })
//                            alert.addAction(okAction)
//                            self.present(alert, animated: true, completion: nil)
//
//                        }
//
//                    }else {
//                        // Registration success (& if message.count == 0)
//                        self.displaySingleButtonAlert(message: "Registration success. Please check your email for verification link")
//                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//                        let homeVC = storyBoard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
//                        self.navigationController?.pushViewController(homeVC, animated: true)
//                    }
//                }else {
//                    if (responseDict.message.count>0) {
//                        print(responseDict.message)
//                        // Registration failed (& if message.count > 0)
//                        self.displaySingleButtonAlert(message: responseDict.message)
//                    }else {
//                        // Registration failed (& if message.count == 0)
//                        self.displaySingleButtonAlert(message: "Registration failed. Please try again later")
//                    }
//                }
//            }else {
//                self.displaySingleButtonAlert(message: error?.localizedDescription ?? "Unknown error")
//            }
//            DispatchQueue.main.async {
//                SVProgressHUD.dismiss()
//            }
//        }
        //edit ends
        
    }
    
    
}
