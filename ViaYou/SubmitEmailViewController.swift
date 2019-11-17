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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.emailTextFieldContainer.layer.borderColor = self.view.themeRedColor().cgColor
        self.emailTextFieldContainer.layer.borderWidth = 1.0
    }
    
    @IBAction func submitEmailButtonClicked(_ sender: Any) {
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
}
