//
//  PaymentCompletedViewController.swift
//  ViaYou
//
//  Created by Arya S on 21/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit
import Firebase

class PaymentCompletedViewController: UIViewController {
    @IBOutlet weak var profilePicView: UIImageView!
    
    let profileImageUrlHeader:String = "https://dev-promptchu.s3.us-east-2.amazonaws.com/"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let profileImage = "profile.jpg"
        if let selfUserId = Auth.auth().currentUser?.uid {
            let profileImageOnlineUrl = "\(profileImageUrlHeader)users/\(selfUserId)/\(profileImage)"
            print("profileImageOnlineUrl====>\(profileImageOnlineUrl)")

            JMImageCache.shared()?.image(for: URL(string: profileImageOnlineUrl), completionBlock: { (image) in
                
                self.profilePicView.image = image
                self.profilePicView.layer.cornerRadius = self.profilePicView.frame.size.width/2.0
                self.profilePicView.clipsToBounds = true
                if (__CGSizeEqualToSize(self.profilePicView.image?.size ?? CGSize.zero, CGSize.zero)) {
                    print("EMPTY IMAGE")
                    self.profilePicView.image = UIImage(named: "defaultProfilePic")
                }
            }, failureBlock: { (request, response, error) in
            })
        }
    }
    
    @IBAction func upgradeButtonClicked() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "UpgradeAndSubscriptionBaseViewController") as! UpgradeAndSubscriptionBaseViewController
        nextVC.isFromPaymentConfirmedPage = true
        let navVC = UINavigationController(rootViewController: nextVC)
        navVC.isNavigationBarHidden = true
        self.navigationController?.pushViewController(nextVC, animated: false)
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
