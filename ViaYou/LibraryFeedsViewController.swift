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


class LibraryFeedsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MFMailComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, BecomeGrowthHostPopUpViewControllerDelegate, AddTwoMenuViewControllerDelegate, AddFeedPopUpViewControllerDelegate, TrialPeriodEndedViewControllerDelegate, UIScrollViewDelegate {
    
    
    
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
    @IBOutlet weak var remainingDaysLabel: UILabel!
    
    //    @IBOutlet weak var storageIndicatorGreenOnDropDown: UIView!
    //    @IBOutlet weak var storageIndicatorRedOnDropDown: UIView!
    //    @IBOutlet weak var storageIndicatorLabelOnDropDown: UILabel!
    //    @IBOutlet weak var storageIndicatorRedOnDropDownWidthConstraint: NSLayoutConstraint!
    var isSelectingProfilePictureFromImagePicker:Bool = false
    var dataDict:UserDataDictionary = UserDataDictionary([:])
    
    
    
    @IBOutlet weak var uploadProgressBarContainer: UIView!
    @IBOutlet weak var uploadProgressBarHeightConstraint: NSLayoutConstraint!
    let uploadBarStatusNotification = Notification.Name("uploadBarStatusNotification")
    @IBOutlet weak var uploadProgressFillBarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var uploadPercentageLabel: UILabel!
    @IBOutlet weak var uploadTextOverlayProgressFillBarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressArrowImageView: UIImageView!
    let uploadCompleteStatusNotification = Notification.Name("uploadCompleteStatusNotification")
    
    
    var dataArray:[FeedDataArrayObject] = []
    var bucketDataArray:BucketDataObject = BucketDataObject([:])
    var subscriptionArray:SubscriptionArrayObject = SubscriptionArrayObject([:])
    var passedProfileImage = UIImage()
    var userId: String = ""
    var invitationUrl: URL!
    //    var dropdownArray = ["Invite",
    //                         "My Plan Or Upgrade",
    //                         "Remove Watermark",
    //                         "Restore",
    //                         "Feedback",
    //                         "Feature Request",
    //                         "Privacy Policy",
    //                         "Mobile Terms Of Use",
    //                         "High Resolution",
    //                         "Sign Out"]
    var dropdownArray = ["Invite",
                         "About Watermark",
                         "Archive",
                         "Feedback",
                         "Feature Request",
                         "Resolution",
                         "Sign Out"]
    var dropdownArrayAfterPurchase = ["Invite",
                                      "My Plan Or Upgrade",
                                      "Add Watermark",
                                      "Restore",
                                      "Feedback",
                                      "Feature Request",
                                      "Privacy Policy",
                                      "Mobile Terms Of Use",
                                      "High Resolution",
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
    var watermarkUrlHeader = "http://s3.viayou.net/"
    let imagePickerController = UIImagePickerController()
    var lastContentOffset:CGFloat = 0.0
    var bucketSpace: Int = 0
    
    var isSelectingVideo: Bool = false
    var selectedVideo: URL!
    
    
    var fetchStart:Int = 0
    var isDataFetchInProgress:Bool = false
    var mutableVideoURL: URL!
    
    @objc func handleNotification(withNotification notification : NSNotification) {
        if (notification.name == uploadBarStatusNotification) {
            print("uploadBarStatusNotification...")
            let loadingImages = (1...4).map { UIImage(named: "progress_\($0)")! }
            progressArrowImageView.animationImages = loadingImages
            progressArrowImageView.animationDuration = 1.0
            progressArrowImageView.startAnimating()
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.4, animations: {
                    self.uploadProgressBarContainer.layoutIfNeeded()
                    self.uploadProgressBarHeightConstraint.constant = 60
                })
            }
            
            let percentage = notification.object as? CGFloat ?? 0.0
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.1, animations: {
                    print("percentage/100.0 ...  \(percentage) || \(percentage/100.0)")
                    
                    self.uploadProgressBarContainer.layoutIfNeeded()
                    self.uploadProgressFillBarWidthConstraint = self.uploadProgressFillBarWidthConstraint.setMultiplier(multiplier: percentage/100.0)
                    self.uploadTextOverlayProgressFillBarWidthConstraint = self.uploadTextOverlayProgressFillBarWidthConstraint.setMultiplier(multiplier: (100.0-percentage)/100.0)
                })
            }
            
            self.uploadPercentageLabel.text = "\(String(format: "%.2f", percentage))%"
            
            if (percentage >= 100) {
                DispatchQueue.main.async {
                    print("Upload completed... 100%...")
                    NotificationCenter.default.removeObserver(self, name: self.uploadBarStatusNotification, object: nil)
                    UIView.animate(withDuration: 0.4, animations: {
                        self.uploadProgressBarContainer.layoutIfNeeded()
                        self.uploadProgressBarHeightConstraint.constant = 0
                    })
                    //Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.reloadPageAfterVideoUpload), userInfo: nil, repeats: false)
                }
                
            }
        }
        
        
        if (notification.name == uploadCompleteStatusNotification) {
            NotificationCenter.default.removeObserver(self, name: self.uploadCompleteStatusNotification, object: nil)
            DispatchQueue.main.async {
                self.reloadPageAfterVideoUpload()
            }
        }
    }
    
    func reloadPageAfterVideoUpload() {
        print("reloadPageAfterVideoUpload...")
        self.dataArray = []
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.getResponseFromJSONFile()
    }
    
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
        getProfileResponseFromAPI()
        DispatchQueue.main.async {
            self.popUpDontBeShhyButton.addAppGradient()
            self.uploadProgressBarHeightConstraint.constant = 0
            self.plusButtonBottomSpaceConstraint.constant = 0
            self.uploadPercentageLabel.text = ""
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
        //print(getReq.bucket)
        guard let uid = Auth.auth().currentUser?.uid else { return }
        getReq.prefix = "posts/\(uid)" //Folder path to get size
        //print(getReq.prefix)
        print(getReq)
        
        let downloadGroup = DispatchGroup()
        downloadGroup.enter()
        
        s3.listObjects(getReq) { (listObjects, error) in
            print(getReq)
            // print(listObjects)
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
                
                let paymentTypePurchased = DefaultWrapper().getPaymentTypePurchased()
                if (paymentTypePurchased == 0) {
                    let spaceInInt = Int(self.bucketDataArray.storage)
                    if let value = spaceInInt {
                        self.bucketSpace = value + 15
                        print(self.bucketSpace)
                    }
                    
                    
                    self.totalBucketSpace = "\((Float(self.bucketSpace))*1000.0)"
                    print("self.totalBucketSpace = \(self.totalBucketSpace)")
                    
                }
                else if (paymentTypePurchased == 1) {
                    let spaceInInt = Int(self.bucketDataArray.storage)
                    if let value = spaceInInt {
                        self.bucketSpace = value + 30
                        print(self.bucketSpace)
                    }
                    
                    
                    self.totalBucketSpace = "\((Float(self.bucketSpace))*1000.0)"
                    print("self.totalBucketSpace = \(self.totalBucketSpace)")
                }
                else if (paymentTypePurchased == 2) {
                    let spaceInInt = Int(self.bucketDataArray.storage)
                    if let value = spaceInInt {
                        self.bucketSpace = value + 100
                        print(self.bucketSpace)
                    }
                    
                    
                    self.totalBucketSpace = "\((Float(self.bucketSpace))*1000.0)"
                    print("self.totalBucketSpace = \(self.totalBucketSpace)")
                }
                else {
                    self.totalBucketSpace = "\((Float(self.bucketDataArray.storage) ?? 0.0)*1000.0)"
                    print("self.totalBucketSpace = \(self.totalBucketSpace)")
                }
                
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
                    
                    //                    let storageIndicatorGreenOnDropdownWidth = self.storageIndicatorGreenOnDropDown.frame.size.width
                    //                    let storageIndicatorRedOnDropdownWidth   = self.storageIndicatorRedOnDropDown.frame.size.width
                    
                    print("storageIndicatorGreenWidth = \(storageIndicatorGreenWidth)")
                    print("storageIndicatorRedWidth = \(storageIndicatorRedWidth)")
                    
                    //                    print("storageIndicatorGreenWidth = \(storageIndicatorGreenOnDropdownWidth)")
                    //                    print("storageIndicatorRedWidth = \(storageIndicatorRedOnDropdownWidth)")
                    
                    self.storageIndicatorRedWidthConstraint.constant = CGFloat(percentage)
                    // self.storageIndicatorRedOnDropDownWidthConstraint.constant = CGFloat(percentage)
                    
                }
            }
            
            let remainingSpace = totalBucketSpaceValue - usedBucketSpaceValue
            print("remainingSpace = \(remainingSpace)")
            
            let remainingSpaceInMB = Float(remainingSpace) / 1000.0
            //   let roundedValue = remainingSpaceInMB.rounded(.toNearestOrAwayFromZero)
            
            DispatchQueue.main.async {
                
                self.storageIndicatorLabel.text = "\(remainingSpaceInMB) GB Free"
                // self.storageIndicatorLabelOnDropDown.text = "\(remainingSpaceInMB) GB Free"
                
            }
        }
        else
        {
            DispatchQueue.main.async {
                let storageIndicatorRedWidth   = self.storageIndicatorRed.frame.size.width
                print("storageIndicatorRedWidth = \(storageIndicatorRedWidth)")
                self.storageIndicatorRedWidthConstraint.constant = CGFloat(0.0)
                //self.storageIndicatorRedOnDropDownWidthConstraint.constant = CGFloat(0.0)
                self.storageIndicatorLabel.text = "2 GB Free"
                // self.storageIndicatorLabelOnDropDown.text = "2 GB Free"
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
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        // self.collectioView.isUserInteractionEnabled = false
        
        getSubscriptionPlanResponseFromAPI()
        //self.dataArray = []
        self.tableView.reloadData()
        getResponseFromJSONFile()
        self.dropDownBaseView.alpha = 0
        self.dropdownOverlayButton.alpha = 0
        self.popUpOverlayButton.alpha = 0
        s3Url = AWSS3.default().configuration.endpoint.url
        
        overlayViewWhenDropDownAppears.alpha = 0
        UserDefaults.standard.set(false, forKey: "isTappedFromSingleVideo")
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotification(withNotification:)), name: uploadBarStatusNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotification(withNotification:)), name: uploadCompleteStatusNotification, object: nil)
        getTotalVideoCountFromAPI()
        
    }
    func getTotalVideoCountFromAPI() {
        ApiManager().getAllPostsAPI(from: "\(fetchStart)", size: "10") { (responseDict, error) in
            if error == nil {
                print("getAllPostsAPI :: responseDict.success\(responseDict.success)")
                print("Total video count=====> \(responseDict.count)")
                if responseDict.count == 1 {
                    DispatchQueue.main.async {
                        self.totalVideoCount.text = "\(String(responseDict.count)) video"
                    }                        }
                else {
                    DispatchQueue.main.async {
                        self.totalVideoCount.text = "\(String(responseDict.count)) videos"
                    }
                }
                
            }
            else {
                
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: uploadBarStatusNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: uploadCompleteStatusNotification, object: nil)
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
//                else if type == "PRO" {
//                    print("2")
//                    DefaultWrapper().setPaymentTypePurchased(type: 2)
//                }
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
    
    func isDataArrayContains(indexDict:FeedDataArrayObject) -> Bool {
        var isArrayContainsThisVideo:Bool = false
        let indexDictId = indexDict._id
        for i in 0..<self.dataArray.count {
            let arrayElementId = self.dataArray[i]._id
            if (arrayElementId == indexDictId) {
                isArrayContainsThisVideo = true
                break
            }
        }
        return isArrayContainsThisVideo
    }
    
    func getResponseFromJSONFile() {
        print("getAllPostsAPI :: dataArray.count\(dataArray.count)")
        print("getAllPostsAPI :: fetchStart\(fetchStart)")
        
        
        ApiManager().getAllPostsAPI(from: "\(fetchStart)", size: "10") { (responseDict, error) in
            if error == nil {
                //print("getAllPostsAPI :: responseDict\(responseDict.message)")
                if (responseDict.data.count == 0 && self.dataArray.count == 0) {
                    //print("getAllPostsAPI :: responseDict.data.count\(responseDict.data.count)")
                    DispatchQueue.main.async {
                        self.noFeedPopUpView.alpha = 1
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                        //  self.collectioView.isUserInteractionEnabled = true
                        
                        self.collectioView.reloadData()
                        self.isDataFetchInProgress = false
                    }
                }
                else {
                    print("getAllPostsAPI :: responseDict.success\(responseDict.success)")
                    print("Total video count=====> \(responseDict.count)")
//                    if responseDict.count == 1 {
//                        DispatchQueue.main.async {
//                            self.totalVideoCount.text = "\(String(responseDict.count)) video"
//                        }                        }
//                    else {
//                        DispatchQueue.main.async {
//                            self.totalVideoCount.text = "\(String(responseDict.count)) videos"
//                        }
//                    }
                    
                    for i in 0..<responseDict.data.count {
                        let indexDict = responseDict.data[i]
                        indexDict.isInfoPopUpDisplaying = false
                        
                        if (self.isDataArrayContains(indexDict: indexDict) == false) {
                            self.dataArray.append(indexDict)
                        }
                        //print("getAllPostsAPI :: filename ====> \(indexDict.fileName)")
                    }
                    
                    self.loadAllVideoImagesForDataArray()
                    DispatchQueue.main.async {
                        self.noFeedPopUpView.alpha = 0
                        self.collectioView.reloadData()
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                        // self.collectioView.isUserInteractionEnabled = true
                        self.isDataFetchInProgress = false
                    }
                    
                }
            }
                
            else {
                print("getAllPostsAPI :: error ====> \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    // self.collectioView.isUserInteractionEnabled = true
                    self.isDataFetchInProgress = false
                }
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (isDataFetchInProgress == false) {
            print("scrollViewDidEndDecelerating :: Calling API to fetch data again...")
            isDataFetchInProgress = true
            fetchStart = fetchStart + 10
            getResponseFromJSONFile()
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
        
        cell.playButton.tag = indexPath.row
        //        cell.playButton.addTarget(self, action: #selector(playButtonClicked), for: UIControl.Event.touchUpInside)
        cell.playButton.showsTouchWhenHighlighted = true
        //cell.playButton.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        cell.playButton.addTarget(self, action: #selector(LibraryFeedsViewController.playVideoOnCell(_:)), for: .touchUpInside)
        
        cell.infoSliderCloseButton.tag = indexPath.row
        cell.infoSliderCloseButton.addTarget(self, action: #selector(infoSliderCloseButtonClicked), for: UIControl.Event.touchUpInside)
        
        return cell
    }
    @objc func playVideoOnCell(_ button:UIButton) {
        print("playVideoOnCell :: ====> \(button.tag)")
        
        if (dataArray.count > button.tag) {
            print(dataArray[button.tag]._id)
            
            let userID = dataArray[button.tag].user._id
            let videoName = dataArray[button.tag].fileName
            let videoId = dataArray[button.tag]._id
            var videUrlString = "http://s3.viayou.net/posts/\(userID)/\(videoName)"
            videUrlString = videUrlString.replacingOccurrences(of: " ", with: "%20")
            
            let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "VideoViewController") as! VideoViewController
            nextVC.videoUrl = videUrlString
            nextVC.postId = videoId
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        
    }
    
    @objc func deleteVideoButtonClicked(_ sender:UIButton) {
        print(sender.tag)
        print(dataArray[sender.tag]._id)
        
        let boolValue = UserDefaults.standard.bool(forKey: "TrialPeriodEnds")
        if boolValue == true {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "BecomeGrowthHostPopUpViewController") as! BecomeGrowthHostPopUpViewController
            nextVC.modalPresentationStyle = .overCurrentContext
            nextVC.delegate = self
            self.present(nextVC, animated: false, completion: nil)
        }
        else {
            let tappedPostId = dataArray[sender.tag]._id
            ApiManager().deletePostAPI(postId: tappedPostId) { (response, error) in
                if error == nil {
                    print(response.success)
                    print(response.message)
                    
                    DispatchQueue.main.async {
                        self.dataArray.remove(at: sender.tag)
                        self.collectioView.reloadData()
                        self.dataArray.removeAll()
                        self.getResponseFromJSONFile()
                    }
                }
                else
                {
                    print(error.debugDescription)
                }
            }
        }
        
    }
    
    @objc func shareButtonClicked(_ sender:UIButton) {
        print(dataArray[sender.tag]._id)
        
        let boolValue = UserDefaults.standard.bool(forKey: "TrialPeriodEnds")
        if boolValue == true {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "BecomeGrowthHostPopUpViewController") as! BecomeGrowthHostPopUpViewController
            nextVC.modalPresentationStyle = .overCurrentContext
            nextVC.delegate = self
            self.present(nextVC, animated: false, completion: nil)
        }
        else {
            let userID = dataArray[sender.tag].user._id
            let videoName = dataArray[sender.tag].fileName
            //var videUrlString = "http://s3.viayou.net/posts/\(userID)/\(videoName)"
            var videUrlString = "http://d1o52q4xl0mbqu.cloudfront.net/posts/\(userID)/\(videoName)"
            videUrlString = videUrlString.replacingOccurrences(of: " ", with: "%20")
            UserDefaults.standard.set(true, forKey: "isTappedFromSingleVideo")
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "ContactsViewController") as! ContactsViewController
            nextVC.passedUrlLink = videUrlString
            let navVC = UINavigationController(rootViewController: nextVC)
            navVC.isNavigationBarHidden = true
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        
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
    }
    
    
    @IBAction func plusButtonClicked() {
        /*
         self.inviteFriendsPopUpView.alpha = 1
         self.popUpOverlayButton.alpha = 0.5
         */
        let boolValue = UserDefaults.standard.bool(forKey: "TrialPeriodEnds")
        if boolValue == true {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "TrialPeriodEndedViewController") as! TrialPeriodEndedViewController
            nextVC.modalPresentationStyle = .overCurrentContext
            nextVC.delegate = self
            self.present(nextVC, animated: false, completion: nil)
        }
        else {
//            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//            let nextVC = storyBoard.instantiateViewController(withIdentifier: "TrialPeriodEndedViewController") as! TrialPeriodEndedViewController
//            nextVC.modalPresentationStyle = .overCurrentContext
//            nextVC.delegate = self
//            self.present(nextVC, animated: false, completion: nil)
            
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        let nextVC = storyBoard.instantiateViewController(withIdentifier: "AddTwoMenuViewController") as! AddTwoMenuViewController
                        nextVC.modalPresentationStyle = .overCurrentContext
                        nextVC.delegate = self
                        self.present(nextVC, animated: false, completion: nil)
        }
        
    }
    
    func goToContactsVCToInvite() {
        
        UserDefaults.standard.set(false, forKey: "isTappedFromSingleVideo")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let link = URL(string: "https://viayou.page.link/?invitedby=\(uid)")
        let referralLink = DynamicLinkComponents(link: link!, domainURIPrefix: "https://viayou.page.link")
        
        referralLink!.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.viayou.ViaYouApp")
        referralLink!.iOSParameters?.minimumAppVersion = "1.0"
        // referralLink!.iOSParameters?.appStoreID = "123456789"
        
        referralLink!.androidParameters = DynamicLinkAndroidParameters(packageName: "net.viayou")
        //referralLink!.androidParameters?.minimumVersion = 125
        
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
        // print("\(self.getCurrentTime()) :: loadAllVideoImagesForDataArray :: dataArray.count ====> \(dataArray.count)")
        for i in 0..<dataArray.count {
            if (self.dataArray.count > i) {
                let userID = dataArray[i].user._id
                let videoName = dataArray[i].fileName
                var videUrlString = "http://s3.viayou.net/posts/\(userID)/\(videoName)"
                videUrlString = videUrlString.replacingOccurrences(of: " ", with: "%20")
                //print("videUrlString :: \(videUrlString)")
                
                DispatchQueue.global(qos: .userInitiated).async {
                    let image = self.previewImageFromVideo(url: URL(string: videUrlString)! as NSURL)
                    if (image != nil) {
                        let asset = AVAsset(url: URL(string: videUrlString)!)
                        let duration = asset.duration
                        let durationTime = CMTimeGetSeconds(duration)
                        
                        if (self.dataArray.count > i) {
                            self.dataArray[i].user.videoImage = image!
                            self.dataArray[i].user.duration = "\(durationTime)"
                            self.dataArray[i].fileName = videoName
                            DispatchQueue.main.async {
                                //print("****Loaded image at index :: \(i)")
                                self.collectioView.reloadData()
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        if (i == (self.dataArray.count-1)) {
                            self.activityIndicator.isHidden = true
                            self.activityIndicator.stopAnimating()
                            //  print("\(self.getCurrentTime()) :: loadAllVideoImagesForDataArray :: stopAnimating")
                            
                        }
                    }
                }
                
                //get video size
                
                getDownloadSize(url: URL(string: videUrlString)!) { (size, error) in
                    if (error == nil) {
                        DispatchQueue.main.async {
                            let size = "\(size) KB"
                            if (self.dataArray.count > i) {
                                self.dataArray[i].videoFileSize = size
                                self.collectioView.reloadData()
                            }
                        }
                    }
                }
                
                //get video size ended
            }
            else
            {
                
            }
            
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
        let paymentTypePurchased = DefaultWrapper().getPaymentTypePurchased()
        
        self.dropDownBaseViewHeightConstraint.constant = 0.0001
        self.dropdownOverlayButton.alpha = 1
        self.dropDownBaseView.alpha = 1
        self.overlayViewWhenDropDownAppears.alpha = 0.4
        UIView.animate(withDuration: 0.4) {
            if (paymentTypePurchased >= 0) {
                self.dropDownBaseViewHeightConstraint.constant = 400
            }else {
                self.dropDownBaseViewHeightConstraint.constant = 400
            }
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
        //      let paymentTypePurchased = DefaultWrapper().getPaymentTypePurchased()
        //        if (paymentTypePurchased >= 0) { //Purchased any
        //            return dropdownArrayAfterPurchase.count
        //        }
        return dropdownArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileDropdownTableViewCell", for: indexPath) as! ProfileDropdownTableViewCell
        cell.configureCell(dataArray: dropdownArray, index: indexPath.row)
        //        let paymentTypePurchased = DefaultWrapper().getPaymentTypePurchased()
        //        if (indexPath.row == 8) {
        //            let switchButton = UISwitch(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        //            switchButton.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        //            switchButton.center = CGPoint(x: tableView.frame.size.width-40, y: 20)
        //            switchButton.isOn = false
        //            switchButton.backgroundColor = UIColor.clear
        //            if (paymentTypePurchased >= 0 || paymentTypePurchased == 1 || paymentTypePurchased == 2 ) {
        //                switchButton.isUserInteractionEnabled = true
        //                switchButton.addTarget(self, action: #selector(enableSwitchStateChanged(_:)), for: .valueChanged)
        //            }
        //            else {
        //                switchButton.isUserInteractionEnabled = false
        //                switchButton.addTarget(self, action: #selector(showUpgradeOptions(_:)), for: .touchUpInside)
        //            }
        //            cell.addSubview(switchButton)
        //
        //            //                    if (switchIsOpen) {
        //            //                        switchButton.isOn = true
        //            //                    }
        //        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        dropDownOverlayButtonClicked((Any).self)
        
        let boolValue = UserDefaults.standard.bool(forKey: "TrialPeriodEnds")
        let paymentTypePurchased = DefaultWrapper().getPaymentTypePurchased()

        
        if(indexPath.row == 0) {
            self.inviteFriendsPopUpView.alpha = 1
            self.popUpOverlayButton.alpha = 0.5
        }
            //            else if (indexPath.row == 1) {
            //            let paymentTypePurchased = DefaultWrapper().getPaymentTypePurchased()
            //            print("paymentTypePurchased ====> \(paymentTypePurchased)")
            //
            //            if (paymentTypePurchased == 1 || paymentTypePurchased == 2) {
            //                self.becomeGrowthHostPopUpVC_SubscriptionBaseViewControllerrButtonClicked()
            //            }else {
            //                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            //                let nextVC = storyBoard.instantiateViewController(withIdentifier: "BecomeGrowthHostPopUpViewController") as! BecomeGrowthHostPopUpViewController
            //                nextVC.modalPresentationStyle = .overCurrentContext
            //                nextVC.delegate = self
            //                self.present(nextVC, animated: false, completion: nil)
            //            }
            //
            //        }
        else if (indexPath.row == 1) {
            
            if boolValue == true {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextVC = storyBoard.instantiateViewController(withIdentifier: "BecomeGrowthHostPopUpViewController") as! BecomeGrowthHostPopUpViewController
                nextVC.modalPresentationStyle = .overCurrentContext
                nextVC.delegate = self
                self.present(nextVC, animated: false, completion: nil)
            }
            else if (boolValue == false || paymentTypePurchased == 0 || paymentTypePurchased == 1){
                addWatermarkClicked()
                
            }
            else {
                addWatermarkClicked()
            }
            
            //            let paymentTypePurchased = DefaultWrapper().getPaymentTypePurchased()
            //            print("paymentTypePurchased ====> \(paymentTypePurchased)")
            //
            //            if (paymentTypePurchased == 1 || paymentTypePurchased == 2) {
            //                addWatermarkClicked()
            //
            //            }
            //            else {
            //                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            //                let nextVC = storyBoard.instantiateViewController(withIdentifier: "BecomeGrowthHostPopUpViewController") as! BecomeGrowthHostPopUpViewController
            //                nextVC.modalPresentationStyle = .overCurrentContext
            //                nextVC.delegate = self
            //                self.present(nextVC, animated: false, completion: nil)
            //            }
        }
        else if (indexPath.row == 2) {
            if boolValue == true {
                print("Restore option not available...")
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextVC = storyBoard.instantiateViewController(withIdentifier: "BecomeGrowthHostPopUpViewController") as! BecomeGrowthHostPopUpViewController
                nextVC.modalPresentationStyle = .overCurrentContext
                nextVC.delegate = self
                self.present(nextVC, animated: false, completion: nil)
            }
            else if (boolValue == false || paymentTypePurchased == 0 || paymentTypePurchased == 1){
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextVC = storyBoard.instantiateViewController(withIdentifier: "DeletedVideosViewController") as! DeletedVideosViewController
                nextVC.modalPresentationStyle = .overCurrentContext
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            else {
                
            }
            //            let paymentTypePurchased = DefaultWrapper().getPaymentTypePurchased()
            //            print("paymentTypePurchased ====> \(paymentTypePurchased)")
            //
            //            if (paymentTypePurchased == 1 || paymentTypePurchased == 2) {
            //                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            //                let nextVC = storyBoard.instantiateViewController(withIdentifier: "DeletedVideosViewController") as! DeletedVideosViewController
            //                nextVC.modalPresentationStyle = .overCurrentContext
            //                self.navigationController?.pushViewController(nextVC, animated: true)
            //
            //            }else {
            //                print("Restore option not available...")
            //                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            //                let nextVC = storyBoard.instantiateViewController(withIdentifier: "BecomeGrowthHostPopUpViewController") as! BecomeGrowthHostPopUpViewController
            //                nextVC.modalPresentationStyle = .overCurrentContext
            //                nextVC.delegate = self
            //                self.present(nextVC, animated: false, completion: nil)
            //            }
        }  else if (indexPath.row == 3) {
            if let url = URL(string: "http://www.blaquefracturetechnologies.com/") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
            
        }else if (indexPath.row == 4) {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "FeatureResuestPage_1ViewController") as! FeatureResuestPage_1ViewController
            nextVC.modalPresentationStyle = .overCurrentContext
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
            //        else if (indexPath.row == 5) {
            //            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            //            let nextVC = storyBoard.instantiateViewController(withIdentifier: "PrivacyPolicyViewController") as! PrivacyPolicyViewController
            //            self.navigationController?.pushViewController(nextVC, animated: true)
            //        } else if (indexPath.row == 6) {
            //            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            //            let nextVC = storyBoard.instantiateViewController(withIdentifier: "TermsNConditionsViewController") as! TermsNConditionsViewController
            //            self.navigationController?.pushViewController(nextVC, animated: true)
            //        }
        else if (indexPath.row == 6) {
            UserDefaults.standard.set(false, forKey: "IsUserLoggedIn")
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "NewLaunchViewController") as! NewLaunchViewController
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        
    }
    
    @objc func enableSwitchStateChanged(_ sender:UISwitch) {
        print("enableSwitchStateChange...")
        let paymentTypePurchased = DefaultWrapper().getPaymentTypePurchased()
        print("paymentTypePurchased ====> \(paymentTypePurchased)")
        
        
        //        if (switchIsOpen) {
        //            switchIsOpen = false
        //        }else {
        //            switchIsOpen = true
        //        }
        //        tableView.reloadData()
    }
    @objc func showUpgradeOptions(_ sender:UISwitch) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "BecomeGrowthHostPopUpViewController") as! BecomeGrowthHostPopUpViewController
        nextVC.modalPresentationStyle = .overCurrentContext
        nextVC.delegate = self
        self.present(nextVC, animated: false, completion: nil)
        
    }
    
    func addWatermarkClicked() {
        print("addWatermarkClicked...")
        
        isSelectingProfilePictureFromImagePicker = false
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
        
        //select videos from gallery
        self.isSelectingVideo = true
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.movie"]
        present(imagePickerController, animated: true, completion: nil)
        //select videos from gallery ends
        //        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //        let nextVC = storyBoard.instantiateViewController(withIdentifier: "AddFeedPopUpViewController") as! AddFeedPopUpViewController
        //        nextVC.delegate = self
        //        nextVC.modalPresentationStyle = .overCurrentContext
        //        self.present(nextVC, animated: false, completion: nil)
    }
    
    func AddTwoMenuViewController_videomergeButtonClicked() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "VideoRecordVC") as! VideoRecordVC
        //        let navVC = UINavigationController(rootViewController: nextVC)
        //        navVC.isNavigationBarHidden = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func becomeGrowthHostPopUpVC_UpgradeAndSubscriptionBaseViewControllerButtonClicked() {
        
        if let emailAddress = UserDefaults.standard.value(forKey: "UserEmailAddress"){
            ApiManager().getEmailToUpgradeAPI(emailId: emailAddress as! String) { (response, error) in
                if error == nil {
                    print(response.message)
                    self.displayAlert(msg: response.message)
                }
                else {
                    print(error.debugDescription)
                    self.displayAlert(msg: "Sorry! Please try again later.")
                }
            }
        }
        else {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "SubmitEmailViewController") as! SubmitEmailViewController
            let navVC = UINavigationController(rootViewController: nextVC)
            navVC.isNavigationBarHidden = true
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        //        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //        let nextVC = storyBoard.instantiateViewController(withIdentifier: "UpgradeAndSubscriptionBaseViewController") as! UpgradeAndSubscriptionBaseViewController
        //        nextVC.isFromViewAllButtonClick = true
        //        let navVC = UINavigationController(rootViewController: nextVC)
        //        navVC.isNavigationBarHidden = true
        //        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    func becomefullMember_LearnMoreButtonClicked() {
        if let emailAddress = UserDefaults.standard.value(forKey: "UserEmailAddress"){
            ApiManager().getEmailToUpgradeAPI(emailId: emailAddress as! String) { (response, error) in
                if error == nil {
                    print(response.message)
                    self.displayAlert(msg: response.message)
                }
                else {
                    print(error.debugDescription)
                    self.displayAlert(msg: "Sorry! Please try again later.")
                }
            }
        }
        else {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "SubmitEmailViewController") as! SubmitEmailViewController
            let navVC = UINavigationController(rootViewController: nextVC)
            navVC.isNavigationBarHidden = true
            self.navigationController?.pushViewController(nextVC, animated: true)
        }

        
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let nextVC = storyBoard.instantiateViewController(withIdentifier: "SubmitEmailViewController") as! SubmitEmailViewController
//        let navVC = UINavigationController(rootViewController: nextVC)
//        navVC.isNavigationBarHidden = true
//        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    //MARK:- Select profile picture
    @IBAction func dropdownProfilePicButtonClicked(_ sender: Any) {
        isSelectingProfilePictureFromImagePicker = true
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
    //edit starts
    func removeAudioFromVideo(_ videoURL: URL) {
        let inputVideoURL: URL = videoURL
        let sourceAsset = AVURLAsset(url: inputVideoURL)
        let sourceVideoTrack: AVAssetTrack? = sourceAsset.tracks(withMediaType: AVMediaType.video)[0]
        let composition : AVMutableComposition = AVMutableComposition()
        let compositionVideoTrack: AVMutableCompositionTrack? = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        compositionVideoTrack?.preferredTransform = sourceVideoTrack!.preferredTransform
        let x: CMTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: sourceAsset.duration)
        _ = try? compositionVideoTrack!.insertTimeRange(x, of: sourceVideoTrack!, at: CMTime.zero)
        mutableVideoURL = NSURL(fileURLWithPath: NSHomeDirectory() + "/Documents/FinalVideo.mp4") as URL
        let exporter: AVAssetExportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
        exporter.outputFileType = AVFileType.mp4
        exporter.outputURL = mutableVideoURL as URL
        removeFileAtURLIfExists(url: mutableVideoURL! as NSURL)
        exporter.exportAsynchronously(completionHandler:
            {
                switch exporter.status
                {
                case AVAssetExportSession.Status.failed:
                    print("failed \(String(describing: exporter.error))")
                case AVAssetExportSession.Status.cancelled:
                    print("cancelled \(String(describing: exporter.error))")
                case AVAssetExportSession.Status.unknown:
                    print("unknown\(String(describing: exporter.error))")
                case AVAssetExportSession.Status.waiting:
                    print("waiting\(String(describing: exporter.error))")
                case AVAssetExportSession.Status.exporting:
                    print("exporting\(String(describing: exporter.error))")
                default:
                    print("-----Mutable video exportation complete.")
                }
        })
    }
    
    func removeFileAtURLIfExists(url: NSURL) {
        if let filePath = url.path {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                do{
                    try fileManager.removeItem(atPath: filePath)
                } catch let error as NSError {
                    print("Couldn't remove existing destination file: \(error)")
                }
            }
        }
    }
    //edit ends
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let videoURL = info[.mediaURL] as? URL {
            selectedVideo = videoURL
            let asset = AVURLAsset(url: videoURL)
            
            removeAudioFromVideo(videoURL)
            // get the time in seconds
            let durationInSeconds = asset.duration.seconds
            let durationInInt = Int(durationInSeconds)
            print(durationInInt)
            UserDefaults.standard.set(durationInInt, forKey: "videotime")
            UserDefaults.standard.set(true, forKey: "IsSelectingVideoFromGallery")
            
        }
        
        
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
        
        
        if (isSelectingProfilePictureFromImagePicker == true) {
            
            self.dismiss(animated: true, completion: {
                let isFileDeleted = self.removeImageFromDocumentsDirectory(imageName: "profile.jpg")
                print("isFileDeleted====>\(isFileDeleted)")
                
                let savedProfileImagePath = self.saveprofilePicToDocumentDirectory(selectedImage)
                print("savedProfileImagePath====>\(savedProfileImagePath.absoluteString)")
                
                self.uploadProfilePhotoFile(with: "profile", type: "jpg", savedimagePathInDocuments: savedProfileImagePath)
            })
        }
        else if (isSelectingVideo == true) {
            print(selectedVideo)
            print(mutableVideoURL)
            self.dismiss(animated: true, completion: {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextVC = storyBoard.instantiateViewController(withIdentifier: "RecordFantVideoVC") as! RecordFantVideoVC
                //nextVC.getVideoURL = self.selectedVideo
                nextVC.getVideoURL = self.mutableVideoURL
                
                let navVC = UINavigationController(rootViewController: nextVC)
                navVC.isNavigationBarHidden = true
                self.navigationController?.pushViewController(nextVC, animated: true)
            })
        }
        else {
            print("image selected :: isSelectingProfilePictureFromImagePicker...")
            self.dismiss(animated: true, completion: {
                let isFileDeleted = self.removeImageFromDocumentsDirectory(imageName: "powered_viayou.png")
                print("isFileDeleted====>\(isFileDeleted)")
                
                let savedWatermarkImagePath = self.saveWatermarkToDocumentDirectory(selectedImage)
                print("savedProfileImagePath====>\(savedWatermarkImagePath.absoluteString)")
                
                self.uploadWatermarkPhotoFile(with: "powered_viayou", type: "png", savedimagePathInDocuments: savedWatermarkImagePath)
            })
            
        }
        
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
    
    func saveWatermarkToDocumentDirectory(_ chosenImage: UIImage) -> URL {
        let directoryPath =  NSHomeDirectory().appending("/Documents/")
        if !FileManager.default.fileExists(atPath: directoryPath) {
            do {
                try FileManager.default.createDirectory(at: NSURL.fileURL(withPath: directoryPath), withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error)
            }
        }
        
        let filename = "powered_viayou.png"
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
                            let alertController = UIAlertController(title: "ViaYou", message: ("Uploaded Profile Picture"), preferredStyle:.alert)
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
    
    
    func uploadWatermarkPhotoFile(with resource: String, type: String, savedimagePathInDocuments: URL)
    {
        
        // Upload file here
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
                            
                            let profileImageOnlineUrl = "\(self.watermarkUrlHeader)users/\(self.userId)/\(key)"
                            print("profileImageOnlineUrl====>\(profileImageOnlineUrl)")
                            
                            
                            JMImageCache.shared()?.removeImage(for: URL(string: profileImageOnlineUrl))
                            DispatchQueue.main.async {
                                JMImageCache.shared()?.image(for: URL(string: profileImageOnlineUrl), completionBlock: { (image) in
                                    
                                    //                                    self.profilePicButton.setBackgroundImage(image, for: .normal)
                                    //                                    self.profilePicButtonOnDropDownList.setBackgroundImage(image, for: .normal)
                                    //                                    self.profilePicOnInvitePopUp.image = image
                                    //                                    self.profilePicOnNoFeedPopUp.image = image
                                    
                                    
                                }, failureBlock: { (request, response, error) in
                                })
                                
                            }
                            print("Upload success \(key)")
                            let alertController = UIAlertController(title: "ViaYou", message: ("Uploaded watermark"), preferredStyle:.alert)
                            let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.cancel) {
                                UIAlertAction in}
                            alertController.addAction(action)
                            DispatchQueue.main.async {
                                self.activityIndicator.isHidden = true
                                self.activityIndicator.stopAnimating()
                                self.present(alertController, animated: true, completion:nil)
                                
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
    
    //MARK:- Get Profile Response
    func getProfileResponseFromAPI() {
        userId = Auth.auth().currentUser!.uid
        ApiManager().getProfileDetails(userId: userId) { (response, error) in
            if error == nil {
                print("Response Dictionary success status:\(response.success)")
                self.dataDict = response.data
                print("dataDict is dict: Name====>\(self.dataDict.createdDateTime)")
                var dateFromApi = self.dataDict.createdDateTime
                dateFromApi = dateFromApi.components(separatedBy: "T").first ?? dateFromApi
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                // Reads date form variable `dateString `
                let newdate = dateFormatter.date(from: dateFromApi)
                var expiryDateForLabel:Int = 0
                if let expiryDate = Calendar.current.date(byAdding: .month, value: 1, to: newdate!) {
                    print(expiryDate)
                    
                    if let diffInDays = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day {
                        print("daysDifference ====> \(diffInDays)")
                        expiryDateForLabel = diffInDays
                        
                        //notified every week method
                        //k* --start
                        if (diffInDays == 0) {
                            //Date is over
                            self.remainingDaysLabel.text = "Trial Period Ended"
                            UserDefaults.standard.set(true, forKey: "TrialPeriodEnds")
                            
                            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                            let nextVC = storyBoard.instantiateViewController(withIdentifier: "TrialPeriodEndedViewController") as! TrialPeriodEndedViewController
                            nextVC.modalPresentationStyle = .overCurrentContext
                            nextVC.delegate = self
                            self.present(nextVC, animated: false, completion: nil)
                            
                        }else {
                            if (diffInDays % 7 == 0) {
                                print("days Remaining  ====> \(diffInDays)")
                                print("weeks Remaining ====> \(diffInDays/7)")
                                let todaysDateString = self.getTodaysDate()
                                let isUserNotifiedOnThisDate = DefaultWrapper().getIsUserNotifiedOnThisDate(dateString: todaysDateString, userId: self.userId)
                                if (isUserNotifiedOnThisDate == false) {
                                    print("User was not notified on this date")
                                    DefaultWrapper().setIsUserNotifiedOnThisDate(status: true, dateString: todaysDateString, userId: self.userId)
                                    DispatchQueue.main.async {
                                        //self.displayAlert(msg: "Remaining \(diffInDays) days")
                                        
                                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                        let nextVC = storyBoard.instantiateViewController(withIdentifier: "BecomeGrowthHostPopUpViewController") as! BecomeGrowthHostPopUpViewController
                                        nextVC.modalPresentationStyle = .overCurrentContext
                                        nextVC.delegate = self
                                        nextVC.remainingDays = "\(diffInDays/7)"
                                        self.present(nextVC, animated: false, completion: nil)
                                    }
                                }
                            }
                        }
                    }
                    if expiryDateForLabel < 1 {
                        self.remainingDaysLabel.text = "Trial Period Ended"
                        UserDefaults.standard.set(true, forKey: "TrialPeriodEnds")
                        
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        let nextVC = storyBoard.instantiateViewController(withIdentifier: "TrialPeriodEndedViewController") as! TrialPeriodEndedViewController
                        nextVC.modalPresentationStyle = .overCurrentContext
                        nextVC.delegate = self
                        self.present(nextVC, animated: false, completion: nil)
                    }
                        //k* --end
                    else if expiryDateForLabel == 1 {
                        self.remainingDaysLabel.text = "\(String(expiryDateForLabel)) day left"
                        UserDefaults.standard.set(false, forKey: "TrialPeriodEnds")
                    }
                    else {
                        DispatchQueue.main.async {
                            self.remainingDaysLabel.text = "\(String(expiryDateForLabel)) days left"
                            UserDefaults.standard.set(false, forKey: "TrialPeriodEnds")
                        }
                    }
                    
                }
                
            }
            else {
                print(error?.localizedDescription ?? "Error getting user details")
                self.displaySingleButtonAlert(message: "Something went wrong. Please try again later!")
            }
        }
    }
    
    func getTodaysDate() ->String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
}

