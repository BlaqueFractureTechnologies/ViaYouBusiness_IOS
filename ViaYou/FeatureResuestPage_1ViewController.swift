//
//  FeatureResuestPage_1ViewController.swift
//  ViaYou
//
//  Created by Arya S on 15/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class FeatureResuestPage_1ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewBg: UIView!
    @IBOutlet weak var inviteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textViewBg.layer.cornerRadius = 5
        textViewBg.layer.borderColor = UIColor.gray.cgColor
        textViewBg.layer.borderWidth = 1.0
        textView.addDoneButtonToKeyboard(myAction:  #selector(textView.resignFirstResponder))
        
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
    
    @IBAction func nextButtonClicked() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "FeatureResuestPage_2ViewController") as! FeatureResuestPage_2ViewController
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func backButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
}
