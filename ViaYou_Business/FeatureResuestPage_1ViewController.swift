//
//  FeatureResuestPage_1ViewController.swift
//  ViaYou
//
//  Created by Arya S on 15/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit
import Firebase

class FeatureResuestPage_1ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewBg: UIView!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    
    let profileImageUrlHeader:String = "http://s3.viayou.net/"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        textViewBg.layer.cornerRadius = 5
        textViewBg.layer.borderColor = UIColor.gray.cgColor
        textViewBg.layer.borderWidth = 1.0
        textView.addDoneButtonToKeyboard(myAction:  #selector(textView.resignFirstResponder))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.inviteButton.addAppGradient()
        }
    }
    
    @objc func  dismissTextViewKeyboard() {
        textView.resignFirstResponder()
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
    
    @IBAction func nextButtonClicked() {
        let textToBePassed = textView.text ?? ""
        if textToBePassed.count > 0 {
            ApiManager().addFeatureAPI(description: textView.text) { (response, error) in
                print(response) // minor edit
                print(response) // minor edit
                
                if error == nil {
                    print(response.message)
                    print(response.success)
                    DispatchQueue.main.async {
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        let nextVC = storyBoard.instantiateViewController(withIdentifier: "FeatureResuestPage_2ViewController") as! FeatureResuestPage_2ViewController
                        self.navigationController?.pushViewController(nextVC, animated: true)
                    }
                }
            }
        }
        else {
            self.displayAlert(msg: "Please enter your Request")
            //            DispatchQueue.main.async {
            //                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            //                let nextVC = storyBoard.instantiateViewController(withIdentifier: "FeatureResuestPage_2ViewController") as! FeatureResuestPage_2ViewController
            //                self.navigationController?.pushViewController(nextVC, animated: true)
            //            }
            
        }
        
        
        
    }
    
    @IBAction func backButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
}
