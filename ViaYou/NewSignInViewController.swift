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
    var ref: DatabaseReference!
    
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
        
        
        //        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //        let nextVC = storyBoard.instantiateViewController(withIdentifier: "LibraryFeedsViewController") as! LibraryFeedsViewController
        //        let navVC = UINavigationController(rootViewController: nextVC)
        //        navVC.isNavigationBarHidden = true
        //        self.navigationController?.present(navVC, animated: true, completion: nil)
        
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        print("emailTextField.text: \(emailTextField.text ?? "")")
        print("passwordTextField.text: \(passwordTextField.text ?? "")")
        
        
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
                print("result ====> \(result!)")
                
                Auth.auth().currentUser?.getIDToken(completion: { (updatedToken, error) in
                    if (error == nil) {
                        
                        if let verifiedStatus = Auth.auth().currentUser?.isEmailVerified {
                            self.isEmailVerified = verifiedStatus
                        }
                        
                        print("Is email verified = \(String(describing: self.isEmailVerified))")
                        if self.isEmailVerified {
                            if let userToken = updatedToken {
                                let generatedUserToken = userToken
                                UserDefaults.standard.set(generatedUserToken, forKey: "GeneratedUserToken")
                                print("Updated Token: \(generatedUserToken)")
                                UserDefaults.standard.set(true, forKey: "IsUserLoggedIn")
                                
                                //handling referral events
                                guard let newUserStatus = result?.additionalUserInfo?.isNewUser else {return}
                                if newUserStatus {
                                    print("I'm a new user")
                                    let userID = Auth.auth().currentUser?.uid
                                    self.ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                                        // Get user value
                                        let value = snapshot.value as? NSDictionary
                                        let referredUserName = value?["isReferredBy"] as? String ?? ""
                                        print(referredUserName)
                                        // ...
                                        ApiManager().callUserReferralAPI(referredBy: referredUserName, completion: { (response, error) in
                                            if error == nil {
                                                print("User signed in using referral link")
                                            }
                                            else {
                                                print(error.debugDescription)
                                            }
                                        })
                                    }) { (error) in
                                        print(error.localizedDescription)
                                    }
                                }
                                //handling referral events ends
                                
                                print("Signed in successfully!")
                                UserDefaults.standard.set(true, forKey: "IsUserLoggedIn")
                                DispatchQueue.main.async {
                                    self.activityIndicator.stopAnimating()
//                                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//                                    let homeVC = storyBoard.instantiateViewController(withIdentifier: "UserTipsViewController") as! UserTipsViewController
//                                    let navVC = UINavigationController(rootViewController: homeVC)
//                                    navVC.isNavigationBarHidden = true
//                                    self.navigationController?.present(navVC, animated: true, completion: nil)
                                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                    let homeVC = storyBoard.instantiateViewController(withIdentifier: "LibraryFeedsViewController") as! LibraryFeedsViewController
                                    let navVC = UINavigationController(rootViewController: homeVC)
                                    navVC.isNavigationBarHidden = true
                                    self.navigationController?.present(navVC, animated: true, completion: nil)
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
        }
    }
    
    //editing ends
    //google auth
    
    //listener function
    func getAuthenticationToken() {
        
        //edit starts
        Auth.auth().currentUser?.getIDToken(completion: { (updatedToken, error) in
            if (error == nil) {
                if let userToken = updatedToken {
                    let generatedUserToken = userToken
                    UserDefaults.standard.set(generatedUserToken, forKey: "GeneratedUserToken")
                    print("Updated Token: \(generatedUserToken)")
                    UserDefaults.standard.set(true, forKey: "IsUserLoggedIn")
                    print("Signed in successfully!")
                    DispatchQueue.main.async {
                        //self.activityIndicator.stopAnimating()
                        //let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        // appDelegate.goToHomeVC()
                    }
                }
                else {
                    self.displaySingleButtonAlert(message: "Email not verified. Please verify your email")
                    //                    DispatchQueue.main.async {
                    //                        self.activityIndicator.stopAnimating()
                    //                        self.activityIndicator.isHidden = true
                    //                    }
                }
                
                
            }
        })
    }
    
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
