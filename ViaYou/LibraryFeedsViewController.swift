//
//  LibraryFeedsViewController.swift
//  ViaYou
//
//  Created by Arya S on 29/09/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import AVFoundation
import MessageUI
import AWSS3
import AWSCore
import AWSCognito
//import DTMessageHUD


class LibraryFeedsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MFMailComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, BecomeGrowthHostPopUpViewControllerDelegate, AddTwoMenuViewControllerDelegate, AddFeedPopUpViewControllerDelegate, UIScrollViewDelegate {
    
    
    
    @IBOutlet weak var collectioView: UICollectionView!
    @IBOutlet weak var bottomPlusButton: UIButton!
    @IBOutlet weak var profilePicButton: UIButton!
    @IBOutlet weak var noFeedPopUpView: UIView!
    @IBOutlet weak var dropDownBaseView: UIView!
    @IBOutlet weak var dropDownBaseViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dropDownButtonContainerBg: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dropdownOverlayButton: UIButton!
    @IBOutlet weak var overlayViewWhenDropDownAppears: UIImageView!
    @IBOutlet weak var profilePicOnDropDownList: UIImageView!
    @IBOutlet weak var profilePicButtonOnDropDownList: UIButton!
    @IBOutlet weak var popUpDontBeShhyButton: UIButton!
    @IBOutlet weak var inviteFriendsPopUpView: UIView!
    @IBOutlet weak var userNameOnDropDown: UILabel!
    @IBOutlet weak var dismissInvitePopUpButton: UIButton!
    @IBOutlet weak var popUpOverlayButton: UIButton!
    @IBOutlet weak var storageIndicatorGreen: UIView!
    @IBOutlet weak var storageIndicatorRed: UIView!
    @IBOutlet weak var storageIndicatorRedWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var storageIndicatorLabel: UILabel!
    @IBOutlet weak var profilePicOnInvitePopUp: UIImageView!
    @IBOutlet weak var profilePicOnNoFeedPopUp: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var plusButtonBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var totalVideoCount: UILabel!
    
    
    
    var dataArray:[FeedDataArrayObject] = []
    var bucketDataArray:BucketDataObject = BucketDataObject([:])
    var subscriptionArray:SubscriptionArrayObject = SubscriptionArrayObject([:])
    var passedProfileImage = UIImage()
    var userId: String = ""
    var invitationUrl: URL!
    var dropdownArray = ["Invite",
                         "My Plan Or Upgrade",
                         "Restore",
                         "Feedback",
                         "Feature Request",
                         "Privacy Policy",
                         "Terms And Conditions",
                         "Sign Out"]
    //AWS setup
    let bucketName = "s3.viayou.net"
    var contentUrl: URL!
    var s3Url: URL!
    
    var streetName: String = ""
    var countryCode: String = ""
    var totalBucketSpace = ""
    var usedBucketSpace = ""
    let profileImageUrlHeader:String = "http://s3.viayou.net/"
    let imagePickerController = UIImagePickerController()
    var lastContentOffset:CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.isHidden = true
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(displayBottomPlusButtonCircularWave), userInfo: nil, repeats: false)
        self.noFeedPopUpView.alpha = 0
        self.inviteFriendsPopUpView.alpha = 0
        userId = Auth.auth().currentUser!.uid
        print(self.passedProfileImage)
        print("Current user name is: \(String(describing: Auth.auth().currentUser?.displayName))")
        if let profileName = Auth.auth().currentUser?.displayName {
            userNameOnDropDown.text = profileName
        }
        else
        {
            userNameOnDropDown.text = "ViaYou User"
        }
        //edit
        let isFileDeleted = self.removeImageFromDocumentsDirectory(imageName: "profile.jpg")
        print("isFileDeleted====>\(isFileDeleted)")
        
        let savedProfileImagePath = self.saveprofilePicToDocumentDirectory(self.passedProfileImage)
        print("savedProfileImagePath====>\(savedProfileImagePath.absoluteString)")
        
        self.uploadProfilePhotoFile(with: "profile", type: "jpg", savedimagePathInDocuments: savedProfileImagePath)
        
        //edit ends
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
                
                self.profilePicOnDropDownList.layer.cornerRadius = self.profilePicOnDropDownList.frame.size.width/2.0
                self.profilePicOnDropDownList.clipsToBounds = true
                //self.profilePicOnDropDownList.image = self.passedProfileImage
                self.profilePicButtonOnDropDownList.setBackgroundImage(image, for: .normal)
                if (__CGSizeEqualToSize(self.profilePicButtonOnDropDownList.currentBackgroundImage?.size ?? CGSize.zero, CGSize.zero)) {
                    print("EMPTY IMAGE")
                    self.profilePicButtonOnDropDownList.setBackgroundImage(UIImage(named: "defaultProfilePic"), for: .normal)
                    
                }
                
                self.profilePicOnInvitePopUp.image = image
                self.profilePicOnInvitePopUp.layer.cornerRadius = self.profilePicOnInvitePopUp.frame.size.width/3.0
                self.profilePicOnInvitePopUp.clipsToBounds = true
                if (__CGSizeEqualToSize(self.profilePicOnInvitePopUp.image?.size ?? CGSize.zero, CGSize.zero)) {
                    print("EMPTY IMAGE")
                    self.profilePicOnInvitePopUp.image = UIImage(named: "defaultProfilePic")
                    
                }
                
                self.profilePicOnNoFeedPopUp.image = image
                self.profilePicOnNoFeedPopUp.layer.cornerRadius = self.profilePicOnNoFeedPopUp.frame.size.width/3.0
                self.profilePicOnNoFeedPopUp.clipsToBounds = true
                if (__CGSizeEqualToSize(self.profilePicOnNoFeedPopUp.image?.size ?? CGSize.zero, CGSize.zero)) {
                    print("EMPTY IMAGE")
                    self.profilePicOnInvitePopUp.image = UIImage(named: "defaultProfilePic")
                    
                }
            }, failureBlock: { (request, response, error) in
            })
        }
        
        collectioView.reloadData()
        //  getResponseFromJSONFile()
        getBucketInfo()
        getTotalStorageSpace()
        DispatchQueue.main.async {
            self.popUpDontBeShhyButton.addAppGradient()
        }
        
    }
    
    //get aws s3 bucket info
    func getBucketInfo() {
        //aws configuration
        let accessKey = "AKIA6JJLBT2ZHL52PQLQ"
        let secretKey = "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"
        //let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast2, identityPoolId:"us-east-2:3d024c5d-faba-4922-85e4-9b3d2d9581c9")
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USEast2, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        s3Url = AWSS3.default().configuration.endpoint.url
        let s3 = AWSS3.default()
        let getReq : AWSS3ListObjectsRequest = AWSS3ListObjectsRequest()
        getReq.bucket = self.bucketName
        print(getReq.bucket)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        getReq.prefix = "posts/\(uid)" //Folder path to get size
        print(getReq.prefix)
        print(getReq)
        
        let downloadGroup = DispatchGroup()
        downloadGroup.enter()
        
        s3.listObjects(getReq) { (listObjects, error) in
            print(getReq)
            print(listObjects)
            var total : Int = 0
            if listObjects?.contents != nil {
                for object in (listObjects?.contents)! {
                    do {
                        let s3Object : AWSS3Object = object
                        total += (s3Object.size?.intValue)!
                    }
                }
                
                print(total)
                
                let byteCount = total // replace with data.count
                let bcf = ByteCountFormatter()
                bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
                bcf.countStyle = .file
                let string = bcf.string(fromByteCount: Int64(byteCount))
                print("File size in MB : \(string)")
                
                self.usedBucketSpace = "\(string)"
                if (self.usedBucketSpace.contains(" ")) {
                    self.usedBucketSpace = self.usedBucketSpace.components(separatedBy: " ").first ?? ""
                }
                self.setBucketSizeGraph()
            }
            else {
                print("contents is blank")
                print(error.debugDescription)
            }
        }
    }
    //get aws s3 bucket info ends
    
    //get total bucket size
    func getTotalStorageSpace() {
        ApiManager().getTotalBucketSize { (response, error) in
            if error == nil {
                print(response.message)
                self.bucketDataArray = response.data
                print("Total storage space = \(self.bucketDataArray.storage)")
                self.totalBucketSpace = "\((Float(self.bucketDataArray.storage) ?? 0.0)*1000.0)"
                print("self.totalBucketSpace = \(self.totalBucketSpace)")
                
                self.setBucketSizeGraph()
                
            }
            else {
                print(error.debugDescription)
            }
        }
    }
    //get total bucket size ends
    
    func setBucketSizeGraph() {
        print("self.usedBucketSpace** = \(self.usedBucketSpace)")
        print("self.totalBucketSpace** = \(self.totalBucketSpace)")
        
        if (self.totalBucketSpace.count > 0 && self.usedBucketSpace.count > 0) {
            let usedBucketSpaceValue  = Float(self.usedBucketSpace) ?? 0.0
            let totalBucketSpaceValue = Float(self.totalBucketSpace) ?? 0.0
            print("usedBucketSpaceValue = \(usedBucketSpaceValue)")
            print("totalBucketSpaceValue = \(totalBucketSpaceValue)")
            
            if (totalBucketSpaceValue > 0) {
                let percentage = (usedBucketSpaceValue/totalBucketSpaceValue)*100
                print("percentage = \(percentage)")
                
                DispatchQueue.main.async {
                    let storageIndicatorGreenWidth = self.storageIndicatorGreen.frame.size.width
                    let storageIndicatorRedWidth   = self.storageIndicatorRed.frame.size.width
                    
                    print("storageIndicatorGreenWidth = \(storageIndicatorGreenWidth)")
                    print("storageIndicatorRedWidth = \(storageIndicatorRedWidth)")
                    
                    self.storageIndicatorRedWidthConstraint.constant = CGFloat(percentage)
                    
                }
            }
            
            let remainingSpace = totalBucketSpaceValue - usedBucketSpaceValue
            print("remainingSpace = \(remainingSpace)")
            
            let remainingSpaceInMB = Float(remainingSpace) / 1000.0
            let roundedValue = remainingSpaceInMB.rounded(.toNearestOrAwayFromZero)
            
            DispatchQueue.main.async {
                
                self.storageIndicatorLabel.text = "\(remainingSpaceInMB) GB Free"
            }
        }
        else
        {
            DispatchQueue.main.async {
                let storageIndicatorRedWidth   = self.storageIndicatorRed.frame.size.width
                print("storageIndicatorRedWidth = \(storageIndicatorRedWidth)")
                self.storageIndicatorRedWidthConstraint.constant = CGFloat(0.0)
                self.storageIndicatorLabel.text = "2 GB Free"
            }
        }
    }
    
    
    @objc func displayBottomPlusButtonCircularWave() {
        self.view.layoutIfNeeded()
        bottomPlusButton.layoutIfNeeded()
        
        let wave = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        wave.backgroundColor = self.view.themeRedColor()
        wave.layer.cornerRadius = wave.frame.size.width/2.0
        wave.clipsToBounds = true
        self.view.addSubview(wave)
        self.view.bringSubviewToFront(bottomPlusButton)
        wave.center = bottomPlusButton.center
        
        UIView.animate(withDuration: 2.0, delay: 0.2, options: .curveEaseIn, animations: {
            wave.transform = CGAffineTransform(scaleX: 100.0, y: 100.0)
            wave.alpha = 0
        }) { (completed) in
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getSubscriptionPlanResponseFromAPI()
        self.dataArray.removeAll()
        self.tableView.reloadData()
        getResponseFromJSONFile()
        self.dropDownBaseView.alpha = 0
        self.dropdownOverlayButton.alpha = 0
        self.popUpOverlayButton.alpha = 0
        s3Url = AWSS3.default().configuration.endpoint.url
        
        overlayViewWhenDropDownAppears.alpha = 0
        UserDefaults.standard.set(false, forKey: "isTappedFromSingleVideo")
        
    }
    
    func getSubscriptionPlanResponseFromAPI() {
        ApiManager().getSubscriptionDetailsAPI { (responseDict, error) in
            if error == nil {
                print(responseDict.message)
                self.subscriptionArray = responseDict.data
                print(self.subscriptionArray.type)
                print(self.subscriptionArray.expiry.getReadableDateString())
                
                let type = self.subscriptionArray.type
                if type == "SOLO" {
                    print("0")
                    DefaultWrapper().setPaymentTypePurchased(type: 0)
                }
                else if type == "GROWTH" {
                    print("1")
                    DefaultWrapper().setPaymentTypePurchased(type: 1)
                }
                else if type == "PRO" {
                    print("2")
                    DefaultWrapper().setPaymentTypePurchased(type: 2)
                }
                else {
                    print("-1")
                    DefaultWrapper().setPaymentTypePurchased(type: -1)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            else
            {
                print(error.debugDescription)
            }
            
        }
    }
    
    func getResponseFromJSONFile() {
        //        readResponseFromFileForTest()
        //        return
        //
        
        ApiManager().getAllPostsAPI(from: "0", size: "100") { (responseDict, error) in
            if error == nil {
                print("getNewsFeedsForYouResponseFromAPI :: responseDict\(responseDict.message)")
                if responseDict.data.count == 0 {
                    
                    DispatchQueue.main.async {
                        self.noFeedPopUpView.alpha = 1
                        self.collectioView.reloadData()
                        
                    }
                }
                else {
                    
                    print("getNewsFeedsForYouResponseFromAPI :: responseDict\(responseDict.success)")
                    for i in 0..<responseDict.data.count {
                        print("Total video count=====> \(responseDict.data.count)")
                        if responseDict.data.count == 1 {
                            DispatchQueue.main.async {
                                self.totalVideoCount.text = "\(responseDict.data.count) video"
                            }                        }
                        else {
                            DispatchQueue.main.async {
                                self.totalVideoCount.text = "\(responseDict.data.count) videos"
                            }
                        }
                        let indexDict = responseDict.data[i]
                        indexDict.isInfoPopUpDisplaying = false
                        self.dataArray.append(indexDict)
                        
                        /*
                         self.dataArray.append(indexDict)
                         self.dataArray.append(indexDict)
                         self.dataArray.append(indexDict)
                         self.dataArray.append(indexDict)
                         self.dataArray.append(indexDict)
                         self.dataArray.append(indexDict)
                         self.dataArray.append(indexDict)
                         self.dataArray.append(indexDict)
                         self.dataArray.append(indexDict)
                         self.dataArray.append(indexDict)
                         self.dataArray.append(indexDict)
                         self.dataArray.append(indexDict)
                         self.dataArray.append(indexDict)
                         self.dataArray.append(indexDict)
                         self.dataArray.append(indexDict)
                         self.dataArray.append(indexDict)
                         self.dataArray.append(indexDict)
                         self.dataArray.append(indexDict)
                         self.dataArray.append(indexDict)
                         */
                        
                        print("getLibraryResponseFromAPI :: filename\(indexDict.fileName)")
                    }
                    self.loadAllVideoImagesForDataArray()
                    //  self.loadVideoSize()
                    DispatchQueue.main.async {
                        self.noFeedPopUpView.alpha = 0
                        self.collectioView.reloadData()
                        
                    }
                    
                }
            }
                
            else {
                print(error?.localizedDescription)
            }
        }
    }
    
    var isBottomButtonAnimationInProgress:Bool = false
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if ((self.lastContentOffset-scrollView.contentOffset.y) > 50) {
            print("Scrolling Up...")
            
            if (isBottomButtonAnimationInProgress == false) {
                isBottomButtonAnimationInProgress = true
                UIView.animate(withDuration: 0.4, animations: {
                    self.plusButtonBottomSpaceConstraint.constant = 60
                    self.view.layoutIfNeeded()
                }) { (completed) in
                    self.isBottomButtonAnimationInProgress = false
                }
            }
            
        } else if ((self.lastContentOffset-scrollView.contentOffset.y) < -50) {
            print("Scrolling Down...")
            if (isBottomButtonAnimationInProgress == false) {
                isBottomButtonAnimationInProgress = true
                UIView.animate(withDuration: 0.4, animations: {
                    self.plusButtonBottomSpaceConstraint.constant = -200
                    self.view.layoutIfNeeded()
                }) { (completed) in
                    self.isBottomButtonAnimationInProgress = false
                }
            }
        }
        
        if (abs(self.lastContentOffset-scrollView.contentOffset.y) > 50) {
            self.lastContentOffset = scrollView.contentOffset.y;
        }
        
        //print(" scrollView.contentOffset.y ====> \( scrollView.contentOffset.y)")
        
        if (scrollView.contentOffset.y == 0) {
            isBottomButtonAnimationInProgress = true
            UIView.animate(withDuration: 0.4, animations: {
                self.plusButtonBottomSpaceConstraint.constant = 60
                self.view.layoutIfNeeded()
            }) { (completed) in
                self.isBottomButtonAnimationInProgress = false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LibraryFeedsCollectionViewCell", for: indexPath) as! LibraryFeedsCollectionViewCell
        cell.configureCell(dataDict: dataArray[indexPath.row])
        
        cell.infoButton.tag = indexPath.row
        cell.infoButton.addTarget(self, action: #selector(infoButtonClicked), for: UIControl.Event.touchUpInside)
        
        cell.deleteVideoButton.tag = indexPath.row
        cell.deleteVideoButton.addTarget(self, action: #selector(deleteVideoButtonClicked), for: UIControl.Event.touchUpInside)
        
        cell.shareButton.tag = indexPath.row
        cell.shareButton.addTarget(self, action: #selector(shareButtonClicked), for: UIControl.Event.touchUpInside)
        
        cell.infoSliderCloseButton.tag = indexPath.row
        cell.infoSliderCloseButton.addTarget(self, action: #selector(infoSliderCloseButtonClicked), for: UIControl.Event.touchUpInside)
        
        return cell
    }
    
    @objc func deleteVideoButtonClicked(_ sender:UIButton) {
        print(dataArray[sender.tag]._id)
        let tappedPostId = dataArray[sender.tag]._id
        ApiManager().deletePostAPI(postId: tappedPostId) { (response, error) in
            if error == nil {
                print(response.success)
                print(response.message)
                
                DispatchQueue.main.async {
                    self.dataArray.remove(at: sender.tag)
                    self.collectioView.reloadData()
                }
            }
            else
            {
                print(error.debugDescription)
            }
        }
        
    }
    
    @objc func shareButtonClicked(_ sender:UIButton) {
        print(dataArray[sender.tag]._id)
        
        let userID = dataArray[sender.tag].user._id
        let videoName = dataArray[sender.tag].fileName
        var videUrlString = "http://s3.viayou.net/posts/\(userID)/\(videoName)"
        videUrlString = videUrlString.replacingOccurrences(of: " ", with: "%20")
        UserDefaults.standard.set(true, forKey: "isTappedFromSingleVideo")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "ContactsViewController") as! ContactsViewController
        nextVC.passedUrlLink = videUrlString
        let navVC = UINavigationController(rootViewController: nextVC)
        navVC.isNavigationBarHidden = true
        self.navigationController?.pushViewController(nextVC, animated: true)
        
        
    }
    
    @objc func infoButtonClicked(_ sender:UIButton) {
        print("infoButtonClicked...")
        if (dataArray[sender.tag].isInfoPopUpDisplaying == false) {
            dataArray[sender.tag].isInfoPopUpDisplaying = true
        }else {
            dataArray[sender.tag].isInfoPopUpDisplaying = false
        }
        collectioView.reloadData()
    }
    
    @objc func infoSliderCloseButtonClicked(_ sender:UIButton) {
        print("infoSliderCloseButtonClicked...")
        if (dataArray[sender.tag].isInfoPopUpDisplaying == false) {
            dataArray[sender.tag].isInfoPopUpDisplaying = true
        }else {
            dataArray[sender.tag].isInfoPopUpDisplaying = false
        }
        collectioView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.size.width/2.0)-10
        return CGSize(width: cellWidth, height: cellWidth*1.41)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt...")
        selectRow(selectedRow: indexPath.row)
        //        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //        let nextVC = storyBoard.instantiateViewController(withIdentifier: "NoScreenCastsPopUpViewController") as! NoScreenCastsPopUpViewController
        //        nextVC.modalPresentationStyle = .overCurrentContext
        //        let navVC = UINavigationController(rootViewController: nextVC)
        //        navVC.isNavigationBarHidden = true
        //        self.navigationController?.present(navVC, animated: false, completion: nil)
    }
    
    func selectRow(selectedRow:Int) {
        
        if (dataArray.count>selectedRow) {
            let userID = dataArray[selectedRow].user._id
            let videoName = dataArray[selectedRow].fileName
            let videoId = dataArray[selectedRow]._id
            var videUrlString = "http://s3.viayou.net/posts/\(userID)/\(videoName)"
            videUrlString = videUrlString.replacingOccurrences(of: " ", with: "%20")
            
            let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "VideoViewController") as! VideoViewController
            nextVC.videoUrl = videUrlString
            nextVC.postId = videoId
            nextVC.modalPresentationStyle = .overCurrentContext
            self.present(nextVC, animated: true, completion: nil)
        }
        //        if (dataArray.count>selectedRow) {
        //            let userID = dataArray[selectedRow].user._id
        //            let videoName = dataArray[selectedRow].fileName
        //            var videUrlString = "https://dev-promptchu.s3.us-east-2.amazonaws.com/posts/\(userID)/\(videoName)"
        //            videUrlString = videUrlString.replacingOccurrences(of: " ", with: "%20")
        //            UserDefaults.standard.set(true, forKey: "isTappedFromSingleVideo")
        //            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //            let nextVC = storyBoard.instantiateViewController(withIdentifier: "ContactsViewController") as! ContactsViewController
        //            nextVC.passedUrlLink = videUrlString
        //            let navVC = UINavigationController(rootViewController: nextVC)
        //            navVC.isNavigationBarHidden = true
        //            self.navigationController?.pushViewController(nextVC, animated: true)
        //        }
    }
    
    @IBAction func plusButtonClicked() {
        /*
         self.inviteFriendsPopUpView.alpha = 1
         self.popUpOverlayButton.alpha = 0.5
         */
        
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let nextVC = storyBoard.instantiateViewController(withIdentifier: "AddFeedPopUpViewController") as! AddFeedPopUpViewController
//        nextVC.modalPresentationStyle = .overCurrentContext
//        self.present(nextVC, animated: false, completion: nil)

        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "AddTwoMenuViewController") as! AddTwoMenuViewController
        nextVC.modalPresentationStyle = .overCurrentContext
        nextVC.delegate = self
        self.present(nextVC, animated: false, completion: nil)
        
    }
    
    func goToContactsVCToInvite() {
        
        UserDefaults.standard.set(false, forKey: "isTappedFromSingleVideo")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let link = URL(string: "https://viayou.page.link/?invitedby=\(uid)")
        let referralLink = DynamicLinkComponents(link: link!, domainURIPrefix: "https://viayou.page.link")
        
        referralLink!.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.viayou.ViaYouApp")
        referralLink!.iOSParameters?.minimumAppVersion = "1.0"
        referralLink!.iOSParameters?.appStoreID = "123456789"
        
        referralLink!.androidParameters = DynamicLinkAndroidParameters(packageName: "com.example.android")
        referralLink!.androidParameters?.minimumVersion = 125
        
        referralLink!.shorten { (shortURL, warnings, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.invitationUrl = shortURL!
            print(self.invitationUrl.absoluteString)
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "ContactsViewController") as! ContactsViewController
            nextVC.passedUrlLink = self.invitationUrl.absoluteString
            let navVC = UINavigationController(rootViewController: nextVC)
            navVC.isNavigationBarHidden = true
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    //        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
    //        let nextVC = storyBoard.instantiateViewController(withIdentifier: "LessSpacePopUpViewController") as! LessSpacePopUpViewController
    //        nextVC.modalPresentationStyle = .overCurrentContext
    //        let navVC = UINavigationController(rootViewController: nextVC)
    //        navVC.isNavigationBarHidden = true
    //        self.navigationController?.present(navVC, animated: false, completion: nil)
    
    //    func loadVideoSize() {
    //        for i in 0..<dataArray.count {
    //            let userID = dataArray[i].user._id
    //            let videoName = dataArray[i].fileName
    //            var videUrlString = "https://dev-promptchu.s3.us-east-2.amazonaws.com/posts/\(userID)/\(videoName)"
    //            videUrlString = videUrlString.replacingOccurrences(of: " ", with: "%20")
    //            print("videUrlString :: \(videUrlString)")
    //
    //            getDownloadSize(url: URL(string: videUrlString)!) { (size, error) in
    //                if (error == nil) {
    //                    DispatchQueue.main.async {
    //                        let size = "\(size) KB"
    //                        self.dataArray[i].videoFileSize = size
    //                        self.collectioView.reloadData()
    //                    }
    //                }
    //            }
    //
    //        }
    //    }
    
    func getDownloadSize(url: URL, completion: @escaping (Int64, Error?) -> Void) {
        let timeoutInterval = 5.0
        var request = URLRequest(url: url,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: timeoutInterval)
        request.httpMethod = "HEAD"
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            var contentLength = response?.expectedContentLength ?? NSURLSessionTransferSizeUnknown
            contentLength = contentLength/Int64(1000.0)
            completion(contentLength, error)
            }.resume()
    }
    
    
    func loadAllVideoImagesForDataArray() {
        for i in 0..<dataArray.count {
            let userID = dataArray[i].user._id
            let videoName = dataArray[i].fileName
            var videUrlString = "http://s3.viayou.net/posts/\(userID)/\(videoName)"
            videUrlString = videUrlString.replacingOccurrences(of: " ", with: "%20")
            print("videUrlString :: \(videUrlString)")
            
            //get duration time
            let asset = AVAsset(url: URL(string: videUrlString)!)
            let duration = asset.duration
            let durationTime = CMTimeGetSeconds(duration)
            print("durationTime====>\(durationTime)")
            //get duration time ends
            DispatchQueue.global(qos: .userInitiated).async {
                let image = self.previewImageFromVideo(url: URL(string: videUrlString)! as NSURL)
                if (image != nil) {
                    self.dataArray[i].user.videoImage = image!
                    self.dataArray[i].user.duration = String(durationTime)
                    self.dataArray[i].fileName = videoName
                    DispatchQueue.main.async {
                        print("****Loaded image at index :: \(i)")
                        self.collectioView.reloadData()
                    }
                }
            }
            
            //get video size
            
            getDownloadSize(url: URL(string: videUrlString)!) { (size, error) in
                if (error == nil) {
                    DispatchQueue.main.async {
                        let size = "\(size) KB"
                        self.dataArray[i].videoFileSize = size
                        self.collectioView.reloadData()
                    }
                }
            }
            
            //get video size ended
        }
    }
    
    func previewImageFromVideo(url: NSURL) -> UIImage? {
        let url = url as URL
        let request = URLRequest(url: url)
        let cache = URLCache.shared
        
        if
            let cachedResponse = cache.cachedResponse(for: request),
            let image = UIImage(data: cachedResponse.data)
        {
            return image
        }
        
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        var image: UIImage?
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            image = UIImage(cgImage: cgImage)
        } catch { }
        
        if
            let image = image,
            let data = image.pngData(),
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        {
            let cachedResponse = CachedURLResponse(response: response, data: data)
            
            cache.storeCachedResponse(cachedResponse, for: request)
        }
        
        return image
    }
    
    @IBAction func dismissPopUp(_ sender: Any) {
        self.noFeedPopUpView.alpha = 0
        //self.navigationController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func dismissInvitePopUp(_ sender: Any) {
        self.inviteFriendsPopUpView.alpha = 0
        self.popUpOverlayButton.alpha = 0
    }
    
    @IBAction func inviteFriendsButtonClicked(_ sender: Any) {
        self.inviteFriendsPopUpView.alpha = 0
        self.popUpOverlayButton.alpha = 0
        goToContactsVCToInvite()
    }
    
    
    
    @IBAction func profilePicButtonClicked(_ sender: Any) {
        self.dropDownBaseViewHeightConstraint.constant = 0.0001
        self.dropdownOverlayButton.alpha = 1
        self.dropDownBaseView.alpha = 1
        self.overlayViewWhenDropDownAppears.alpha = 0.4
        UIView.animate(withDuration: 0.4) {
            self.dropDownBaseViewHeightConstraint.constant = 480
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func dropDownOverlayButtonClicked(_ sender: Any) {
        UIView.animate(withDuration: 0.4, animations: {
            self.dropDownBaseViewHeightConstraint.constant = 0.0001
            self.view.layoutIfNeeded()
        }) { (completed) in
            self.dropdownOverlayButton.alpha = 0
            self.dropDownBaseView.alpha = 0
            self.overlayViewWhenDropDownAppears.alpha = 0
        }
    }
    
    //MARK:- TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropdownArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileDropdownTableViewCell", for: indexPath) as! ProfileDropdownTableViewCell
        cell.configureCell(dataArray: dropdownArray, index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dropDownOverlayButtonClicked((Any).self)
        
        if(indexPath.row == 0) {
            self.inviteFriendsPopUpView.alpha = 1
            self.popUpOverlayButton.alpha = 0.5
        }
        else if (indexPath.row == 1) {
            let paymentTypePurchased = DefaultWrapper().getPaymentTypePurchased()
            print("paymentTypePurchased ====> \(paymentTypePurchased)")
            
            if (paymentTypePurchased == 1 || paymentTypePurchased == 2) {
                self.becomeGrowthHostPopUpVC_SubscriptionBaseViewControllerrButtonClicked()
            }else {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextVC = storyBoard.instantiateViewController(withIdentifier: "BecomeGrowthHostPopUpViewController") as! BecomeGrowthHostPopUpViewController
                nextVC.modalPresentationStyle = .overCurrentContext
                nextVC.delegate = self
                self.present(nextVC, animated: false, completion: nil)
            }
            
        }
        else if (indexPath.row == 2) {
            // if (index == 2) {
            let paymentTypePurchased = DefaultWrapper().getPaymentTypePurchased()
            print("paymentTypePurchased ====> \(paymentTypePurchased)")
            
            if (paymentTypePurchased == 1 || paymentTypePurchased == 2) {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextVC = storyBoard.instantiateViewController(withIdentifier: "DeletedVideosViewController") as! DeletedVideosViewController
                nextVC.modalPresentationStyle = .overCurrentContext
                self.navigationController?.pushViewController(nextVC, animated: true)
                
            }else {
                print("Restore option not available...")
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextVC = storyBoard.instantiateViewController(withIdentifier: "BecomeGrowthHostPopUpViewController") as! BecomeGrowthHostPopUpViewController
                nextVC.modalPresentationStyle = .overCurrentContext
                nextVC.delegate = self
                self.present(nextVC, animated: false, completion: nil)
            }
            //   }
            
            
        }
                    else if (indexPath.row == 3) {
                        if let url = URL(string: "http://www.blaquefracturetechnologies.com/") {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url, options: [:])
                            }
            }
            
                    }
        else if (indexPath.row == 4) {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "FeatureResuestPage_1ViewController") as! FeatureResuestPage_1ViewController
            nextVC.modalPresentationStyle = .overCurrentContext
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
            //        else if (indexPath.row == 6) {
            //            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            //            let nextVC = storyBoard.instantiateViewController(withIdentifier: "BecomeGrowthHostPopUpViewController") as! BecomeGrowthHostPopUpViewController
            //            nextVC.modalPresentationStyle = .overCurrentContext
            //            nextVC.delegate = self
            //            self.present(nextVC, animated: false, completion: nil)
            //        }
        else if (indexPath.row == 5) {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        else if (indexPath.row == 6) {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "TermsNConditionsViewController") as! TermsNConditionsViewController
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        else if (indexPath.row == 7) {
            UserDefaults.standard.set(false, forKey: "IsUserLoggedIn")
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "NewLaunchViewController") as! NewLaunchViewController
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        
    }
    
    func becomeGrowthHostPopUpVC_SubscriptionBaseViewControllerrButtonClicked() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "SubscriptionBaseViewController") as! SubscriptionBaseViewController
        let navVC = UINavigationController(rootViewController: nextVC)
        navVC.isNavigationBarHidden = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }

    func AddFeedPopUpViewController_videomergeButtonClicked() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "VideoRecordVC") as! VideoRecordVC
        let navVC = UINavigationController(rootViewController: nextVC)
        navVC.isNavigationBarHidden = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    func AddTwoMenuViewController_screencastButtonClicked() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "AddFeedPopUpViewController") as! AddFeedPopUpViewController
        nextVC.modalPresentationStyle = .overCurrentContext
        self.present(nextVC, animated: false, completion: nil)
        //        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //        let nextVC = storyBoard.instantiateViewController(withIdentifier: "AddFeedPopUpViewController") as! AddFeedPopUpViewController
        //        let navVC = UINavigationController(rootViewController: nextVC)
        //        navVC.isNavigationBarHidden = true
        //        self.navigationController?.pushViewController(nextVC, animated: false)
    }
    func AddTwoMenuViewController_videomergeButtonClicked() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "VideoRecordVC") as! VideoRecordVC
//        let navVC = UINavigationController(rootViewController: nextVC)
//        navVC.isNavigationBarHidden = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func becomeGrowthHostPopUpVC_UpgradeAndSubscriptionBaseViewControllerButtonClicked() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "UpgradeAndSubscriptionBaseViewController") as! UpgradeAndSubscriptionBaseViewController
        nextVC.isFromViewAllButtonClick = true
        let navVC = UINavigationController(rootViewController: nextVC)
        navVC.isNavigationBarHidden = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    //MARK:- Select profile picture
    @IBAction func dropdownProfilePicButtonClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Choose your option", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            DispatchQueue.main.async {
                self.chooseImage(source: .camera)
            }
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { action in
            DispatchQueue.main.async {
                self.chooseImage(source: .photoLibrary)
            }
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func chooseImage(source:UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.mediaTypes = ["public.image"]
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.sourceType = source
        self.navigationController?.present(pickerController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        var selectedImage:UIImage!
        if let image = info[.editedImage] as? UIImage {
            selectedImage = image
        }else if let image = info[.originalImage] as? UIImage {
            selectedImage = image
        }
        
        self.dismiss(animated: true, completion: {
            let isFileDeleted = self.removeImageFromDocumentsDirectory(imageName: "profile.jpg")
            print("isFileDeleted====>\(isFileDeleted)")
            
            let savedProfileImagePath = self.saveprofilePicToDocumentDirectory(selectedImage)
            print("savedProfileImagePath====>\(savedProfileImagePath.absoluteString)")
            
            self.uploadProfilePhotoFile(with: "profile", type: "jpg", savedimagePathInDocuments: savedProfileImagePath)
            
        })
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func removeImageFromDocumentsDirectory(imageName:String)->Bool {
        var isFileDeleted:Bool = false
        let filemanager = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as NSString
        let destinationPath = documentsPath.appendingPathComponent(imageName)
        if filemanager.fileExists(atPath: destinationPath) {
            do {
                try filemanager.removeItem(atPath: destinationPath)
                print("Deleted \(imageName) from documents directory")
                isFileDeleted = true
            }
            catch let error {
                print("Not deleted \(imageName) from documents directory :: \(error.localizedDescription)")
                isFileDeleted = false
            }
        }
        return isFileDeleted
    }
    
    func saveprofilePicToDocumentDirectory(_ chosenImage: UIImage) -> URL {
        let directoryPath =  NSHomeDirectory().appending("/Documents/")
        if !FileManager.default.fileExists(atPath: directoryPath) {
            do {
                try FileManager.default.createDirectory(at: NSURL.fileURL(withPath: directoryPath), withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }
        
        let filename = "profile.jpg"
        let filepath = directoryPath.appending(filename)
        let url = NSURL.fileURL(withPath: filepath)
        do {
            try chosenImage.jpegData(compressionQuality: 1.0)?.write(to: url, options: .atomic)
            return url
            
        } catch {
            print(error)
            print("file cant not be save at path \(filepath), with error : \(error)");
            return url
        }
    }
    
    func uploadProfilePhotoFile(with resource: String, type: String, savedimagePathInDocuments: URL)
    {
        
        autoreleasepool{
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    //DTMessageHUD.hud()
                    
                    let key = "\(resource).\(type)"
                    print("key====>\(key)")
                    let request = AWSS3TransferManagerUploadRequest()!
                    request.bucket = self.bucketName
                    self.userId = Auth.auth().currentUser!.uid
                    request.key = "users/"+"\(String(describing: self.userId))"+"/"+key
                    print("self.userID====>\(self.userId)")
                    print("request.key====>\(request.key ?? "No request.key")")
                    
                    request.body = savedimagePathInDocuments
                    request.acl = .publicReadWrite
                    print("savedimagePathInDocuments====>\(savedimagePathInDocuments)")
                    
                    let transferManager = AWSS3TransferManager.default()
                    transferManager.upload(request).continueWith(executor: AWSExecutor.mainThread()) { (task) -> Any? in
                        DispatchQueue.main.async {
                            //  DTMessageHUD.dismiss()
                        }
                        if let error = task.error {
                            print("Upload error occurred :: error ====> \(error.localizedDescription)")
                            // DTMessageHUD.dismiss()
                        }
                        if task.result != nil {
                            //  DTMessageHUD.dismiss()
                            
                            let profileImageOnlineUrl = "\(self.profileImageUrlHeader)users/\(self.userId)/\(key)"
                            print("profileImageOnlineUrl====>\(profileImageOnlineUrl)")
                            
                            
                            JMImageCache.shared()?.removeImage(for: URL(string: profileImageOnlineUrl))
                            DispatchQueue.main.async {
                                JMImageCache.shared()?.image(for: URL(string: profileImageOnlineUrl), completionBlock: { (image) in
                                    
                                    self.profilePicButton.setBackgroundImage(image, for: .normal)
                                    self.profilePicButtonOnDropDownList.setBackgroundImage(image, for: .normal)
                                    self.profilePicOnInvitePopUp.image = image
                                    self.profilePicOnNoFeedPopUp.image = image
                                    
                                    
                                }, failureBlock: { (request, response, error) in
                                })
                                
                            }
                            print("Upload success \(key)")
                            let alertController = UIAlertController(title: "ViaYou", message: ("Uploaded profile pic"), preferredStyle:.alert)
                            let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.cancel) {
                                UIAlertAction in}
                            alertController.addAction(action)
                            DispatchQueue.main.async {
                                self.activityIndicator.isHidden = true
                                self.activityIndicator.stopAnimating()
                               // self.present(alertController, animated: true, completion:nil)
                                
                            }
                            let contentUrl = self.s3Url.appendingPathComponent(self.bucketName).appendingPathComponent(key)
                            self.contentUrl = contentUrl
                        }
                        return nil
                    }
                }
            }
        }
    }
    
}

