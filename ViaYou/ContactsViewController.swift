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
    @IBOutlet weak var inviteAFriendLabel: UILabel!
    
    var fullDataArray:[PhoneContact] = []
    var dataArray:[PhoneContact] = []
    var passedUrlLink: String = ""
    var documentController: UIDocumentInteractionController = UIDocumentInteractionController()
    let defaultProfilePic = UIImage(named: "defaultProfilePic")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let boolVal = UserDefaults.standard.bool(forKey: "isTappedFromSingleVideo")
        if boolVal == true {
            inviteAFriendLabel.text = "Send To"
        }
        else {
            inviteAFriendLabel.text = "Invite A Friend"
        }
        
        self.getContacts { (status,contactsArray) in
            if (status == true) {
                self.fullDataArray = contactsArray
                self.dataArray = contactsArray
                print("contactsReferenceDict.count====>\(self.dataArray.count)")
                for i in 0..<self.dataArray.count {
                    print("contactsReferenceDict====>\(self.dataArray[i].firstName) || \(self.dataArray[i].phoneNumbers)")
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //search
    @IBAction func searchFieldTextChanged(_ sender: UITextField) {
        let searchText = searchField.text ?? ""
        if (searchText.count == 0) {
            dataArray = fullDataArray
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            return
        }
        
        var tempDataArray:[PhoneContact] = []
        for i in 0..<fullDataArray.count {
            let userFullName = fullDataArray[i].fullName
            var userPhoneNumber = ""
            if (fullDataArray[i].phoneNumbers.count > 0) {
                userPhoneNumber = fullDataArray[i].phoneNumbers[0]
            }
            
            if (userFullName.lowercased().contains(searchText.lowercased()) ||
                userPhoneNumber.contains(searchText)) {
                tempDataArray.append(fullDataArray[i])
            }
        }
        
        dataArray = tempDataArray
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //search complete
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsTableViewCell", for: indexPath) as! ContactsTableViewCell
        cell.configureCell(dataDict: dataArray[indexPath.row])
        
        cell.inviteButton.tag = indexPath.row
        cell.inviteButton.addTarget(self, action: #selector(inviteButtonClicked), for: UIControl.Event.touchUpInside)
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
        case 3:
            shareTextOnInstagram()
        case 4:
            shareTextOnAllOtherApps()
        default:
            return
        }
    }
    
    //MARK:-- FB
    func shareTextOnFaceBook() {
        let shareContent = ShareLinkContent()
        // shareContent.contentURL = URL.init(string: "https://developers.facebook.com")! //your link
        shareContent.contentURL = URL.init(string: passedUrlLink)! //your link
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
        
        /*
         let instagramURL = NSURL(string: "instagram://app")
         
         if (UIApplication.shared.canOpenURL(instagramURL! as URL)) {
         
         
         let imageData = self.defaultProfilePic?.jpegData(compressionQuality: 0.75)//UIImageJPEGRepresentation(UIImage(named: "defaultProfilePic")!, 100)
         
         let captionString = self.passedUrlLink
         
         let writePath = (NSTemporaryDirectory() as NSString).appendingPathComponent("instagram.igo")
         do {
         try imageData?.write(to: URL(fileURLWithPath: writePath), options: .atomic)
         } catch {
         print(error)
         }
         let fileURL = NSURL(fileURLWithPath: writePath)
         
         self.documentController = UIDocumentInteractionController(url: fileURL as URL)
         
         self.documentController.delegate = self as? UIDocumentInteractionControllerDelegate
         
         self.documentController.uti = "com.instagram.exlusivegram"
         
         self.documentController.annotation = NSDictionary(object: captionString, forKey: "InstagramCaption" as NSCopying)
         self.documentController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
         
         //}
         }
         */
        
        
        let videoUrlString = "https://www.radiantmediaplayer.com/media/bbb-360p.mp4"
        
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: videoUrlString),
                let urlData = NSData(contentsOf: url) {
                //let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                //let filePath ="\(documentsPath)/tempFile.mp4"
                let filePath = getDocumentsDirectoryFileUrl().absoluteString
                print("Video filePath = \(filePath)")
                
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    print("Video filePath = \(filePath)")
                    
                    print("Video is saved!")
                    
                    let instagramURL = URL(string: "instagram://app")!
                    if (UIApplication.shared.canOpenURL(instagramURL)) {
                        let fileManager = FileManager.default
                        
                        
                        self.documentController = UIDocumentInteractionController(url: getDocumentsDirectoryFileUrl())
                        self.documentController.delegate = self as? UIDocumentInteractionControllerDelegate
                        self.documentController.uti = "com.instagram.exlusivegram"
                        self.documentController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
                    }else {
                        print(" Instagram isn't installed ")
                    }
                    
                    /*
                     PHPhotoLibrary.shared().performChanges({
                     PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                     }) { completed, error in
                     if completed {
                     print("Video is saved!")
                     print("Video is completed = \(completed)")
                     print("Video is error = \(error?.localizedDescription)")
                     
                     let instagramURL = URL(string: "instagram://app")!
                     if (UIApplication.shared.canOpenURL(instagramURL)) {
                     let fileManager = FileManager.default
                     
                     
                     self.documentController = UIDocumentInteractionController(url: getDocumentsDirectoryFileUrl())
                     self.documentController.delegate = self as? UIDocumentInteractionControllerDelegate
                     self.documentController.uti = "com.instagram.exlusivegram"
                     self.documentController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
                     }else {
                     print(" Instagram isn't installed ")
                     }
                     }
                     }
                     */
                }
            }
        }
        
        func getDocumentsDirectoryFileUrl() -> URL {
            let filename = "tempFile.mp4"
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            let filePath = documentsDirectory.appendingPathComponent(filename)
            return filePath
        }
        
        /*
         ///FOR VIDEO POSTING USE THIS LINK AND COMMENT THE ABOVE
         let instagramURL = URL(string: "instagram://app")!
         if (UIApplication.shared.canOpenURL(instagramURL)) {
         
         let imageData = self.passedUrlLink
         let writePath = (NSTemporaryDirectory() as NSString).appendingPathComponent("instagram.igo")
         do {
         try imageData.write(to: URL(fileURLWithPath: writePath), atomically: true, encoding: String.Encoding.init(rawValue: 1))
         } catch {
         print(error)
         }
         
         let fileURL = NSURL(fileURLWithPath: writePath)
         print(fileURL)
         
         self.documentController = UIDocumentInteractionController(url: fileURL as URL)
         
         self.documentController.delegate = self as? UIDocumentInteractionControllerDelegate
         
         self.documentController.uti = "com.instagram.exlusivegram"
         
         self.documentController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
         
         } else {
         print(" Instagram isn't installed ")
         }
         ///END OF VIDEO POSTING CODE
         */
    }
    
    
    
    
    
    func shareTextOnAllOtherApps() {
        
        let firstActivityItem = "ViaYou"
        let secondActivityItem : NSURL = NSURL(string: self.passedUrlLink)!
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, secondActivityItem], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo
        ]
        
        self.present(activityViewController, animated: true, completion: nil)
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
