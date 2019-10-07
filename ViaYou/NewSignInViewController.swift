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

class NewSignInViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    var isEmailVerified: Bool = false
    var isPasswordFieldTypeIsSecure: Bool = true
    
    //  var tokenChangeListener: IDTokenDidChangeListenerHandle?
    var generatedUserToken: String = ""
    var isFromSignUpPage: Bool = false
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
                print(result!)
                
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
                                DispatchQueue.main.async {
                                    self.activityIndicator.stopAnimating()
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
    
    //MARK:- Social Media Logins
    @IBAction func loginFacebookAction(_ sender: Any) {
        print("Facebook auth")
        let loginManagerr = LoginManager()
        loginManagerr.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            guard let accessToken = AccessToken.current else {
                print("Failed to get access token")
                return
            }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            print("Facebook access token: \(accessToken.tokenString)")
            // Perform login by calling Firebase APIs
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
            }
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.present(alertController, animated: true, completion: nil)
                    }
                    return
                }
                DispatchQueue.main.async {
                    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    self.getAuthenticationToken()
                    // appDelegate.goToHomeVC()
                }
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
                // self.performSegue(withIdentifier: self.signInSegue, sender: nil)
            })
        }
    }
    
    //MARK:Google SignIn Delegate
    //editing starts
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print("Failed to log into Google: ", error)
            return
        }
        print("Successfully logged into Google", user)
        guard let idToken = user.authentication.idToken else { return }
        guard let accessToken = user.authentication.accessToken else { return }
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        print(credentials)
        print(user.authentication.idToken)
        print(user.authentication.accessToken)
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if let err = error {
                print("Failed to create a Firebase User with Google account: ", err)
                return
            }
            else {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                }
                self.getAuthenticationToken()
                print("success token")
                //                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                //                appDelegate.goToHomeVC()
            }
            
            // segue here
        })
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
