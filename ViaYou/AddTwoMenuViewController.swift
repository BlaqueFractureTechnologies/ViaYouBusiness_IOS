//
//  AddTwoMenuViewController.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 25/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit
@objc protocol AddTwoMenuViewControllerDelegate{
    @objc optional func AddTwoMenuViewController_screencastButtonClicked()
    @objc optional func AddTwoMenuViewController_videomergeButtonClicked()
}

class AddTwoMenuViewController: UIViewController {
    var delegate:AddTwoMenuViewControllerDelegate?


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func dualScreenCastButtonClicked(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.AddTwoMenuViewController_screencastButtonClicked!()
            
        }
    }
    
    @IBAction func videoMergeButtonClicked(_ sender: Any) {

        self.dismiss(animated: true) {
            self.delegate?.AddTwoMenuViewController_videomergeButtonClicked!()
            
        }

    }
    
}
