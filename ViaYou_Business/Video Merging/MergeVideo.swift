//
//  MergeVideo.swift
//  Promptchu
//
//  Created by Netra Technosys on 16/07/19.
//  Copyright © 2019 Netra Technosys. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import AssetsLibrary
import Photos
import MediaWatermark
import DTMessageHUD
import AWSS3
import AWSCore
import AWSCognito
import mobileffmpeg
import Firebase
import PhotosUI


enum QUWatermarkPosition {
    case TopLeft
    case TopRight
    case BottomLeft
    case BottomRight
    case Default
}

class MergeVideo: UIViewController, UITextFieldDelegate, MergeVideoDescriptionPopUpViewControllerDelegate { //k*
    
    @IBOutlet weak var bigVIdeoView: UIView!
    @IBOutlet weak var smallVIdeoView: UIView!
    @IBOutlet weak var viewFrame: UIView!
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var btnRedo: UIButton!
    @IBOutlet weak var btnSaveOutlet: UIButton!
    
    @IBOutlet weak var promptTitleField: UITextField!
    @IBOutlet weak var titleFieldContainer: UIView!
    @IBOutlet weak var promptRoundButtonContainer: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var videoTimerLabel: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    
    var timerForCheckPhotoLibraryStatus = Timer()
    
    var bigVideoURL:URL!
    var urlOfSmallVideo:URL!
    //var urlOfSmallVideo: URL!
    var currentTimeCounter = 0
    var lbltimer = Timer()
    var videoTime = Int()
    var audioURl:URL!
    var dicDiscription = NSMutableDictionary()
    var outputURL:URL!
    var watermarkURL:URL!
    var userID: String = ""
    //AWS SETUP
    let bucketName = "s3.viayou.net"
    var contentUrl: URL!
    var s3Url: URL!
    
    var streetName: String = ""
    var countryCode: String = ""
    let locationManager = CLLocationManager()
    
    var dataDictToBePosted:[String:Any] = [:]
    
    var totalVideoTime:Int = 0
    
    
    //
    var nameOfVideo:String = ""
    var videoSize: String = ""
    var dateCreated: String = ""
    
    var strName: String = ""
    var typeString: String = ""
    var finalURL: URL!
    
    var watermarkUrlHeader = "http://s3.viayou.net/"
    var thirdUrl: String = ""
    var userId: String = ""
    //
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // promptTitleField.makeBlackPlaceholder()
        promptTitleField.makeWhitePlaceholder()
        
        //watermark image
        let watermarkImage = "powered_viayou.png"
        if let selfUserId = Auth.auth().currentUser?.uid {
            thirdUrl = "\(watermarkUrlHeader)users/\(selfUserId)/\(watermarkImage)"
            print(thirdUrl)
        }
        //
        
        JMImageCache.shared()?.image(for: URL(string: thirdUrl), completionBlock: { (image) in
            print(image)
            let selectedImage = image
            let savedProfileImagePath = self.saveprofilePicToDocumentDirectory(selectedImage!)
            print("savedProfileImagePath====>\(savedProfileImagePath.absoluteString)")
            
            self.uploadProfilePhotoFile(with: "powered_viayou", type: "png", savedimagePathInDocuments: savedProfileImagePath)
            
            if (__CGSizeEqualToSize(image?.size ?? CGSize.zero, CGSize.zero)) {
                print("EMPTY IMAGE")
                let selectedImage = UIImage(named: "ic_powered_viayou")!
                
                let savedProfileImagePath = self.saveprofilePicToDocumentDirectory(selectedImage)
                print("savedProfileImagePath====>\(savedProfileImagePath.absoluteString)")
                
                self.uploadProfilePhotoFile(with: "powered_viayou", type: "png", savedimagePathInDocuments: savedProfileImagePath)
            }
        }, failureBlock: { (request, response, error) in
            print(error.debugDescription)
            let selectedImage = UIImage(named: "ic_powered_viayou")!
            
            let savedProfileImagePath = self.saveprofilePicToDocumentDirectory(selectedImage)
            print("savedProfileImagePath====>\(savedProfileImagePath.absoluteString)")
            
            self.uploadProfilePhotoFile(with: "powered_viayou", type: "png", savedimagePathInDocuments: savedProfileImagePath)
        })
        //
        
        
        //watermark image ends
        // time calc starts
        let interval = self.totalVideoTime
        print(interval)
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .brief
        
        let formattedString = formatter.string(from: TimeInterval(interval))!
        print(formattedString)
        self.videoTimerLabel.text = formattedString
        //time calc ends
        self.viewSetUPDesign()
        //AWS SETUP FOR UPLOAD VIDEO ON AWS SERVER
        //SIMULATORE
        /*let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast2, identityPoolId:"us-east-2:3d024c5d-faba-4922-85e4-9b3d2d9581c9")
         let configuration = AWSServiceConfiguration(region:.USEast2, credentialsProvider:credentialsProvider)
         AWSServiceManager.default().defaultServiceConfiguration = configuration
         s3Url = AWSS3.default().configuration.endpoint.url*/
        //REAL DEVICE
        let accessKey = "AKIA6JJLBT2ZHL52PQLQ"
        let secretKey = "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"
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USEast2, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        s3Url = AWSS3.default().configuration.endpoint.url
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        
        
        
        activityIndicator.isHidden = true
        self.uploadButton.isUserInteractionEnabled = false
        PlaybigViewVideo()
        PlaysmallViewVideo()
        saveVideoToFile()
        self.hideKeyboardWhenTappedAround()
        
        //btnRedo.isUserInteractionEnabled = true
        // btnSaveOutlet.isUserInteractionEnabled = true
        print("Video time = \(videoTime)")
        videoTime = UserDefaults.standard.value(forKey: "videotime") as! Int
        self.currentTimeCounter = 1
        //Setup dict
        self.userID = Auth.auth().currentUser!.uid
        dataDictToBePosted["_id"] = ""
        dataDictToBePosted["title"] = promptTitleField.text
        dataDictToBePosted["description"] = "description...."
        dataDictToBePosted["user"] = self.userID
        dataDictToBePosted["isScreenCast"] = true
        
        
        var locationDict:[String:Any] = [:]
        locationDict["address"] = "address...."
        locationDict["type"] = "Point"
        
        var coordinatesArray:[Float] = []
        coordinatesArray.append(145.16732566211985)
        coordinatesArray.append(-37.926291593749504)
        locationDict["coordinates"] = coordinatesArray  //Setup coordinatesArray
        
        dataDictToBePosted["location"] = locationDict  //Setup locationDict to main Dict
        
        dataDictToBePosted["createdDateTime"] = "2019-09-07T11:50:56.077Z"
        dataDictToBePosted["updatedDateTime"] = "2019-09-07T11:50:56.077Z"
        
        var tagsArray:[String] = []
        tagsArray.append("Tag 1")
        tagsArray.append("Tag 2")
        dataDictToBePosted["tags"] = tagsArray  //Setup tagsArray to main Dict
        
        //        dataDictToBePosted["fileName"] = "fileName..."
        dataDictToBePosted["commentsCount"] = 0
        dataDictToBePosted["viewCount"] = 0
        dataDictToBePosted["isRatedByUser"] = true
        dataDictToBePosted["isBlocked"] = true
        
        dataDictToBePosted["product"] = "Product..."
        var companyDict:[String:Any] = [:]
        companyDict["_id"] = "company_id...."
        companyDict["name"] = "company_name..."
        dataDictToBePosted["company"] = companyDict  //Setup companyDict to main Dict
        dataDictToBePosted["brand"] = "Brand..."
        dataDictToBePosted["duration"] = self.videoTime
        dataDictToBePosted["size"] = self.videoSize
        
        print("dataDictToBePosted====>\(dataDictToBePosted)")
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardDidShowNotification),name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardDidShowNotification),name: UIResponder.keyboardWillHideNotification,object: nil)
        
        //   getUserShadows() //k*
        
    }
    
    //MARK::- Text Field Delegates
    @objc func keyboardDidShowNotification(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardOriginY = keyboardFrame.cgRectValue.origin.y
            print("keyboardOriginY====>\(keyboardOriginY)")
            
            DispatchQueue.main.async {
                
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func promptButtonClicked(_ sender: Any) {
        print("promptButtonClicked...")
        print("btnActionSaveToGallery :: dataDictToBePosted====>\(dataDictToBePosted)")
        self.activityIndicator.isHidden = false
        // self.view.isUserInteractionEnabled = false
        self.activityIndicator.startAnimating()
        let asset = AVURLAsset(url: urlOfSmallVideo, options: nil)
        audioURl = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/temp.m4a")
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let myDocumentPath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("temp.m4a").absoluteString
        _ = NSURL(fileURLWithPath: myDocumentPath)
        let documentsDirectory2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        audioURl = documentsDirectory2.appendingPathComponent("Audio.m4a")
        self.deleteFile(filePath: audioURl as NSURL)
        asset.writeAudioTrackToURL(audioURl) { (success, error) -> () in
            if !success
            {
                print(error as Any)
            }
            else
            {
                self.mergeVideos(firestUrl: self.urlOfSmallVideo, SecondUrl: self.bigVideoURL)
                if self.watermarkURL == nil
                {
                    // processVideo(url:watermarkURL )
                    let alertController = UIAlertController(title: "Viayou", message: "Kindly Wait, Video is under the Process!", preferredStyle:.alert)
                    let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.cancel) {
                        UIAlertAction in}
                    alertController.addAction(action)
                    // self.present(alertController, animated: true, completion:nil)
                }else
                {
                    let alertController = UIAlertController(title: "Viayou", message: "Save video in Gallery?", preferredStyle:.alert)
                    let action = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                        UIAlertAction in
                    }
                    let action1 = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                        UIAlertAction in
                        // self.HideButton()
                        self.timerForCheckPhotoLibraryStatus.invalidate()
                        self.timerForCheckPhotoLibraryStatus = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.checkPhotoLibraryPermission), userInfo: nil, repeats: true)
                    }
                    alertController.addAction(action)
                    alertController.addAction(action1)
                    self.present(alertController, animated: true, completion:nil)
                    
                }
            }
        }
    }
    
    @IBAction func descriptionOverlayButtonClicked(_ sender: Any) {
        print("descriptionOverlayButtonClicked...")
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "MergeVideoDescriptionPopUpViewController") as! MergeVideoDescriptionPopUpViewController
        // nextVC.descriptionText = promptDescriptionTextView.text ?? ""
        nextVC.delegate = self
        nextVC.modalPresentationStyle = .overCurrentContext
        self.present(nextVC, animated: true, completion: nil)
    }
    //
    //    func mergeVideoDescriptionPopUpVCDescriptionTextSubmitted(descriptionString: String) {
    //        print("mergeVideoDescriptionPopUpVCDescriptionTextSubmitted...")
    //
    //     //   self.promptDescriptionTextView.text = descriptionString
    //        dataDictToBePosted["description"]   = descriptionString
    //    }
    
    @IBAction func titleFieldTextChanged(_ sender: UITextField) {
        print("titleFieldTextChanged :: \(sender.text ?? "")")
        let titleText = sender.text ?? ""
        dataDictToBePosted["title"] = titleText
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        timerForCheckPhotoLibraryStatus.invalidate()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func viewSetUPDesign()
    {
        
        smallVIdeoView.layer.borderWidth = 3
        smallVIdeoView.layer.borderColor = hexStringToUIColor(hex: "D6556B").cgColor
        
        //        viewFrame.layer.borderWidth = 5
        //        viewFrame.layer.borderColor = hexStringToUIColor(hex: "F8CC5F").cgColor
        
        //        lblTimer.layer.cornerRadius = self.lblTimer.frame.size.height / 2
        //        lblTimer.clipsToBounds = true
        
        promptTitleField.layer.cornerRadius = self.promptTitleField.frame.size.height / 2
        promptTitleField.clipsToBounds = true
        
    }
    
    var smallPlayerLayer = AVPlayerLayer()
    var bigPlayerLayer = AVPlayerLayer()
    
    func PlaysmallViewVideo()
    {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                //let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
                let player = AVPlayer(url: self.urlOfSmallVideo!)
                self.smallPlayerLayer = AVPlayerLayer(player: player)
                self.smallPlayerLayer.frame = self.smallVIdeoView.bounds
                self.smallPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.smallVIdeoView.layer.addSublayer(self.smallPlayerLayer)
                player.play()
            }
        }
    }
    
    func PlaybigViewVideo()
    {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                let player = AVPlayer(url: self.bigVideoURL!)
                self.bigPlayerLayer = AVPlayerLayer(player: player)
                self.bigPlayerLayer.frame = self.bigVIdeoView.bounds
                self.bigPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.bigVIdeoView.layer.addSublayer(self.bigPlayerLayer)
                player.play()
            }
        }
    }
    
    
    func upodateCreatedAndUpdatedTme() {
        
        
        let now_inGMT = Date().toGlobalTime()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-ddTHH:mm:ss.ssssZ"
        let dateString = dateFormatter.string(from: now_inGMT)
        print("dateString====>\(dateString)")
        
        dataDictToBePosted["createdDateTime"] = dateString
        dataDictToBePosted["updatedDateTime"] = dateString
        
    }
    
    /*
     func uploadFile(with resource: String, type: String, videoURL: URL)
     {
     upodateCreatedAndUpdatedTme()
     print("upodateCreatedAndUpdatedTme :: dataDictToBePosted====>\(dataDictToBePosted)")
     autoreleasepool{
     DispatchQueue.global(qos: .userInitiated).async {
     DispatchQueue.main.async {
     //DTMessageHUD.hud()
     
     let key = "\(resource).\(type)"
     
     let request = AWSS3TransferManagerUploadRequest()!
     request.bucket = self.bucketName
     self.userID = Auth.auth().currentUser!.uid
     request.key = "posts/"+"\(String(describing: self.userID))"+"/"+key
     
     request.body = videoURL
     request.acl = .publicReadWrite
     self.dataDictToBePosted["fileName"] = key
     
     let transferManager = AWSS3TransferManager.default()
     transferManager.upload(request).continueWith(executor: AWSExecutor.mainThread()) { (task) -> Any? in
     DispatchQueue.main.async {
     DTMessageHUD.dismiss()
     }
     if let error = task.error {
     print(error)
     DTMessageHUD.dismiss()
     }
     if task.result != nil {
     DTMessageHUD.dismiss()
     //Post video to firebase
     
     //NEW
     ApiManager().addVideoPostToFirebase(dataDict: self.dataDictToBePosted, completion: { (responseDict, error) in
     if (error == nil) {
     if (responseDict.success == true) {
     print(responseDict)
     print("Success :: updateProfileToAPI ====> \(responseDict.message)")
     print("Uploaded \(key)")
     let alertController = UIAlertController(title: "Viayou", message: ("Uploaded Video"), preferredStyle:.alert)
     let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.default) {
     UIAlertAction in
     
     let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
     let homeVC = storyBoard.instantiateViewController(withIdentifier: "LibraryFeedsViewController") as! LibraryFeedsViewController
     self.navigationController?.pushViewController(homeVC, animated: true)
     }
     alertController.addAction(action)
     self.activityIndicator.stopAnimating()
     self.activityIndicator.isHidden = true
     self.view.isUserInteractionEnabled = true
     
     self.present(alertController, animated: true, completion:nil)
     }
     }else {
     self.displaySingleButtonAlert(message: error?.localizedDescription ?? "Network Error")
     self.activityIndicator.stopAnimating()
     self.activityIndicator.isHidden = true
     self.view.isUserInteractionEnabled = true
     
     }
     })
     
     
     // /* OLD
     //                             ApiManager().addVideoPostToFirebase(userID: self.userID, title: self.promptTitleField.text ?? "", description: "", fileName: key, completion: { (responseDict, error) in
     //                             if (error == nil) {
     //                             if (responseDict.success == true) {
     //                             print(responseDict)
     //                             print("Success :: updateProfileToAPI ====> \(responseDict.message)")
     //                             }
     //                             }else {
     //                             self.displaySingleButtonAlert(message: error?.localizedDescription ?? "Network Error")
     //                             }
     //
     //                             })
     // */
     //post video to firebase ends
     
     let contentUrl = self.s3Url.appendingPathComponent(self.bucketName).appendingPathComponent(key)
     self.contentUrl = contentUrl
     }
     return nil
     }
     }
     }
     }
     print("Done")
     }
     */
    
    func uploadFile(with resource: String, type: String, videoURL: URL)
    {
        print("Entered :: uploadFile")
        
        upodateCreatedAndUpdatedTme()
        DTMessageHUD.dismiss()
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        print("upodateCreatedAndUpdatedTme :: dataDictToBePosted====>\(dataDictToBePosted)")
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.uploadFile(with: resource, type: type, videoURL: videoURL, passeddataDictToBePosted: dataDictToBePosted, passed_s3Url: self.s3Url)
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let homeVC = storyBoard.instantiateViewController(withIdentifier: "LibraryFeedsViewController") as! LibraryFeedsViewController
        self.navigationController?.pushViewController(homeVC, animated: true)
        
        
        /*
         autoreleasepool{
         DispatchQueue.global(qos: .userInitiated).async {
         DispatchQueue.main.async {
         //DTMessageHUD.hud()
         
         let key = "\(resource).\(type)"
         
         let request = AWSS3TransferManagerUploadRequest()!
         request.bucket = self.bucketName
         self.userID = Auth.auth().currentUser!.uid
         request.key = "posts/"+"\(String(describing: self.userID))"+"/"+key
         
         request.body = videoURL
         request.acl = .publicReadWrite
         self.dataDictToBePosted["fileName"] = key
         
         let transferManager = AWSS3TransferManager.default()
         transferManager.upload(request).continueWith(executor: AWSExecutor.mainThread()) { (task) -> Any? in
         DispatchQueue.main.async {
         DTMessageHUD.dismiss()
         }
         if let error = task.error {
         print(error)
         DTMessageHUD.dismiss()
         }
         if task.result != nil {
         DTMessageHUD.dismiss()
         //Post video to firebase
         
         //NEW
         ApiManager().addVideoPostToFirebase(dataDict: self.dataDictToBePosted, completion: { (responseDict, error) in
         if (error == nil) {
         if (responseDict.success == true) {
         print(responseDict)
         print("Success :: updateProfileToAPI ====> \(responseDict.message)")
         print("Uploaded \(key)")
         let alertController = UIAlertController(title: "Viayou", message: ("Uploaded Video"), preferredStyle:.alert)
         let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.default) {
         UIAlertAction in
         
         let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
         let homeVC = storyBoard.instantiateViewController(withIdentifier: "LibraryFeedsViewController") as! LibraryFeedsViewController
         self.navigationController?.pushViewController(homeVC, animated: true)
         }
         alertController.addAction(action)
         self.activityIndicator.stopAnimating()
         self.activityIndicator.isHidden = true
         self.view.isUserInteractionEnabled = true
         
         self.present(alertController, animated: true, completion:nil)
         }
         }else {
         self.displaySingleButtonAlert(message: error?.localizedDescription ?? "Network Error")
         self.activityIndicator.stopAnimating()
         self.activityIndicator.isHidden = true
         self.view.isUserInteractionEnabled = true
         
         }
         })
         
         
         // /* OLD
         //                             ApiManager().addVideoPostToFirebase(userID: self.userID, title: self.promptTitleField.text ?? "", description: "", fileName: key, completion: { (responseDict, error) in
         //                             if (error == nil) {
         //                             if (responseDict.success == true) {
         //                             print(responseDict)
         //                             print("Success :: updateProfileToAPI ====> \(responseDict.message)")
         //                             }
         //                             }else {
         //                             self.displaySingleButtonAlert(message: error?.localizedDescription ?? "Network Error")
         //                             }
         //
         //                             })
         // */
         //post video to firebase ends
         
         let contentUrl = self.s3Url.appendingPathComponent(self.bucketName).appendingPathComponent(key)
         self.contentUrl = contentUrl
         }
         return nil
         }
         }
         }
         }
         print("Done")
         */
    }
    
    
    @IBAction func btnPressToFristVC(_ sender: Any)
    {
        //self.navigationController?.popViewControllers(viewsToPop: 2)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnActionSaveToGallery(_ sender: Any)
    {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let homeVC = storyBoard.instantiateViewController(withIdentifier: "LibraryFeedsViewController") as! LibraryFeedsViewController
            self.navigationController?.pushViewController(homeVC, animated: true)
        }
        
    }
    
    @objc func checkPhotoLibraryPermission()
    {
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == PHAuthorizationStatus.authorized){
            timerForCheckPhotoLibraryStatus.invalidate()
            self.SaveVideoInPhotoLibrary()
        }
        else if (status == PHAuthorizationStatus.denied){
            print("PHAuthorizationStatus denied")
        }
        else if (status == PHAuthorizationStatus.notDetermined)
        {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == PHAuthorizationStatus.authorized){
                    print("PHAuthorizationStatus authorized")
                }else{
                    print("PHAuthorizationStatus not authorized")
                }
            })
        }
        else if (status == PHAuthorizationStatus.restricted){
            print("PHAuthorizationStatus restricted")
        }
    }
    
    func SaveVideoInPhotoLibrary()
    {
        self.processVideo(url: self.watermarkURL!)
    }
    
    func mergeVideos(firestUrl : URL , SecondUrl : URL )
    {
        let tempURl = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/temp.mp4")
        print(tempURl)
        let boolValue = UserDefaults.standard.bool(forKey: "IsSelectingVideoFromGallery")
        if boolValue == true {
            MobileFFmpeg.execute( "-y -i \(SecondUrl.absoluteString) -i \(firestUrl.absoluteString) -i \(thirdUrl) -filter_complex [1]scale=(iw*0.30):(ih*0.30),pad=(iw+5):(ih+5):2:2:0xD6556B[scaled];[0:0][scaled]overlay=x=W-w-16:y=16[merged];[2:0]scale=w=250:h=90[water];[merged][water]overlay=x=(main_w-overlay_w):y=(main_h-overlay_h) \(tempURl.absoluteString)")
        }
        else {
            MobileFFmpeg.execute( "-y -i \(SecondUrl.absoluteString) -i \(firestUrl.absoluteString) -i \(thirdUrl) -filter_complex [1]scale=(iw*0.30):(ih*0.30),pad=(iw+5):(ih+5):2:2:0xD6556B[scaled];[0:0][scaled]overlay=x=W-w-16:y=16[merged];[2:0]scale=w=350:h=180[water];[merged][water]overlay=x=(main_w-overlay_w):y=(main_h-overlay_h) \(tempURl.absoluteString)")
        }
        
        
        
        //        let paymentTypePurchased = DefaultWrapper().getPaymentTypePurchased()
        //        print("paymentTypePurchased ====> \(paymentTypePurchased)")
        
        //        if (paymentTypePurchased == 0) {
        //            MobileFFmpeg.execute( "-y -i \(SecondUrl.absoluteString) -i \(firestUrl.absoluteString) -filter_complex [1]scale=(iw*0.30):(ih*0.30),pad=(iw+5):(ih+5):2:2:0xD6556B[scaled];[0:0][scaled]overlay=x=W-w-16:y=16 \(tempURl.absoluteString)")
        //        } else {
        //            MobileFFmpeg.execute( "-y -i \(SecondUrl.absoluteString) -i \(firestUrl.absoluteString) -i \(thirdUrl) -filter_complex [1]scale=(iw*0.30):(ih*0.30),pad=(iw+5):(ih+5):2:2:0xD6556B[scaled];[0:0][scaled]overlay=x=W-w-16:y=16[merged];[2:0]scale=w=350:h=180[water];[merged][water]overlay=x=(main_w-overlay_w):y=(main_h-overlay_h) \(tempURl.absoluteString)")
        //        }
        //let boolValue = UserDefaults.standard.bool(forKey: "IsSelectingVideoFromGallery")
        //        if boolValue == true {
        //            if (paymentTypePurchased == 0) {
        //                MobileFFmpeg.execute( "-y -i \(SecondUrl.absoluteString) -i \(firestUrl.absoluteString) -filter_complex [1]scale=(iw*0.30):(ih*0.30),pad=(iw+5):(ih+5):2:2:0xD6556B[scaled];[0:1][scaled]overlay=x=W-w-16:y=16 \(tempURl.absoluteString)")
        //            } else {
        //                MobileFFmpeg.execute( "-y -i \(SecondUrl.absoluteString) -i \(firestUrl.absoluteString) -i \(thirdUrl) -filter_complex [1]scale=(iw*0.30):(ih*0.30),pad=(iw+5):(ih+5):2:2:0xD6556B[scaled];[0:1][scaled]overlay=x=W-w-16:y=16[merged];[2:0]scale=w=350:h=180[water];[merged][water]overlay=x=(main_w-overlay_w):y=(main_h-overlay_h) \(tempURl.absoluteString)")
        //            }
        //        }
        //        else {
        //            if (paymentTypePurchased == 0) {
        //                MobileFFmpeg.execute( "-y -i \(SecondUrl.absoluteString) -i \(firestUrl.absoluteString) -filter_complex [1]scale=(iw*0.30):(ih*0.30),pad=(iw+5):(ih+5):2:2:0xD6556B[scaled];[0:0][scaled]overlay=x=W-w-16:y=16 \(tempURl.absoluteString)")
        //            } else {
        //                MobileFFmpeg.execute( "-y -i \(SecondUrl.absoluteString) -i \(firestUrl.absoluteString) -i \(thirdUrl) -filter_complex [1]scale=(iw*0.30):(ih*0.30),pad=(iw+5):(ih+5):2:2:0xD6556B[scaled];[0:0][scaled]overlay=x=W-w-16:y=16[merged];[2:0]scale=w=350:h=180[water];[merged][water]overlay=x=(main_w-overlay_w):y=(main_h-overlay_h) \(tempURl.absoluteString)")
        //            }
        //        }
        
        
        
        let tmpDirURL = FileManager.default.temporaryDirectory
        let strName : String = "viayou_\(self.randomStringWithLength(len: 13))"
        let strNameOfVideo : String = strName + ".\(tempURl.pathExtension)"
        let newURL = tmpDirURL.appendingPathComponent(strNameOfVideo)
        
        let fileUrl: URL
        fileUrl = tmpDirURL
        if let currentDate = fileUrl.creationDate {
            let presentDate = currentDate
            let newDate = presentDate.toString(dateFormat: "dd-MM-YYYY")
            print(newDate)
            self.dateCreated = newDate
            
        }
        print("\(strName).\(newURL.pathExtension)")
        self.nameOfVideo = "\(strName).\(newURL.pathExtension)"
        self.videoSize = "\(fileUrl.fileSizeString)"
        
        print("file size = \(fileUrl.fileSize), \(fileUrl.fileSizeString)")
        
        print("=============SAVE===========================")
        
        DispatchQueue.main.async {
            do {
                try FileManager.default.copyItem(at: tempURl, to: newURL)
                self.strName = strName
                self.typeString = newURL.pathExtension
                self.finalURL = newURL
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.uploadButton.isUserInteractionEnabled = true
                // self.view.isUserInteractionEnabled = true
                // self.uploadFile(with: strName, type: newURL.pathExtension, videoURL: newURL)
                
            } catch let error {
                DTMessageHUD.dismiss()
                NSLog("Unable to copy file: \(error)")
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    func exportCompositedVideo(compiledVideo: AVMutableComposition, toURL outputUrl: NSURL, withVideoComposition videoComposition: AVMutableVideoComposition) {
        DispatchQueue.main.async {
            guard let exporter = AVAssetExportSession(asset: compiledVideo, presetName: AVAssetExportPresetHighestQuality) else { return }
            exporter.outputURL = outputUrl as URL
            exporter.videoComposition = videoComposition
            exporter.outputFileType = AVFileType.mp4
            exporter.shouldOptimizeForNetworkUse = true
            exporter.exportAsynchronously(completionHandler: {
                switch exporter.status {
                case .completed:
                    print("VideoMaskingUtils.exportVideo SUCCESS!")
                    self.watermarkURL = exporter.outputURL
                    //self.processVideo(url: exporter.outputURL!)
                    if exporter.error != nil {
                        print("VideoMaskingUtils.exportVideo Error: \(String(describing: exporter.error))")
                        print("VideoMaskingUtils.exportVideo Description: \(exporter.description)")
                    }
                    break
                case .exporting:
                    let progress = exporter.progress
                    print("VideoMaskingUtils.exportVideo \(progress)")
                    break
                case .failed:
                    print("VideoMaskingUtils.exportVideo Error: \(String(describing: exporter.error))")
                    print("VideoMaskingUtils.exportVideo Description: \(exporter.description)")
                    break
                    
                default: break
                }
            })
        }
    }
    
    func deleteFile(filePath:NSURL)
    {
        guard FileManager.default.fileExists(atPath: filePath.path!) else {
            return
        }
        do { try FileManager.default.removeItem(atPath: filePath.path!)
        } catch { fatalError("Unable to delete file: \(error)") }
    }
    
    
    func processVideo(url: URL)
    {
        
        DispatchQueue.main.async
            {
                DTMessageHUD.hud()
                if let item = MediaItem(url: url) {
                    let logoImage = UIImage(named: "logo")
                    let firstElement = MediaElement(image: logoImage!)
                    
                    if self.view.frame.size.height >= 812
                    {
                        firstElement.frame = CGRect(x:item.size.width - 100 , y:100, width:70, height: 70)
                    }else
                    {
                        firstElement.frame = CGRect(x:item.size.width - 90 , y:30, width:70, height: 70)
                    }
                    
                    item.add(elements: [firstElement])
                    let mediaProcessor = MediaProcessor()
                    mediaProcessor.processElements(item: item) { [weak self] (result, error) in
                        self!.outputURL = result.processedUrl
                        //                        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                        //                        let myDocumentPath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("processed.mov").absoluteString
                        //                        _ = NSURL(fileURLWithPath: myDocumentPath)
                        //                        let documentsDirectory2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
                        //                        self!.outputURL = documentsDirectory2.appendingPathComponent("video.mp4")
                        //                        self!.deleteFile(filePath: self!.outputURL as NSURL)
                        let tmpDirURL = FileManager.default.temporaryDirectory
                        let strName : String = "viayou_\(self!.randomStringWithLength(len: 13))"
                        let strNameOfVideo : String = strName + ".\(self!.outputURL.pathExtension)"
                        let newURL = tmpDirURL.appendingPathComponent(strNameOfVideo)
                        
                        
                        
                        
                        //                        let tempDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
                        //                        let targetURL = tempDirectoryURL.appendingPathComponent("\(resourceName).\(fileExtension)")
                        
                        //UISaveVideoAtPathToSavedPhotosAlbum(self!.outputURL!.path, nil, nil, nil)
                        print("=============SAVE===========================")
                        DispatchQueue.main.async {
                            //DTMessageHUD.dismiss()
                            //self!.btnRedo.isUserInteractionEnabled = true
                            //self!.btnSaveOutlet.isUserInteractionEnabled = true
                            
                            do {
                                try FileManager.default.copyItem(at: self!.outputURL, to: newURL)
                                self!.uploadFile(with: strName, type: newURL.pathExtension, videoURL: newURL)
                                
                            } catch let error {
                                DTMessageHUD.dismiss()
                                NSLog("Unable to copy file: \(error)")
                            }
                        }
                    }
                }
        }
    }
    
    
    func hexStringToUIColor (hex:String) -> UIColor
    {
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
    
    func randomStringWithLength(len: Int) -> NSString
    {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomString : NSMutableString = NSMutableString(capacity: len)
        for i in 0..<len
        {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        return randomString
    }
    
    
    @IBAction func reRecordButtonClicked(_ sender: Any) {
        self.navigationController?.popViewControllers(viewsToPop: 2)
        //self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewControllers(viewsToPop: 2)
    }
    
    
    func saveVideoToFile() {
        print("promptButtonClicked...")
        print("btnActionSaveToGallery :: dataDictToBePosted====>\(dataDictToBePosted)")
        self.activityIndicator.isHidden = false
        //self.view.isUserInteractionEnabled = false
        self.activityIndicator.startAnimating()
        let asset = AVURLAsset(url: urlOfSmallVideo, options: nil)
        audioURl = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/temp.m4a")
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let myDocumentPath = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("temp.m4a").absoluteString
        _ = NSURL(fileURLWithPath: myDocumentPath)
        let documentsDirectory2 = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        audioURl = documentsDirectory2.appendingPathComponent("Audio.m4a")
        self.deleteFile(filePath: audioURl as NSURL)
        asset.writeAudioTrackToURL(audioURl) { (success, error) -> () in
            if !success
            {
                print(error as Any)
            }
            else
            {
                self.mergeVideos(firestUrl: self.urlOfSmallVideo, SecondUrl: self.bigVideoURL)
            }
        }
    }
    
    @IBAction func uploadVideoButtonClicked(_ sender: Any) {
        print("uploadVideoButtonClicked...")
        //saving to gallery
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.finalURL)
        }) { saved, error in
            if saved {
                let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(defaultAction)
                //self.present(alertController, animated: true, completion: nil)
                print("Video saved in gallery")
            }
            else {
                print(error.debugDescription)
            }
        }
        //saving to gallery ends
        if promptTitleField.text == "" {
            self.displayAlert(msg: "Please Enter a Title for the Video")
            return
        }
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        self.uploadFile(with: self.strName, type: self.typeString, videoURL: self.finalURL)
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        DispatchQueue.main.async {
            self.viewFrame.layoutIfNeeded()
            self.smallPlayerLayer.frame = self.smallVIdeoView.bounds
            self.bigPlayerLayer.frame = self.bigVIdeoView.bounds
        }
    }
    
    
    @IBAction func videoDetailsButtonClicked(_ sender: Any) {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "MergeVideoInfoViewController") as! MergeVideoInfoViewController
        nextVC.dateCreated = self.dateCreated
        nextVC.videoName = self.nameOfVideo
        nextVC.sizeOfVideo = self.videoSize
        nextVC.modalPresentationStyle = .overCurrentContext
        self.present(nextVC, animated: true, completion: nil)
    }
    
    //MARK:- Watermark Addition
    func saveprofilePicToDocumentDirectory(_ chosenImage: UIImage) -> URL {
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
            // try chosenImage.jpegData(compressionQuality: 1.0)?.write(to: url, options: .atomic)
            try chosenImage.pngData()?.write(to: url, options: .atomic)
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
                                //                                self.activityIndicator.isHidden = true
                                //                                self.activityIndicator.stopAnimating()
                                //  self.present(alertController, animated: true, completion:nil)
                                
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




///watermark ends

extension AVAsset{
    func writeAudioTrackToURL(_ url: URL, completion: @escaping (Bool, Error?) -> ()) {
        do {
            let audioAsset = try self.audioAsset()
            audioAsset.writeToURL(url, completion: completion)
        } catch (let error as NSError){
            completion(false, error)
        }
    }
    
    func writeToURL(_ url: URL, completion: @escaping (Bool, Error?) -> ())
    {
        guard let exportSession = AVAssetExportSession(asset: self, presetName: AVAssetExportPresetAppleM4A) else {
            completion(false, nil)
            return
        }
        exportSession.outputFileType = .m4a
        exportSession.outputURL      = url
        print("+++++++++SusseccURL++++++++:::::\(url)")
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(true, nil)
            case .unknown, .waiting, .exporting, .failed, .cancelled:
                completion(false, nil)
            }
        }
    }
    
    func audioAsset() throws -> AVAsset
    {
        let composition = AVMutableComposition()
        let audioTracks = tracks(withMediaType: .audio)
        
        for track in audioTracks
        {
            let compositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try compositionTrack?.insertTimeRange(track.timeRange, of: track, at: track.timeRange.start)
            compositionTrack?.preferredTransform = track.preferredTransform
        }
        return composition
    }
    
}
extension URL {
    var attributes: [FileAttributeKey : Any]? {
        do {
            return try FileManager.default.attributesOfItem(atPath: path)
        } catch let error as NSError {
            print("FileAttribute error: \(error)")
        }
        return nil
    }
    var fileSize: UInt64 {
        return attributes?[.size] as? UInt64 ?? UInt64(0)
    }
    
    var fileSizeString: String {
        return ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file)
    }
    
    var creationDate: Date? {
        return attributes?[.creationDate] as? Date
    }
}

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
