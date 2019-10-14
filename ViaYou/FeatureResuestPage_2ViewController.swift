//
//  FeatureResuestPage_2ViewController.swift
//  ViaYou
//
//  Created by Arya S on 15/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class FeatureResuestPage_2ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func homeButtonClicked() {
        self.navigationController?.popToViewController(ofClass: LibraryFeedsViewController.self)
    }
    
    @IBAction func backButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
}
