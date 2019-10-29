//
//  BecomeGrowthHostPopUpViewController.swift
//  ViaYou
//
//  Created by Arya S on 10/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit
import Firebase

@objc protocol BecomeGrowthHostPopUpViewControllerDelegate{
    @objc optional func becomeGrowthHostPopUpVC_UpgradeAndSubscriptionBaseViewControllerButtonClicked()
    @objc optional func becomeGrowthHostPopUpVC_SubscriptionBaseViewControllerrButtonClicked()
}

class BecomeGrowthHostPopUpViewController: UIViewController {
    
    @IBOutlet weak var crownButton: UIButton!
    var delegate:BecomeGrowthHostPopUpViewControllerDelegate?
    @IBOutlet weak var tryGrowthButton: UIButton!
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        crownButton.layer.borderColor = UIColor.white.cgColor
        crownButton.layer.borderWidth = 5.0
        
        DispatchQueue.main.async {
            self.tryGrowthButton.addAppGradient()
        }
    }
    
    
    @IBAction func closeButtonClicked() {
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func goToUpgradeAndSubscriptionBaseViewControllerButtonClicked() {
        self.dismiss(animated: true) {
            self.delegate?.becomeGrowthHostPopUpVC_SubscriptionBaseViewControllerrButtonClicked!()
            
        }
    }
    
    @IBAction func goToSubscriptionBaseViewControllerrButtonClicked() {
        self.dismiss(animated: true) {
            self.delegate?.becomeGrowthHostPopUpVC_UpgradeAndSubscriptionBaseViewControllerButtonClicked!()
            
        }
    }
    
}
