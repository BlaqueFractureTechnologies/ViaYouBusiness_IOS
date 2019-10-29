//
//  AddFeedPopUpViewController.swift
//  ViaYou
//
//  Created by Arya S on 23/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit
import Firebase

class AddFeedPopUpViewController: UIViewController {
    
    @IBOutlet weak var popUpHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profilePic: UIImageView!
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
        //        if (UIScreen.main.bounds.size.height > 600) {
        //            self.popUpHeightConstraint.constant =
        //        }
    }
    
    @IBAction func closeButtonClicked() {
         self.dismiss(animated: true, completion: nil)
    //    self.navigationController?.popViewController(animated: false)
    }
    
}
