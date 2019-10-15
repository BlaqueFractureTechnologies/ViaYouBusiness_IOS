//
//  FeatureResuestPage_2ViewController.swift
//  ViaYou
//
//  Created by Arya S on 15/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class FeatureResuestPage_2ViewController: UIViewController {
    
    @IBOutlet weak var homeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.homeButton.addAppGradient()
        }
    }
    
    @IBAction func homeButtonClicked() {
        self.navigationController?.popToViewController(ofClass: LibraryFeedsViewController.self)
    }
    
    @IBAction func backButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
}
