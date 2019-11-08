//
//  AppDelegate.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 26/9/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn
import Firebase
import Stripe
import AWSS3
import AWSCore
import AWSCognito

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    let bucketName = "s3.viayou.net"
    var userId: String = ""
    var s3Url: URL!
    var contentUrl: URL!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
//        Stripe.setDefaultPublishableKey("pk_test_kjt2etOhS9X6czAJxzLbEuM5007kPQdweC")
        Stripe.setDefaultPublishableKey("pk_live_ERcYOkG4ChP3Rpy7yzm2dh6L00xDyFrxYu")

        userId = Auth.auth().currentUser!.uid
        return true
    }
    
    //google authentication
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            // ...
            print(error.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        // ...
        print(credential)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any])
        -> Bool {
            //            return GIDSignIn.sharedInstance().handle(url,
            //                                                     sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            //                                                     annotation: [:])
            
            let isDynamicLink = DynamicLinks.dynamicLinks().shouldHandleDynamicLink(fromCustomSchemeURL: url)
            if isDynamicLink == true{
                let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url)
                return handleDynamicLink(dynamicLink)
            }
            // Handle incoming URL with other methods as necessary
            // ...
            return false
    }
    //google authentication ends
    
    // dynamic link handling starts
    
    @available(iOS 8.0, *)
    private func application(_ application: UIApplication,
                             continue userActivity: NSUserActivity,
                             restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        let dynamicLinks = DynamicLinks.dynamicLinks()
        //   guard let dynamicLinks = DynamicLinks.dynamicLinks() else { return false }
        let handled = dynamicLinks.handleUniversalLink(userActivity.webpageURL!) { (dynamicLink, error) in
            if (dynamicLink != nil) && !(error != nil) {
                self.handleDynamicLink(dynamicLink)
            }
        }
        if !handled {
            // Handle incoming URL with other methods as necessary
            // ...
        }
        return handled
    }
    
    @discardableResult func handleDynamicLink(_ dynamicLink: DynamicLink?) -> Bool {
        guard let dynamicLink = dynamicLink else { return false }
        guard let deepLink = dynamicLink.url else { return false }
        let queryItems = URLComponents(url: deepLink, resolvingAgainstBaseURL: true)?.queryItems
        let invitedBy = queryItems?.filter({(item) in item.name == "invitedby"}).first?.value
        let user = Auth.auth().currentUser
        // If the user isn't signed in and the app was opened via an invitation
        // link, sign in the user anonymously and record the referrer UID in the
        // user's RTDB record.
        if user == nil && invitedBy != nil {
            Auth.auth().signInAnonymously() { (user, error) in
                if let user = user {
                    let userRecord = Database.database().reference().child("users").child(user.user.uid)
                    userRecord.child("referred_by").setValue(invitedBy)
                    //                    if dynamicLink.matchConfidence == .weak {
                    //                        // If the Dynamic Link has a weak match confidence, it is possible
                    //                        // that the current device isn't the same device on which the invitation
                    //                        // link was originally opened. The way you handle this situation
                    //                        // depends on your app, but in general, you should avoid exposing
                    //                        // personal information, such as the referrer's email address, to
                    //                        // the user.
                    //                    }
                }
            }
        }
        return true
    }
    
    //dynamic link handling ends
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    let uploadBarStatusNotification = Notification.Name("uploadBarStatusNotification")
    let uploadCompleteStatusNotification = Notification.Name("uploadCompleteStatusNotification")
    
    func uploadFile(with resource: String, type: String, videoURL: URL, passeddataDictToBePosted:[String:Any], passed_s3Url: URL!) {
        print("Appdelegate :: uploadFile..........***************")
        var dataDictToBePosted = passeddataDictToBePosted
        s3Url = passed_s3Url
        
        autoreleasepool{
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    //DTMessageHUD.hud()
                    
                    let key = "\(resource).\(type)"
                    
                    let request = AWSS3TransferManagerUploadRequest()!
                    request.bucket = self.bucketName
                    self.userId = Auth.auth().currentUser!.uid
                    request.key = "posts/"+"\(String(describing: self.userId))"+"/"+key
                    
                    request.body = videoURL
                    request.acl = .publicReadWrite
                    dataDictToBePosted["fileName"] = key
                    
                    let transferManager = AWSS3TransferManager.default()
                    request.uploadProgress = { (bytesSent, totalBytesSent, totalBytesExpectedToSend) -> Void in
                        DispatchQueue.main.async(execute: {
                            let amountUploaded = totalBytesSent // To show the updating data status in label.
                            let fileSize = totalBytesExpectedToSend
                            let percentage = (CGFloat(totalBytesSent)/CGFloat(totalBytesExpectedToSend))*100.0
                            print("uploadProgress :: \(totalBytesSent)/\(totalBytesExpectedToSend) ====> \(percentage)")
                            NotificationCenter.default.post(name: self.uploadBarStatusNotification, object:percentage)
                        })
                    }
                    
                    
                    transferManager.upload(request).continueWith(executor: AWSExecutor.mainThread()) { (task) -> Any? in
                        print("Appdelegate :: uploadFile : transferManager.upload")
                        if let error = task.error {
                            print("Appdelegate :: uploadFile : transferManager.upload :: error ====>> \(error.localizedDescription)")
                            print(error)
                        }
                        if task.result != nil {
                            //Post video to firebase
                            print("Appdelegate :: uploadFile : transferManager.upload :: task.result")
                            
                            //NEW
                            ApiManager().addVideoPostToFirebase(dataDict: dataDictToBePosted, completion: { (responseDict, error) in
                                if (error == nil) {
                                    if (responseDict.success == true) {
                                        print(responseDict)
                                        print("Success :: updatePostToAPI ====> \(responseDict.message)")
                                        print("Uploaded \(key)")
                                        
                                        DispatchQueue.main.async {
                                            let alertController = UIAlertController(title: "Viayou", message: ("Uploaded Video"), preferredStyle:.alert)
                                            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                                            alertController.addAction(action)
                                            self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                                        }
                                    }
                                    NotificationCenter.default.post(name: self.uploadCompleteStatusNotification, object: responseDict)
                                }else {
                                    print("Failed :: updateProfileToAPI ====> \(responseDict.message)")
                                    let alertController = UIAlertController(title: "Viayou", message: "\(error?.localizedDescription ?? "Network Error")", preferredStyle:.alert)
                                    let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                                    alertController.addAction(action)
                                    DispatchQueue.main.async {
                                        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
                                    }
                                    
                                }
                            })
                            
                            //post video to firebase ends
                            
                            let contentUrl = self.s3Url.appendingPathComponent(self.bucketName).appendingPathComponent(key)
                            self.contentUrl = contentUrl
                        }
                        return nil
                    }
                }
            }
        }
        print("Done")
    }
    
}

