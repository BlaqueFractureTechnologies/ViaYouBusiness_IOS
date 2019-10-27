//
//  AddFeedPopUpViewController.swift
//  ViaYou
//
//  Created by Arya S on 23/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class AddFeedPopUpViewController: UIViewController {
    
    @IBOutlet weak var popUpHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        if (UIScreen.main.bounds.size.height > 600) {
        //            self.popUpHeightConstraint.constant =
        //        }
    }
    
    @IBAction func closeButtonClicked() {
         self.dismiss(animated: true, completion: nil)
    //    self.navigationController?.popViewController(animated: false)
    }
    
}
