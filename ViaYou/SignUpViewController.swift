//
//  SignUpViewController.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 26/9/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController{ //, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet var socialButtonsBaseCollection: [UIView]!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signInWithFacebook: UIButton!
   // @IBOutlet weak var signInWithGoogle: GIDSignInButton!
  //  var tokenChangeListener: IDTokenDidChangeListenerHandle?
    var generatedUserToken: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.isHidden = true
//        GIDSignIn.sharedInstance().uiDelegate = self
//        GIDSignIn.sharedInstance().delegate = self
//        GIDSignIn.sharedInstance().signInSilently()
//        if (AccessToken.current != nil) {
//            // User is logged in, do work such as go to next view controller.
//        }
    }
    
    //MARK:- Facebook auth
    
    @IBAction func loginFacebookAction(_ sender: Any) {
//        let loginManagerr = LoginManager()
//        loginManagerr.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
//            if let error = error {
//                print("Failed to login: \(error.localizedDescription)")
//                return
//            }
//            guard let accessToken = AccessToken.current else {
//                print("Failed to get access token")
//                return
//            }
//            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
//            print("Facebook access token: \(accessToken.tokenString)")
//            // Perform login by calling Firebase APIs
//            DispatchQueue.main.async {
//                self.activityIndicator.isHidden = false
//                self.activityIndicator.startAnimating()
//            }
//            Auth.auth().signIn(with: credential, completion: { (user, error) in
//                if let error = error {
//                    print("Login error: \(error.localizedDescription)")
//                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
//                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                    alertController.addAction(okayAction)
//
//                    DispatchQueue.main.async {
//                        self.activityIndicator.stopAnimating()
//                        self.activityIndicator.isHidden = true
//                        self.present(alertController, animated: true, completion: nil)
//                    }
//                    return
//                }
//                DispatchQueue.main.async {
//                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                    self.getAuthenticationToken()
//                    appDelegate.goToHomeVC()
//                }
//                DispatchQueue.main.async {
//                    self.activityIndicator.stopAnimating()
//                    self.activityIndicator.isHidden = true
//                }
//                // self.performSegue(withIdentifier: self.signInSegue, sender: nil)
//            })
//        }
    }
    //MARK:- Google auth
    
    @IBAction func signInWithGoogleButtonClicked(_ sender: Any) {
//        GIDSignIn.sharedInstance().uiDelegate = self
//        GIDSignIn.sharedInstance().signIn()
        
    }
    
    //MARK:Google SignIn Delegate
    //editing starts
//    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
//        if let error = error {
//            print("Failed to log into Google: ", error)
//            return
//        }
//
//        print("Successfully logged into Google", user)
//        guard let idToken = user.authentication.idToken else { return }
//        guard let accessToken = user.authentication.accessToken else { return }
//        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
//
//        print(credentials)
//        print(user.authentication.idToken)
//        print(user.authentication.accessToken)
//        DispatchQueue.main.async {
//            self.activityIndicator.isHidden = false
//            self.activityIndicator.startAnimating()
//        }
    
//        Auth.auth().signIn(with: credentials, completion: { (user, error) in
//            if let err = error {
//                print("Failed to create a Firebase User with Google account: ", err)
//                return
//            }
//            else {
//                DispatchQueue.main.async {
//                    self.activityIndicator.stopAnimating()
//                    self.activityIndicator.isHidden = true
//                }
//                self.getAuthenticationToken()
//                print("success token")
//                //                let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                //                appDelegate.goToHomeVC()
//            }
//
//            // segue here
//        })
//    }
    //editing ends
    //google auth
    
    //listener function
//    func getAuthenticationToken() {
//
//        //edit starts
//        Auth.auth().currentUser?.getIDToken(completion: { (updatedToken, error) in
//            if (error == nil) {
//                if let userToken = updatedToken {
//                    let generatedUserToken = userToken
//                    UserDefaults.standard.set(generatedUserToken, forKey: "GeneratedUserToken")
//                    print("Updated Token: \(generatedUserToken)")
//                    UserDefaults.standard.set(true, forKey: "IsUserLoggedIn")
//                    print("Signed in successfully!")
//                    DispatchQueue.main.async {
//                        //self.activityIndicator.stopAnimating()
//                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                        appDelegate.goToHomeVC()
//                    }
//                }
//                else {
//                    self.displaySingleButtonAlert(message: "Email not verified. Please verify your email")
//                    //                    DispatchQueue.main.async {
//                    //                        self.activityIndicator.stopAnimating()
//                    //                        self.activityIndicator.isHidden = true
//                    //                    }
//                }
//
//
//            }
//        })
//        //edit ends
//        //        Auth.auth().addIDTokenDidChangeListener({ (auth, user) in
//        //            if let user = user {
//        //                // Get the token, renewing it if the 60 minute expiration
//        //                //  has occurred.
//        //                user.getIDToken { idToken, error in
//        //                    if let error = error {
//        //                        // Handle error
//        //                        print("getIDToken error: \(error)")
//        //                        return;
//        //                    }
//        //
//        //                    print("getIDToken token: \(String(describing: idToken))")
//        //                    if let validToken = idToken {
//        //                        self.generatedUserToken = validToken
//        //                        print("Generated user token = \(self.generatedUserToken)")
//        //                        UserDefaults.standard.set(self.generatedUserToken, forKey: "GeneratedUserToken")
//        //                    }
//        //
//        //                    // Reauthorize Firebase with the new token: idToken
//        //                }
//        //            }
//        //        })
//    }
    //listener function ends
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for i in 0..<socialButtonsBaseCollection.count {
            socialButtonsBaseCollection[i].applySignUpButtonTheme()
        }
        
    }
    
    @IBAction func signUpWithPhoneOrEmailButtonClicked(_ sender: UIButton) {
        //        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //        let nextVC = storyBoard.instantiateViewController(withIdentifier: "CreateAccountViewController") as! CreateAccountViewController
        //        self.navigationController?.pushViewController(nextVC, animated: true)
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "SignUpMobileEntryViewController") as! SignUpMobileEntryViewController
        self.navigationController?.pushViewController(nextVC, animated: true)
        
    }
    
    @IBAction func alreadyHaveAnAccountButtonClicked(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "NewSignInViewController") as! NewSignInViewController
        //nextVC.isFromSignUpPage = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
}
