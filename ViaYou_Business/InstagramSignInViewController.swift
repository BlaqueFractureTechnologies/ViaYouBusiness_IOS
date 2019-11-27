//
//  InstagramSignInViewController.swift
//  Promptchu
//
//  Created by Promptchu Pty Ltd on 24/7/19.
//  Copyright © 2019 AryaSreenivasan. All rights reserved.
//

import UIKit
import WebKit
import Firebase

class InstagramSignInViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var webView: UIWebView!
    var generatedUserToken: String = ""
    var passingProfileImage = UIImage()
    var ref: DatabaseReference?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.isHidden = true
        // Do any additional setup after loading the view.
        let authURL = String(format: "%@?app_id=%@&redirect_uri=%@&scope=%@&response_type=code", arguments: [API.INSTAGRAM_AUTHURL,API.APP_ID,API.INSTAGRAM_REDIRECT_URI, API.INSTAGRAM_SCOPE])
        //  let authURL = String(format: "%@?app_id=%@&redirect_uri=%@&response_type=code&scope=%@&DEBUG=True", arguments: [API.INSTAGRAM_AUTHURL,API.APP_ID,API.INSTAGRAM_REDIRECT_URI, API.INSTAGRAM_SCOPE])
        
        print(authURL)
        let urlRequest = URLRequest.init(url: URL.init(string: authURL)!)
        webView.loadRequest(urlRequest)
    }
    
    func checkRequestForCallbackURL(request: URLRequest) -> Bool {
        let requestURLString = (request.url?.absoluteString)! as String
        print(API.INSTAGRAM_REDIRECT_URI)
        if requestURLString.hasPrefix(API.INSTAGRAM_REDIRECT_URI) {
            let range: Range<String.Index> = requestURLString.range(of: "?code=")!
            handleAuth(authToken: requestURLString.substring(from: range.upperBound))
            //instagram edit starts
            fetchInstagramAuthToken()
            //fetchAuthResponseFromAPI()
            //instagram edit ends
            return false;
        }
        return true
    }
    
    func fetchInstagramAuthToken() {
        let instagramAuthenticationCode = UserDefaults.standard.value(forKey: "InstagramAuthenticationCode")
        if let authenticationCode = instagramAuthenticationCode {
            let codeForToken = authenticationCode as! String
            let newStr = codeForToken.replacingOccurrences(of: "#_", with: "")
            ApiManager().getInstagramTokenAPI(app_id: API.APP_ID , app_secret: API.INSTAGRAM_APPSERCRET, grant_type: "authorization_code", redirect_uri: API.INSTAGRAM_REDIRECT_URI, code: newStr) { (response, error) in
                if error == nil {
                    print(response.access_token)
                    print(response.user_id)
                    let instagramAuthenticationToken = response.access_token
                    UserDefaults.standard.set(instagramAuthenticationToken, forKey: "InstagramAccessToken")
                    self.fetchAuthResponseFromAPI()
                }
                else {
                    print(error.debugDescription)
                    self.displayAlert(msg: "Error while logging in! Please try again later!")
                }
            }
        }
    }
    
    func fetchAuthResponseFromAPI() {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        ApiManager().getInstagramAuthResponseFromAPI { (responseDict, error) in
            if (error == nil) {
                
                print("Response Dict: \(responseDict.user_id)")
                print("Response Dict: \(responseDict.username)")
                let userId = responseDict.user_id
                let userName = responseDict.username
                ApiManager().postInstagramUserIdAPI(userId: userId, name: userName, completion: { (response, error) in
                    if (error == nil) {
                        
                        let customTokenGenerated = response.accessToken
                        print("Response result: \(response.success)")
                        print("access token: \(response.accessToken)")
                        print("Response message: \(response.message)")
                        
                        Auth.auth().signIn(withCustomToken: customTokenGenerated, completion: { (result, error) in
                            if (error == nil) {
                                print("authorised successfully!")
                                print("Response message: \(response.message)")
                                
                                Auth.auth().currentUser?.getIDToken(completion: { (token, error) in
                                    if token != nil {
                                        print(token)
                                        if let userToken = token {
                                            self.generatedUserToken = userToken
                                            print(self.generatedUserToken)
                                            UserDefaults.standard.set(self.generatedUserToken, forKey: "GeneratedUserToken")
                                            //  let instagramAuthenticationToken = UserDefaults.standard.value(forKey: "InstagramAccessToken")
                                            UserDefaults.standard.set(true, forKey: "IsUserLoggedIn")
                                            UserDefaults.standard.set(true, forKey: "UserFromInstagram")
                                            //onboard screens
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
                                                    // let referredUserName = value?["referredBy"] as? String ?? ""
                                                    if let referredUserName = value?["referredBy"] as? String {
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
                                            //onboard screens end
                                            DispatchQueue.main.async {
                                                self.activityIndicator.stopAnimating()
                                                self.activityIndicator.isHidden = true
                                                let boolValue = UserDefaults.standard.bool(forKey: "IsNewUser")
                                                if boolValue == true {
                                                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                                    let homeVC = storyBoard.instantiateViewController(withIdentifier: "UserTipsViewController") as! UserTipsViewController
                                                    print(self.passingProfileImage)
                                                    homeVC.passedProfileImage = self.passingProfileImage
                                                    let navVC = UINavigationController(rootViewController: homeVC)
                                                    navVC.isNavigationBarHidden = true
                                                    self.navigationController?.present(navVC, animated: true, completion: nil)
                                                }
                                                else if boolValue == false {
                                                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                                    let homeVC = storyBoard.instantiateViewController(withIdentifier: "LibraryFeedsViewController") as! LibraryFeedsViewController
                                                    homeVC.passedProfileImage = self.passingProfileImage
                                                    let navVC = UINavigationController(rootViewController: homeVC)
                                                    navVC.isNavigationBarHidden = true
                                                    self.navigationController?.present(navVC, animated: true, completion: nil)
                                                }
                                            }
                                        }
                                    }
                                })
                                //                                self.generatedUserToken = response.accessToken
                                //
                                //                                UserDefaults.standard.set(self.generatedUserToken, forKey: "GeneratedUserToken")
                                //                              //  let instagramAuthenticationToken = UserDefaults.standard.value(forKey: "InstagramAccessToken")
                                //                                UserDefaults.standard.set(true, forKey: "IsUserLoggedIn")
                                //
                                //                                //onboard screens
                                //                                // new user checking starts
                                //                                guard let newUserStatus = result?.additionalUserInfo?.isNewUser else {return}
                                //                                if newUserStatus {
                                //                                    print("I'm a new user")
                                //                                    UserDefaults.standard.set(true, forKey: "IsNewUser")
                                //                                    //
                                //                                    let userID = Auth.auth().currentUser?.uid
                                //                                    self.ref = Database.database().reference()
                                //                                    self.ref?.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                                //                                        // Get user value
                                //                                        let value = snapshot.value as? NSDictionary
                                //                                        // let referredUserName = value?["referredBy"] as? String ?? ""
                                //                                        if let referredUserName = value?["referredBy"] as? String {
                                //                                            let appReferredUserName = referredUserName
                                //                                            print("print referral user name: \(appReferredUserName)")
                                //                                            // ...
                                //                                            ApiManager().callUserReferralAPI(referredBy: appReferredUserName, completion: { (response, error) in
                                //                                                if error == nil {
                                //                                                    print("User signed in using referral link")
                                //                                                }
                                //                                                else {
                                //                                                    print(error.debugDescription)
                                //                                                }
                                //                                            })
                                //                                        }
                                //
                                //                                    }) { (error) in
                                //                                        print(error.localizedDescription)
                                //                                    }
                                //                                    //
                                //                                }
                                //                                else {
                                //                                    UserDefaults.standard.set(false, forKey: "IsNewUser")
                                //                                }
                                //
                                //                                // new user checking ends
                                //                                //onboard screens end
                                //                                DispatchQueue.main.async {
                                //                                    self.activityIndicator.stopAnimating()
                                //                                    self.activityIndicator.isHidden = true
                                //                                    let boolValue = UserDefaults.standard.bool(forKey: "IsNewUser")
                                //                                    if boolValue == true {
                                //                                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                //                                        let homeVC = storyBoard.instantiateViewController(withIdentifier: "UserTipsViewController") as! UserTipsViewController
                                //                                        print(self.passingProfileImage)
                                //                                        homeVC.passedProfileImage = self.passingProfileImage
                                //                                        let navVC = UINavigationController(rootViewController: homeVC)
                                //                                        navVC.isNavigationBarHidden = true
                                //                                        self.navigationController?.present(navVC, animated: true, completion: nil)
                                //                                    }
                                //                                    else if boolValue == false {
                                //                                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                //                                        let homeVC = storyBoard.instantiateViewController(withIdentifier: "LibraryFeedsViewController") as! LibraryFeedsViewController
                                //                                        homeVC.passedProfileImage = self.passingProfileImage
                                //                                        let navVC = UINavigationController(rootViewController: homeVC)
                                //                                        navVC.isNavigationBarHidden = true
                                //                                        self.navigationController?.present(navVC, animated: true, completion: nil)
                                //                                    }
                                //                                }
                                //                                ApiManager().getInstaUserDetails(access_token: instagramAuthenticationToken as! String) { (responseDict, error) in
                                //                                    if (error == nil) {
                                //                                        print(responseDict.data)
                                //                                        print("getInstaUserDetails :: profile_picture ====> \(responseDict.data.profile_picture)")
                                //                                        JMImageCache.shared()?.image(for: URL(string: responseDict.data.profile_picture), completionBlock: { (image) in
                                //                                            if let imageRetrieved = image {
                                //                                                self.passingProfileImage = imageRetrieved
                                //                                            }
                                //                                            UserDefaults.standard.set(true, forKey: "IsUserLoggedIn")
                                //                                            DispatchQueue.main.async {
                                //                                                self.activityIndicator.stopAnimating()
                                //                                                self.activityIndicator.isHidden = true
                                //                                                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                //                                                let homeVC = storyBoard.instantiateViewController(withIdentifier: "LibraryFeedsViewController") as! LibraryFeedsViewController
                                //                                                homeVC.passedProfileImage = self.passingProfileImage
                                //                                                let navVC = UINavigationController(rootViewController: homeVC)
                                //                                                navVC.isNavigationBarHidden = true
                                //                                                self.navigationController?.present(navVC, animated: true, completion: nil)
                                //                                            }
                                //
                                //                                        }, failureBlock: { (request, response, error) in
                                //                                        })
                                //
                                //
                                //                                    }
                                //                                }
                                
                            }
                            else{
                                print("Instagram sign in error: \(error.debugDescription)")
                            }
                        })
                    }
                    else {
                        print(error.debugDescription)
                        
                    }
                })
                
            }else {
                print(error.debugDescription)
            }
            
        }
    }
    
    func handleAuth(authToken: String) {
        print("Instagram authentication code ==", authToken)
        let instagramAccessCode = authToken
        UserDefaults.standard.set(instagramAccessCode, forKey: "InstagramAuthenticationCode")
        
        
        
    }
    
}
extension InstagramSignInViewController: UIWebViewDelegate{
    func webView(_ webView: UIWebView, shouldStartLoadWith request:URLRequest, navigationType: UIWebView.NavigationType) -> Bool{
        return checkRequestForCallbackURL(request: request)
    }
}
