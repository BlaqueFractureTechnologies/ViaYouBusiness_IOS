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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.addDoneButtonToKeyboard(myAction: #selector(self.dismissTextViewKeyboard))
        textViewBg.layer.cornerRadius = 5
        textViewBg.layer.borderColor = UIColor.gray.cgColor
        textViewBg.layer.borderWidth = 1.0
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
