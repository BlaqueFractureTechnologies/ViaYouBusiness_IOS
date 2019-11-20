//
//  TrialPeriodEndedViewController.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 20/11/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit
import Firebase
@objc protocol TrialPeriodEndedViewControllerDelegate{
    @objc optional func becomefullMember_LearnMoreButtonClicked()
    
}
class TrialPeriodEndedViewController: UIViewController {

    var delegate:TrialPeriodEndedViewControllerDelegate?
    @IBOutlet weak var tryGrowthButton: UIButton!
    @IBOutlet weak var profilePic: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    @IBAction func closeButtonClicked() {
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func goToSubmitEmailViewControllerButtonClicked(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.becomefullMember_LearnMoreButtonClicked!()
            
        }
    }
    
}
