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
import Firebase

class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, SharingDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var inviteAFriendLabel: UILabel!
    @IBOutlet weak var sendAllInvitationButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var inviteAllButton: UIButton!
    @IBOutlet weak var inviteAllRadioButton_Right: UIButton!
    @IBOutlet weak var inviteAllTextButton_Right: UIButton!
    @IBOutlet weak var profilePicButton: UIButton!
    
    var fullDataArray:[PhoneContact] = []
    var dataArray:[PhoneContact] = []
    var passedUrlLink: String = ""
    var documentController: UIDocumentInteractionController = UIDocumentInteractionController()
    let defaultProfilePic = UIImage(named: "defaultProfilePic")
    var inviteText: String = ""
    var isInviteAllOptionEnabled: Bool = false
    var isInviteAllRadioButtonHighlighted: Bool = false
    let profileImageUrlHeader:String = "http://s3.viayou.net/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        DispatchQueue.main.async {
            self.sendAllInvitationButtonHeightConstraint.constant = 0
            self.tableViewBottomConstraint.constant = 0
            self.inviteAllRadioButton_Right.alpha = 0
            self.inviteAllTextButton_Right.alpha = 0
        }
        
        let profileImage = "profile.jpg"
        if let selfUserId = Auth.auth().currentUser?.uid {
            let profileImageOnlineUrl = "\(profileImageUrlHeader)users/\(selfUserId)/\(profileImage)"
            print("profileImageOnlineUrl====>\(profileImageOnlineUrl)")
            
            JMImageCache.shared()?.image(for: URL(string: profileImageOnlineUrl), completionBlock: { (image) in
                
                self.profilePicButton.setBackgroundImage(image, for: .normal)
                
                if (__CGSizeEqualToSize(self.profilePicButton.currentBackgroundImage?.size ?? CGSize.zero, CGSize.zero)) {
                    print("EMPTY IMAGE")
                    self.profilePicButton.setBackgroundImage(UIImage(named: "defaultProfilePic"), for: .normal)
                }
            }, failureBlock: { (request, response, error) in
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let boolVal = UserDefaults.standard.bool(forKey: "isTappedFromSingleVideo")
        if boolVal == true {
            inviteAFriendLabel.text = "Send To"
            inviteText = "Hey, Checkout this video- "
        }
        else {
            inviteAFriendLabel.text = "Invite A Friend"
            inviteText = "I am on ViaYou, check out it's awesome video features. Dont just share your story, be a part of it. Download for free."
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
        
        cell.radioButton.tag = indexPath.row
        cell.radioButton.addTarget(self, action: #selector(radioButtonClicked), for: UIControl.Event.touchUpInside)
        UIView.animate(withDuration: 0.4) {
            if (self.isInviteAllOptionEnabled == false) {
                cell.radioButtonWidthConstraints.constant = 0
                cell.inviteButtonWidthConstraints.constant = 100
                cell.layoutIfNeeded()
            }else {
                cell.radioButtonWidthConstraints.constant = 40
                cell.inviteButtonWidthConstraints.constant = 0
                cell.layoutIfNeeded()
            }
        }
        return cell
    }
    
    @objc func inviteButtonClicked(_ sender:UIButton) {
        print("inviteButtonClicked...")
        
        let clickedUserPhoneNumbers = dataArray[sender.tag].phoneNumbers
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "\(inviteText) \(self.passedUrlLink)"//"Message Body"
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
        shareContent.quote = "\(inviteText) \(self.passedUrlLink)"//"Text to be shared"
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
        let tweetText = "\(inviteText) \(self.passedUrlLink)"//"your text"
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
        let originalString = "\(inviteText) \(self.passedUrlLink)"//"First Whatsapp Share"
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
        
        
        let videoUrlString = "\(self.passedUrlLink)"
        
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
        
        let firstActivityItem = "\(inviteText) \(self.passedUrlLink)"
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
    
    @IBAction func inviteAllButtonClicked(_ sender: UIButton) {
        if (isInviteAllOptionEnabled == false) {
            isInviteAllOptionEnabled = true
            inviteAllButton.setTitleColor(#colorLiteral(red: 0.5063451777, green: 0.5063451777, blue: 0.5063451777, alpha: 1), for: .normal)
            inviteAllRadioButton_Right.alpha = 1
            inviteAllTextButton_Right.alpha = 1
            UIView.animate(withDuration: 0.4) {
                self.sendAllInvitationButtonHeightConstraint.constant = 45
                self.tableViewBottomConstraint.constant = 10
                self.view.layoutIfNeeded()
            }
        }else {
            isInviteAllOptionEnabled = false
            inviteAllButton.setTitleColor(#colorLiteral(red: 0.968627451, green: 0.2745098039, blue: 0.3960784314, alpha: 1), for: .normal)
            inviteAllRadioButton_Right.alpha = 0
            inviteAllTextButton_Right.alpha = 0
            UIView.animate(withDuration: 0.4) {
                self.sendAllInvitationButtonHeightConstraint.constant = 0
                self.tableViewBottomConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
        tableView.reloadData()
    }
    
    @objc func radioButtonClicked(_ sender:UIButton) {
        print("radioButtonClicked...")
        
        if (dataArray[sender.tag].isSelectedForShare == false) {
            dataArray[sender.tag].isSelectedForShare = true
        }else {
            dataArray[sender.tag].isSelectedForShare = false
        }
        tableView.reloadData()
    }
    
    @IBAction func inviteAllRightButtonsClicked(_ sender:UIButton) {
        print("inviteAllRightButtonsClicked...")
        
        if (isInviteAllRadioButtonHighlighted == false) {
            isInviteAllRadioButtonHighlighted = true
            inviteAllRadioButton_Right.setBackgroundImage(UIImage(named: "radio_ON"), for: .normal)
            for i in 0..<dataArray.count {
                dataArray[i].isSelectedForShare = true
            }
        }else {
            isInviteAllRadioButtonHighlighted = false
            inviteAllRadioButton_Right.setBackgroundImage(UIImage(named: "radio_OFF"), for: .normal)
            for i in 0..<dataArray.count {
                dataArray[i].isSelectedForShare = false
            }
        }
        
        tableView.reloadData()
    }
    
    
    @IBAction func sendInvitationToAllButtonClicked(_ sender: Any) {
        print("sendInvitationToAllButtonClicked...")
        
        var allUsersContactsArray:[String] = []
        for i in 0..<dataArray.count {
            if (dataArray[i].isSelectedForShare == true) {
                let clickedUserPhoneNumbers = dataArray[i].phoneNumbers
                if (clickedUserPhoneNumbers.count > 0) {
                    allUsersContactsArray.append(clickedUserPhoneNumbers[0])
                }
            }
        }
        print("allUsersContactsArray ====> \(allUsersContactsArray)")
        if (allUsersContactsArray.count == 0) {
            self.displayAlert(msg: "Please select atleast one contact")
            return
        }
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "\(inviteText) \(self.passedUrlLink)"//"Message Body"
            controller.recipients = allUsersContactsArray
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
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
