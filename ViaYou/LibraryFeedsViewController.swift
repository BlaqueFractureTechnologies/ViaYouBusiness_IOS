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

class LibraryFeedsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MFMailComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, BecomeGrowthHostPopUpViewControllerDelegate {
    
    
    
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
    
    @IBOutlet weak var userNameOnDropDown: UILabel!
    var dataArray:[FeedDataArrayObject] = []
    var passedProfileImage = UIImage()
    var userId: String = ""
    var invitationUrl: URL!
    let dropdownArray = ["Invite",
                         "Share Storage",
                         "My Plan Or Upgrade",
                         "Restore",
                         "Feedback",
                         "Feature Request",
                         "Analytics",
                         "Privacy Policy",
                         "Terms And Conditions"]
    //AWS setup
    let bucketName = "dev-promptchu"
    var contentUrl: URL!
    var s3Url: URL!
    
    var streetName: String = ""
    var countryCode: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.noFeedPopUpView.alpha = 0
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
        self.profilePicButton.setBackgroundImage(self.passedProfileImage, for: .normal)
        print("self.passedProfileImage===>\(self.passedProfileImage)")
        
        if (__CGSizeEqualToSize(self.profilePicButton.currentBackgroundImage?.size ?? CGSize.zero, CGSize.zero)) {
            print("EMPTY IMAGE")
            self.profilePicButton.setBackgroundImage(UIImage(named: "defaultProfilePic"), for: .normal)
        }
        
        self.profilePicOnDropDownList.layer.cornerRadius = self.profilePicOnDropDownList.frame.size.width/2.0
        self.profilePicOnDropDownList.clipsToBounds = true
        //self.profilePicOnDropDownList.image = self.passedProfileImage
        self.profilePicButtonOnDropDownList.setBackgroundImage(self.passedProfileImage, for: .normal)
        if (__CGSizeEqualToSize(self.profilePicButtonOnDropDownList.currentBackgroundImage?.size ?? CGSize.zero, CGSize.zero)) {
            print("EMPTY IMAGE")
            self.profilePicButtonOnDropDownList.setBackgroundImage(UIImage(named: "defaultProfilePic"), for: .normal)
            
        }
        
        collectioView.reloadData()
        getResponseFromJSONFile()
        getBucketInfo()
        
        
    }
    
    //get aws s3 bucket info
    func getBucketInfo() {
        //aws configuration
        let accessKey = "AKIAJ6O3XJCBVT4WJEYQ"
        let secretKey = "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"
        //let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast2, identityPoolId:"us-east-2:3d024c5d-faba-4922-85e4-9b3d2d9581c9")
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USEast2, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        //s3Url = AWSS3.default().configuration.endpoint.url
        //aws configuration ends
        
        //        AWSS3.register(with: configuration!, forKey: "defaultKey")
        //        let s3 = AWSS3.s3(forKey: "defaultKey")
        let s3 = AWSS3.default()
        let getReq : AWSS3ListObjectsRequest = AWSS3ListObjectsRequest()
        getReq.bucket = self.bucketName
        guard let uid = Auth.auth().currentUser?.uid else { return }
        getReq.prefix = "https://dev-promptchu.s3.us-east-2.amazonaws.com/posts/\(uid)" //Folder path to get size
        let downloadGroup = DispatchGroup()
        downloadGroup.enter()
        
        s3.listObjects(getReq) { (listObjects, error) in
            print(getReq)
            //   print(listObjects)
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
            }
            else {
                print("contents is blank")
                print(error.debugDescription)
            }
        }
        
        ////
        //        s3.listObjects(getReq).continueWith { (task) -> AnyObject? in
        //            print("Object result = \(String(describing: task.result))")
        //
        //            print("Object contents = \(String(describing: task.result?.contents))")
        //            for object in (task.result?.contents)! {
        //
        //                print("Object key = \(object.key!)")
        //            }
        //            return nil
        //
        //        }
        //        //
    }
    //get aws s3 bucket info ends
    
    //get used space
    
    
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
        self.dropDownBaseView.alpha = 0
        self.dropdownOverlayButton.alpha = 0
        overlayViewWhenDropDownAppears.alpha = 0
        UserDefaults.standard.set(false, forKey: "isTappedFromSingleVideo")
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(displayBottomPlusButtonCircularWave), userInfo: nil, repeats: false)
        
    }
    
    
    func readResponseFromFileForTest() {
        if let path = Bundle.main.path(forResource: "response", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [String:Any] {
                    let responseDict = LibraryFeedResponse(jsonResult)
                    
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
                            let indexDict = responseDict.data[i]
                            indexDict.isInfoPopUpDisplaying = false
                            self.dataArray.append(indexDict)
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
            } catch {
                
            }
        }
    }
    
    func getResponseFromJSONFile() {
        readResponseFromFileForTest()
        return
            
            
            ApiManager().getAllPostsAPI(from: "0", size: "10") { (responseDict, error) in
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
                            let indexDict = responseDict.data[i]
                            indexDict.isInfoPopUpDisplaying = false
                            self.dataArray.append(indexDict)
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LibraryFeedsCollectionViewCell", for: indexPath) as! LibraryFeedsCollectionViewCell
        cell.configureCell(dataDict: dataArray[indexPath.row])
        
        cell.infoButton.tag = indexPath.row
        cell.infoButton.addTarget(self, action: #selector(infoButtonClicked), for: UIControl.Event.touchUpInside)
        
        cell.infoSliderCloseButton.tag = indexPath.row
        cell.infoSliderCloseButton.addTarget(self, action: #selector(infoSliderCloseButtonClicked), for: UIControl.Event.touchUpInside)
        
        return cell
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
            var videUrlString = "https://dev-promptchu.s3.us-east-2.amazonaws.com/posts/\(userID)/\(videoName)"
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
    
    @IBAction func plusButtonClicked() {
        print("didSelectItemAt...")
        
        
        UserDefaults.standard.set(false, forKey: "isTappedFromSingleVideo")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let link = URL(string: "https://promptchu.page.link/?invitedby=\(uid)")
        let referralLink = DynamicLinkComponents(link: link!, domainURIPrefix: "https://promptchu.page.link")
        
        referralLink!.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.example.ios")
        referralLink!.iOSParameters?.minimumAppVersion = "1.0.1"
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
        //        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //        let nextVC = storyBoard.instantiateViewController(withIdentifier: "LessSpacePopUpViewController") as! LessSpacePopUpViewController
        //        nextVC.modalPresentationStyle = .overCurrentContext
        //        let navVC = UINavigationController(rootViewController: nextVC)
        //        navVC.isNavigationBarHidden = true
        //        self.navigationController?.present(navVC, animated: false, completion: nil)
    }
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
            var videUrlString = "https://dev-promptchu.s3.us-east-2.amazonaws.com/posts/\(userID)/\(videoName)"
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
        if (indexPath.row == 2) {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "BecomeGrowthHostPopUpViewController") as! BecomeGrowthHostPopUpViewController
            nextVC.modalPresentationStyle = .overCurrentContext
            nextVC.delegate = self
            self.present(nextVC, animated: false, completion: nil)
        }
        else if (indexPath.row == 5) {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextVC = storyBoard.instantiateViewController(withIdentifier: "FeatureResuestPage_1ViewController") as! FeatureResuestPage_1ViewController
            nextVC.modalPresentationStyle = .overCurrentContext
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
    
    func becomeGrowthHostPopUpVC_UpgradeAndSubscriptionBaseViewControllerButtonClicked() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "UpgradeAndSubscriptionBaseViewController") as! UpgradeAndSubscriptionBaseViewController
        let navVC = UINavigationController(rootViewController: nextVC)
        navVC.isNavigationBarHidden = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}

