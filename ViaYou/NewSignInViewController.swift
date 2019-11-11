//
//  NewSignInViewController.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 26/9/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

class NewSignInViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var isEmailVerified: Bool = false
    var isPasswordFieldTypeIsSecure: Bool = true
    
    //  var tokenChangeListener: IDTokenDidChangeListenerHandle?
    var generatedUserToken: String = ""
    var isFromSignUpPage: Bool = false
    var ref: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.loginButton.addAppGradient()
        }
        
        //        GIDSignIn.sharedInstance().uiDelegate = self
        //        GIDSignIn.sharedInstance().delegate = self
        //        GIDSignIn.sharedInstance().signInSilently()
        //        if (AccessToken.current != nil) {
        //            // User is logged in, do work such as go to next view controller.
        //        }
    }
    
    @IBAction func togglePasswordVisibilityButtonClicked(_ sender: Any) {
        if (isPasswordFieldTypeIsSecure == true) {
            isPasswordFieldTypeIsSecure = false
            passwordTextField.isSecureTextEntry = false
        }else {
            isPasswordFieldTypeIsSecure = true
            passwordTextField.isSecureTextEntry = true
        }
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        
        
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        print("emailTextField.text: \(emailTextField.text ?? "")")
        print("passwordTextField.text: \(passwordTextField.text ?? "")")
        
        let credential = EmailAuthProvider.credential(withEmail: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "")

        Auth.auth().signIn(withEmail: emailTextField.text ?? "Invalid Email Address", password: passwordTextField.text ?? "Wrong Password") { (result, error) in
            if error != nil {
                print("Incorrect Credentials!")
                self.displaySingleButtonAlert(message: error?.localizedDescription ?? "Incorrect Credentials!")
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
            }
            else {
                print("result ====> \(String(describing: result?.additionalUserInfo?.isNewUser))")
                                    if let user = Auth.auth().currentUser {
                                        user.link(with: credential) { (user, error) in
                                             //Complete any post sign-up tasks here.
                                            self.getAuthenticationToken()        
                                        }
                }
                
                // new user checking starts
                guard let newUserStatus = result?.additionalUserInfo?.isNewUser else {return}
                if newUserStatus {
                    print("I'm a new user")
                    UserDefaults.standard.set(true, forKey: "IsNewUser")
                    //
                    let userID = Auth.auth().currentUser?.uid
                    self.ref = Database.database().reference()
                    self.ref?.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                        // Get user value
                        let value = snapshot.value as? NSDictionary
                        // let referredUserName = value?["referred_by"] as? String ?? ""
                        if let referredUserName = value?["referred_by"] as? String {
                            let appReferredUserName = referredUserName
                            print("print referral user name: \(appReferredUserName)")
                            // ...
                            ApiManager().callUserReferralAPI(referredBy: appReferredUserName, completion: { (response, error) in
                                if error == nil {
                                    print("User signed in using referral link")
                                }
                                else {
                                    print(error.debugDescription)
                                }
                            })
                        }
                        
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                    //
                }
                else {
                    UserDefaults.standard.set(false, forKey: "IsNewUser")
                }
                
               // new user checking ends
            }
        }
    }
    
    //editing ends
    
    func getAuthenticationToken() {
        
        Auth.auth().currentUser?.getIDToken(completion: { (updatedToken, error) in
            if (error == nil) {
                
                if let verifiedStatus = Auth.auth().currentUser?.isEmailVerified {
                    self.isEmailVerified = verifiedStatus
                }
                
                print("Is email verified = \(String(describing: self.isEmailVerified))")
                if self.isEmailVerified {
                    //                            guard let newUserStatus = result?.additionalUserInfo?.isNewUser else {return}
                    //                            if newUserStatus {
                    //                                print("I'm a new user")
                    //                            }
                    //                            else
                    //                            {
                    //                                print("Welcome back")
                    //                            }
                    if let userToken = updatedToken {
                        let generatedUserToken = userToken
                        UserDefaults.standard.set(generatedUserToken, forKey: "GeneratedUserToken")
                        print("Updated Token: \(generatedUserToken)")
                        print("Signed in successfully!")
                        
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                            let boolValue = UserDefaults.standard.bool(forKey: "IsNewUser")
                            if boolValue == true {
                                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                let homeVC = storyBoard.instantiateViewController(withIdentifier: "UserTipsViewController") as! UserTipsViewController
                                let navVC = UINavigationController(rootViewController: homeVC)
                                navVC.isNavigationBarHidden = true
                                self.navigationController?.present(navVC, animated: true, completion: nil)
                            }
                            else if boolValue == false {
                                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                let homeVC = storyBoard.instantiateViewController(withIdentifier: "LibraryFeedsViewController") as! LibraryFeedsViewController
                                let navVC = UINavigationController(rootViewController: homeVC)
                                navVC.isNavigationBarHidden = true
                                self.navigationController?.present(navVC, animated: true, completion: nil)
                            }
                        }
                    }
                }
                else {
                    self.displaySingleButtonAlert(message: "Email not verified. Please verify your email")
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                    }
                }
                
                
            }
        })
        
    }
    //listener function
    
    @IBAction func createAccountButtonPressed(_ sender: UIButton) {
        if (isFromSignUpPage == true) {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            self.navigationController?.pushViewController(nextVC, animated: true)
        }else {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
}
