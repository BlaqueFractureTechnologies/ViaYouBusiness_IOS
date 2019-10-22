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
    @IBOutlet weak var planNameLabel: UILabel!
    @IBOutlet weak var ribbonImage: UIImageView!
    
    let profileImageUrlHeader:String = "https://dev-promptchu.s3.us-east-2.amazonaws.com/"
    var subscriptionArray:SubscriptionArrayObject = SubscriptionArrayObject([:])
    
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
    override func viewWillAppear(_ animated: Bool) {
        getSubscriptionPlanResponseFromAPI()
    }
    func getSubscriptionPlanResponseFromAPI() {
        ApiManager().getSubscriptionDetailsAPI { (responseDict, error) in
            if error == nil {
                print(responseDict.message)
                self.subscriptionArray = responseDict.data
                print(self.subscriptionArray.type)
                let type = self.subscriptionArray.type
                if type == "SOLO" {
                    print("0")
                    DefaultWrapper().setPaymentTypePurchased(type: 0)
                }
                else if type == "GROWTH" {
                    print("1")
                    DefaultWrapper().setPaymentTypePurchased(type: 1)
                }
                else if type == "PRO" {
                    print("2")
                    DefaultWrapper().setPaymentTypePurchased(type: 2)
                }
                else {
                    print("-1")
                    DefaultWrapper().setPaymentTypePurchased(type: -1)
                }
                DispatchQueue.main.async {
                    self.planNameLabel.text = "You are now a \(type) HOST"
                    self.ribbonImage.image = UIImage(named: "yellowRibbon_\(type)")
                }
            }
            else
            {
                print(error.debugDescription)
            }
            
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
