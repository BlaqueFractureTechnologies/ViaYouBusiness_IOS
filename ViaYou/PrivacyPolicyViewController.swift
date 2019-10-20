//
//  PrivacyPolicyViewController.swift
//  ViaYou
//
//  Created by Arya S on 20/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let rtfPath = Bundle.main.url(forResource: "Privacy Policy", withExtension: "rtf") {
            do {
                let attributedStringWithRtf: NSAttributedString = try NSAttributedString(url: rtfPath, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                self.textView.attributedText = attributedStringWithRtf
            } catch let error {
                print("Got an error \(error)")
            }
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
