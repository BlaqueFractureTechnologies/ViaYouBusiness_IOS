//
//  MergeVideoDescriptionPopUpViewController.swift
//  Promptchu
//
//  Created by Arya S on 08/09/19.
//  Copyright © 2019 AryaSreenivasan. All rights reserved.
//

import UIKit

@objc protocol MergeVideoDescriptionPopUpViewControllerDelegate{
    @objc optional func mergeVideoDescriptionPopUpVCDescriptionTextSubmitted(descriptionString:String)
}

class MergeVideoDescriptionPopUpViewController: UIViewController, UITextViewDelegate {
    
    var delegate:MergeVideoDescriptionPopUpViewControllerDelegate?
    
    var descriptionText:String = ""
    
    @IBOutlet weak var dummyDescriptionTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dummyDescriptionTextView.layer.cornerRadius = 8
        dummyDescriptionTextView.clipsToBounds = true
        dummyDescriptionTextView.layer.borderColor = hexStringToUIColor(hex: "F8CC5F").cgColor
        dummyDescriptionTextView.layer.borderWidth = 2
        
        if (descriptionText.count > 0) {
            descriptionTextView.text = descriptionText
            dummyDescriptionTextView.text = ""
        }else {
            descriptionTextView.text = ""
            dummyDescriptionTextView.text = "Description"
        }
        descriptionTextView.becomeFirstResponder()
        descriptionTextView.addDoneButtonToKeyboard(myAction:  #selector(descriptionTextView.resignFirstResponder))
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if (descriptionText.count > 0) {
            descriptionTextView.text = textView.text
            dummyDescriptionTextView.text = ""
        }else {
            dummyDescriptionTextView.text = "Description"
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEditing...")
        self.dismiss(animated: true) {
            self.delegate?.mergeVideoDescriptionPopUpVCDescriptionTextSubmitted!(descriptionString: self.descriptionTextView.text ?? "")
        }
    }
    
    @objc func descriptionTextViewDoneButtonClicked() {
        print("descriptionTextViewDoneButtonClicked...")
    }
    
    //    func addDoneButtonToKeyboard(){
    //        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40))
    //        doneToolbar.barStyle = UIBarStyle.default
    //
    //        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
    //        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.descriptionTextViewDoneButtonClicked))
    //
    //        var items = [UIBarButtonItem]()
    //        items.append(flexSpace)
    //        items.append(done)
    //
    //        doneToolbar.items = items
    //        doneToolbar.sizeToFit()
    //
    //        descriptionTextView.inputAccessoryView = doneToolbar
    //    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
}
