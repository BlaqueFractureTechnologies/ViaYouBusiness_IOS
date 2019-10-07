//
//  ContactsViewController.swift
//  ViaYou
//
//  Created by Arya S on 04/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit
import MessageUI
//import FacebookShare
import FBSDKShareKit

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, SharingDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    
    var dataArray:[PhoneContact] = []
    var passedUrlLink: String = ""
    var isSearch: Bool!
    var sortedArray:[PhoneContact] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isSearch = false
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.getContacts { (status,contactsArray) in
            if (status == true) {
                self.dataArray = contactsArray
                print("contactsReferenceDict====>\(self.dataArray.count)")
                for i in 0..<self.dataArray.count {
                    print("contactsReferenceDict====>\(self.dataArray[i].firstName)")
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //search
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var searchText  = textField.text! + string
        
        if string  == "" {
            searchText = (searchText as String).substring(to: searchText.index(before: searchText.endIndex))
        }
        
        if searchText == "" {
            isSearch = false
            tableView.reloadData()
        }
        else{
            getSearchArrayContains(searchText)
        }
        
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func getSearchArrayContains(_ text : String) {
//        let predicate : NSPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", text)
//        sortedArray = (dataArray as NSArray).filtered(using: predicate) as! [PhoneContact]
//        isSearch = true
//        tableView.reloadData()
        
        sortedArray = dataArray.filter({ data in
            return data.fullName.contains(text)
        })
        isSearch = true
        tableView.reloadData()
    }
    //search complete
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch! {
            return sortedArray.count
        }
        else{
            return dataArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsTableViewCell", for: indexPath) as! ContactsTableViewCell
        if isSearch! {
           // cell.textLabel?.text = sortedArray[indexPath.row]
            cell.configureCell(dataDict: sortedArray[indexPath.row])
            
            cell.inviteButton.tag = indexPath.row
            cell.inviteButton.addTarget(self, action: #selector(inviteButtonClicked), for: UIControl.Event.touchUpInside)
        }
        else{
            
            cell.configureCell(dataDict: dataArray[indexPath.row])
            
            cell.inviteButton.tag = indexPath.row
            cell.inviteButton.addTarget(self, action: #selector(inviteButtonClicked), for: UIControl.Event.touchUpInside)
        }
        
        return cell
    }
    
    @objc func inviteButtonClicked(_ sender:UIButton) {
        print("inviteButtonClicked...")
        
        let clickedUserPhoneNumbers = dataArray[sender.tag].phoneNumbers
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Hey, Checked out our new App \(self.passedUrlLink)"//"Message Body"
            controller.recipients = clickedUserPhoneNumbers
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func socialButtonsClicked(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            shareTextOnFaceBook()
            return
        case 1:
            shareTextOnTwitter()
            return
        case 2:
            shareTextOnWhatsApp()
            return
        default:
            return
        }
    }
    
    //MARK:-- FB
    func shareTextOnFaceBook() {
        let shareContent = ShareLinkContent()
        shareContent.contentURL = URL.init(string: "https://developers.facebook.com")! //your link
        shareContent.quote = self.passedUrlLink//"Text to be shared"
        ShareDialog(fromViewController: self, content: shareContent, delegate: self).show()
    }
    
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        if sharer.shareContent.pageID != nil {
            print("Share: Success")
        }
    }
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        print("Share: Fail")
    }
    func sharerDidCancel(_ sharer: Sharing) {
        print("Share: Cancel")
    }
    
    //MARK:-- Twitter
    func shareTextOnTwitter() {
        let tweetText = self.passedUrlLink//"your text"
        let tweetUrl = "http://stackoverflow.com/"
        let shareString = "https://twitter.com/intent/tweet?text=\(tweetText)&url=\(tweetUrl)"
        // encode a space to %20 for example
        let escapedShareString = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: escapedShareString)
        if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }else {
            self.displayAlert(msg: "Install Twitter")
        }
    }
    
    //MARK:-- WhatsApp
    func shareTextOnWhatsApp() {
        let originalString = self.passedUrlLink//"First Whatsapp Share"
        let escapedString = originalString.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed)
        
        let url  = URL(string: "whatsapp://send?text=\(escapedString!)")
        
   //     if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
//        }else {
//            self.displayAlert(msg: "Install Whatsapp")
//        }
    }
    
    //MARK:-- Instagram (Refer: https://medium.com/@maximbilan/ios-sharing-via-instagram-9bf9a9f7f14d) and implement
    func shareTextOnInstagram() {
        let url = NSURL(string: "instagram://app")
        if UIApplication.shared.canOpenURL(url! as URL) {
            
        }else {
            self.displayAlert(msg: "Install Instagram")
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        if (self.isViewLoaded && self.view.window == nil) {
            self.view = nil
        }
    }
    
}


//
