//
//  SubmitEmailViewController.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 18/11/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit
import Firebase

class SubmitEmailViewController: UIViewController {
    @IBOutlet weak var addEmailTextField: UITextField!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var submitEmailButton: UIButton!
    @IBOutlet weak var emailTextFieldContainer: UIView!
    
    let profileImageUrlHeader:String = "http://s3.viayou.net/"
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profileImage = "profile.jpg"
        if let selfUserId = Auth.auth().currentUser?.uid {
            let profileImageOnlineUrl = "\(profileImageUrlHeader)users/\(selfUserId)/\(profileImage)"
            print("profileImageOnlineUrl====>\(profileImageOnlineUrl)")
            
            JMImageCache.shared()?.image(for: URL(string: profileImageOnlineUrl), completionBlock: { (image) in
                self.profilePic.image = image
                
                if (__CGSizeEqualToSize(self.profilePic.image?.size ?? CGSize.zero, CGSize.zero)) {
                    print("EMPTY IMAGE")
                    self.profilePic.image = UIImage(named: "defaultProfilePic")
                }
            }, failureBlock: { (request, response, error) in
            })
        }
        
         let emailAddress = UserDefaults.standard.value(forKey: "UserEmailAddress") //{
        print("Email address ==> \(String(describing: emailAddress))")
            self.addEmailTextField.text = emailAddress as? String
       // }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.dismissKeyboard()
        submitEmailButton.addAppGradient()
        self.emailTextFieldContainer.layer.borderColor = self.view.themeRedColor().cgColor
        self.emailTextFieldContainer.layer.borderWidth = 1.0
    }
    
    @IBAction func submitEmailButtonClicked(_ sender: Any) {
        ApiManager().getEmailToUpgradeAPI(emailId: addEmailTextField.text ?? "" ) { (response, error) in
                if error == nil {
                    print(response.message)
                    self.displayAlert(msg: response.message)
                }
                else {
                    print(error.debugDescription)
                    self.displayAlert(msg: "Sorry! Please try again later.")
                }
            }
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
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
