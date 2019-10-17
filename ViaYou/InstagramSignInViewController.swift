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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.isHidden = true
        // Do any additional setup after loading the view.
        let authURL = String(format: "%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@&DEBUG=True", arguments: [API.INSTAGRAM_AUTHURL,API.INSTAGRAM_CLIENT_ID,API.INSTAGRAM_REDIRECT_URI, API.INSTAGRAM_SCOPE])
        let urlRequest = URLRequest.init(url: URL.init(string: authURL)!)
        webView.loadRequest(urlRequest)
    }
    
    func checkRequestForCallbackURL(request: URLRequest) -> Bool {
        let requestURLString = (request.url?.absoluteString)! as String
        if requestURLString.hasPrefix(API.INSTAGRAM_REDIRECT_URI) {
            let range: Range<String.Index> = requestURLString.range(of: "#access_token=")!
            handleAuth(authToken: requestURLString.substring(from: range.upperBound))
            //instagram edit starts
            fetchAuthResponseFromAPI()
            //instagram edit ends
            return false;
        }
        return true
    }
    
    func fetchAuthResponseFromAPI() {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        ApiManager().getInstagramAuthResponseFromAPI { (responseDict, error) in
            if (error == nil) {
                print("Response Dict: \(responseDict.result.id)")
                print("Response Dict: \(responseDict.result.userName)")
                let userId = responseDict.result.id
                let userName = responseDict.result.userName
                ApiManager().postInstagramUserIdAPI(userId: userId, name: userName, completion: { (response, error) in
                    if (error == nil) {
                        
                        let customTokenGenerated = response.accessToken
                        print("Response result: \(response.success)")
                        print("access token: \(response.accessToken)")
                        print("Response message: \(response.message)")
                        
                        Auth.auth().signIn(withCustomToken: customTokenGenerated, completion: { (result, error) in
                            if (error == nil) {
                                print("authorised successfully!")
                                self.generatedUserToken = response.accessToken
                                UserDefaults.standard.set(self.generatedUserToken, forKey: "GeneratedUserToken")
                                let instagramAuthenticationToken = UserDefaults.standard.value(forKey: "InstagramAccessToken")
                                ApiManager().getInstaUserDetails(access_token: instagramAuthenticationToken as! String) { (responseDict, error) in
                                    if (error == nil) {
                                        print(responseDict.data)
                                        print("getInstaUserDetails :: profile_picture ====> \(responseDict.data.profile_picture)")
                                        JMImageCache.shared()?.image(for: URL(string: responseDict.data.profile_picture), completionBlock: { (image) in
                                            self.passingProfileImage = image!
                                        }, failureBlock: { (request, response, error) in
                                        })
                                        
                                        DispatchQueue.main.async {
                                            self.activityIndicator.stopAnimating()
                                            self.activityIndicator.isHidden = true
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
        print("Instagram authentication token ==", authToken)
        let instagramAccessToken = authToken
        UserDefaults.standard.set(instagramAccessToken, forKey: "InstagramAccessToken")
        
        
        
    }
    
}
extension InstagramSignInViewController: UIWebViewDelegate{
    func webView(_ webView: UIWebView, shouldStartLoadWith request:URLRequest, navigationType: UIWebView.NavigationType) -> Bool{
        return checkRequestForCallbackURL(request: request)
    }
}
