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
import CoreLocation


enum QUWatermarkPosition {
    case TopLeft
    case TopRight
    case BottomLeft
    case BottomRight
    case Default
}

class MergeVideo: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, MergeVideoDescriptionPopUpViewControllerDelegate { //k*
    
    @IBOutlet weak var bigVIdeoView: UIView!
    @IBOutlet weak var smallVIdeoView: UIView!
    @IBOutlet weak var viewFrame: UIView!
    @IBOutlet weak var lblTimer: UILabel!
    //@IBOutlet var viewBtnNext: UIView!
    @IBOutlet weak var btnRedo: UIButton!
    @IBOutlet weak var btnSaveOutlet: UIButton!
    
    @IBOutlet weak var promptTitleField: UITextField!
    //@IBOutlet weak var promptDescriptionField: UITextField!
    @IBOutlet weak var promptDescriptionTextView: UITextView!
    //@IBOutlet weak var promptLocationField: UITextField!
    @IBOutlet weak var promptLocationLabel: UILabel!
    @IBOutlet weak var titleFieldContainer: UIView!
    @IBOutlet weak var promptRoundButtonContainer: UIView!
    
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
    let bucketName = "dev-promptchu"
    var contentUrl: URL!
    var s3Url: URL!
    
    var streetName: String = ""
    var countryCode: String = ""
    let locationManager = CLLocationManager()
    
    var dataDictToBePosted:[String:Any] = [:]
    
    
  //  var shadowsDataArray:[UserShadowsArrayObject] = []  //k*
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.viewSetUPDesign()
        //AWS SETUP FOR UPLOAD VIDEO ON AWS SERVER
        //SIMULATORE
        /*let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast2, identityPoolId:"us-east-2:3d024c5d-faba-4922-85e4-9b3d2d9581c9")
         let configuration = AWSServiceConfiguration(region:.USEast2, credentialsProvider:credentialsProvider)
         AWSServiceManager.default().defaultServiceConfiguration = configuration
         s3Url = AWSS3.default().configuration.endpoint.url*/
        //REAL DEVICE
        let accessKey = "AKIAJ6O3XJCBVT4WJEYQ"
        let secretKey = "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"
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: accessKey, secretKey: secretKey)
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USEast2, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        s3Url = AWSS3.default().configuration.endpoint.url
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        PlaybigViewVideo()
        PlaysmallViewVideo()
        self.hideKeyboardWhenTappedAround()
        
        btnRedo.isUserInteractionEnabled = true
        btnSaveOutlet.isUserInteractionEnabled = true
        videoTime = UserDefaults.standard.value(forKey: "videotime") as! Int
        self.currentTimeCounter = 1
        self.lableCounterTime()
        
        //Setup dict
        self.userID = Auth.auth().currentUser!.uid
        dataDictToBePosted["_id"] = ""
        dataDictToBePosted["title"] = promptTitleField.text
        dataDictToBePosted["description"] = "description...."
        dataDictToBePosted["user"] = self.userID
        
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
        
        print("dataDictToBePosted====>\(dataDictToBePosted)")
        
        getCurrentLocation()
        
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
        
//        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
//        let nextVC = storyBoard.instantiateViewController(withIdentifier: "MergeProductBrandCompanyPopUpViewController") as! MergeProductBrandCompanyPopUpViewController
//        nextVC.dataDictToBePosted = self.dataDictToBePosted
//        nextVC.delegate = self
//        nextVC.modalPresentationStyle = .overCurrentContext
//        self.present(nextVC, animated: true, completion: nil)
    }
    
    
    func mergeProductBrandCompanyPopUpVCUploadButtonClicked(dataDictToBePostedModified: [String : Any]) {
        self.dataDictToBePosted = dataDictToBePostedModified
        
        print("uploadButtonClicked :: dataDictToBePosted ====>\(dataDictToBePosted)")
        
        //edit started
        upodateCreatedAndUpdatedTme()
        print("btnActionSaveToGallery :: dataDictToBePosted====>\(dataDictToBePosted)")
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
                    let alertController = UIAlertController(title: "Promptchu", message: "Kindly Wait, Video is under the Process!", preferredStyle:.alert)
                    let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.cancel) {
                        UIAlertAction in}
                    alertController.addAction(action)
                    self.present(alertController, animated: true, completion:nil)
                }else
                {
                    let alertController = UIAlertController(title: "Promptchu", message: "Save video in Gallery?", preferredStyle:.alert)
                    let action = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                        UIAlertAction in
                    }
                    let action1 = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                        UIAlertAction in
                        self.HideButton()
                        self.timerForCheckPhotoLibraryStatus.invalidate()
                        self.timerForCheckPhotoLibraryStatus = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.checkPhotoLibraryPermission), userInfo: nil, repeats: true)
                    }
                    alertController.addAction(action)
                    alertController.addAction(action1)
                    self.present(alertController, animated: true, completion:nil)
                    
                }
            }
        }
        //edit ends
    }
    
    @IBAction func descriptionOverlayButtonClicked(_ sender: Any) {
        print("descriptionOverlayButtonClicked...")
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "MergeVideoDescriptionPopUpViewController") as! MergeVideoDescriptionPopUpViewController
        nextVC.descriptionText = promptDescriptionTextView.text ?? ""
        nextVC.delegate = self
        nextVC.modalPresentationStyle = .overCurrentContext
        self.present(nextVC, animated: true, completion: nil)
    }
    
    func mergeVideoDescriptionPopUpVCDescriptionTextSubmitted(descriptionString: String) {
        print("mergeVideoDescriptionPopUpVCDescriptionTextSubmitted...")
        
        self.promptDescriptionTextView.text = descriptionString
        dataDictToBePosted["description"]   = descriptionString
    }
    
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
    //MARK:- Get User Location
    
    //@IBAction func getCurrentLocation(_ sender: Any) {
    func getCurrentLocation() {
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        var locationDict:[String:Any] = [:]
        // Add below code to get address for touch coordinates.
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        geoCoder.reverseGeocodeLocation(location, completionHandler:
            {
                placemarks, error -> Void in
                
                // Place details
                guard let placeMark = placemarks?.first else { return }
                
                
                // Location name
                if let locationName = placeMark.location {
                    print(locationName)
                }
                // Street address
                if let street = placeMark.thoroughfare {
                    print(street)
                    self.streetName = street
                }
                // City
                if let city = placeMark.subAdministrativeArea {
                    print(city)
                }
                // Zip code
                if let zip = placeMark.isoCountryCode {
                    print(zip)
                    self.countryCode = zip
                }
                // Country
                if let country = placeMark.country {
                    print(country)
                }
                self.promptLocationLabel.text = "\(String(describing: self.streetName)), \(String(describing: self.countryCode))"
                print("Print location label :: \(String(describing: self.promptLocationLabel.text))")
                locationDict["address"] = self.promptLocationLabel.text ?? "No address"//Use: self.promptLocationLabel.text
                locationDict["type"] = "Point"
                
                var coordinatesArray:[Float] = []
                coordinatesArray.append(Float(locValue.longitude))  //Use: locValue.longitude
                coordinatesArray.append(Float(locValue.latitude)) //Use: locValue.latitude
                
                locationDict["coordinates"] = coordinatesArray  //Setup coordinatesArray
                
                self.dataDictToBePosted["location"] = locationDict  //Setup locationDict to main Dict
        })
        // locationManager.stopUpdatingLocation()
        
        
        // self.promptLocationLabel.text = "Mulgrave"
        
        
        
        
        
        locationManager.stopUpdatingLocation()
    }
    
    //location ends
    
    func viewSetUPDesign()
    {
        bigVIdeoView.layer.borderWidth = 5
        bigVIdeoView.layer.borderColor = hexStringToUIColor(hex: "F8CC5F").cgColor
        
        smallVIdeoView.layer.borderWidth = 5
        smallVIdeoView.layer.borderColor = hexStringToUIColor(hex: "F8CC5F").cgColor
        
        viewFrame.layer.borderWidth = 5
        viewFrame.layer.borderColor = hexStringToUIColor(hex: "F8CC5F").cgColor
        
        lblTimer.layer.cornerRadius = self.lblTimer.frame.size.height / 2
        lblTimer.clipsToBounds = true
        
        promptTitleField.layer.cornerRadius = self.promptTitleField.frame.size.height / 2
        promptTitleField.clipsToBounds = true
        promptTitleField.layer.borderColor = hexStringToUIColor(hex: "F8CC5F").cgColor
        promptTitleField.layer.borderWidth = 2
        promptDescriptionTextView.layer.cornerRadius = 8
        promptDescriptionTextView.clipsToBounds = true
        promptDescriptionTextView.layer.borderColor = hexStringToUIColor(hex: "F8CC5F").cgColor
        promptDescriptionTextView.layer.borderWidth = 2
        
        titleFieldContainer.layer.cornerRadius = 8
        titleFieldContainer.layer.borderColor = UIColor.white.cgColor
        titleFieldContainer.layer.borderWidth = 1.5
        
        promptRoundButtonContainer.layer.cornerRadius = promptRoundButtonContainer.frame.size.width/2.0
        promptRoundButtonContainer.layer.borderColor = UIColor.white.cgColor
        promptRoundButtonContainer.layer.borderWidth = 1.5
        promptRoundButtonContainer.backgroundColor = UIColor.clear
    }
    
    func PlaysmallViewVideo()
    {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                //let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
                let player = AVPlayer(url: self.urlOfSmallVideo!)
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = self.smallVIdeoView.bounds
                playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.smallVIdeoView.layer.addSublayer(playerLayer)
                player.play()
            }
        }
    }
    
    func PlaybigViewVideo()
    {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                let player = AVPlayer(url: self.bigVideoURL!)
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = self.bigVIdeoView.bounds
                playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.bigVIdeoView.layer.addSublayer(playerLayer)
                player.play()
            }
        }
    }
    
    func lableCounterTime()
    {
        lbltimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (returnedTimer) in
            self.lblTimer.text = String(format: "00:%02i", self.currentTimeCounter)
            self.currentTimeCounter += 1
            if self.currentTimeCounter == self.videoTime - 1
            {
                self.lblTimer.text = String(format: "00:%02i", self.currentTimeCounter)
                self.lbltimer.invalidate()
            }
        }
    }
    
    func SaveVideoDiscriptionDetails()
    {
        dicDiscription.setValue(promptTitleField.text, forKey: "videoTitle")
        dicDiscription.setValue(promptDescriptionTextView.text, forKey: "videoDescription")
        // dicDiscription.setValue(txtTagAnyPersone.text, forKey: "videoTag")
        dicDiscription.setValue(promptLocationLabel.text, forKey: "videotakePlace")
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
    
    func uploadFile(with resource: String, type: String, videoURL: URL)
    {
        upodateCreatedAndUpdatedTme()
        print("upodateCreatedAndUpdatedTme :: dataDictToBePosted====>\(dataDictToBePosted)")
        autoreleasepool{
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    //DTMessageHUD.hud()
                    
                    let key = "\(resource).\(type)"
                    //let localImagePath = Bundle.main.path(forResource: resource, ofType: type)!
                    //let localImageUrl = URL(fileURLWithPath: localImagePath)
                    
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
//                            ApiManager().addVideoPostToFirebase(dataDict: self.dataDictToBePosted, completion: { (responseDict, error) in
//                                if (error == nil) {
//                                    if (responseDict.success == true) {
//                                        print(responseDict)
//                                        print("Success :: updateProfileToAPI ====> \(responseDict.message)")
//                                    }
//                                }else {
//                                    self.displaySingleButtonAlert(message: error?.localizedDescription ?? "Network Error")
//                                }
//                            })
                            
                            
                           // /* OLD
                             ApiManager().addVideoPostToFirebase(userID: self.userID, title: self.promptTitleField.text ?? "", description: self.promptDescriptionTextView.text ?? "", fileName: key, completion: { (responseDict, error) in
                             if (error == nil) {
                             if (responseDict.success == true) {
                             print(responseDict)
                             print("Success :: updateProfileToAPI ====> \(responseDict.message)")
                             }
                             }else {
                             self.displaySingleButtonAlert(message: error?.localizedDescription ?? "Network Error")
                             }
                             
                             })
                            // */
                            //post video to firebase ends
                            print("Uploaded \(key)")
                            let alertController = UIAlertController(title: "Promptchu", message: ("Uploaded \(key)"), preferredStyle:.alert)
                            let action = UIAlertAction(title: "ok", style: UIAlertAction.Style.default) {
                                UIAlertAction in
                                
                                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                let homeVC = storyBoard.instantiateViewController(withIdentifier: "LibraryFeedsViewController") as! LibraryFeedsViewController
                                self.navigationController?.pushViewController(homeVC, animated: true)
                            }
                            alertController.addAction(action)
                            self.present(alertController, animated: true, completion:nil)
                            let contentUrl = self.s3Url.appendingPathComponent(self.bucketName).appendingPathComponent(key)
                            self.contentUrl = contentUrl
                        }
                        return nil
                    }
                }
            }
        }
    }
    
    @IBAction func btnPressToFristVC(_ sender: Any)
    {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnActionSaveToGallery(_ sender: Any)
    {
        DispatchQueue.main.async {
            //            self.activityIndicator.stopAnimating()
            //            self.activityIndicator.isHidden = true
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
    
    
    
    func HideButton()
    {
        btnRedo.isUserInteractionEnabled = false
        btnSaveOutlet.isUserInteractionEnabled = false
    }
    
    func mergeVideos(firestUrl : URL , SecondUrl : URL )
    {
        let tempURl = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/temp.mp4")
        print(tempURl)
        MobileFFmpeg.execute( "-y -i \(SecondUrl.absoluteString) -i \(firestUrl.absoluteString) -filter_complex [1]scale=(iw*0.30):(ih*0.30),pad=(iw+5):(ih+5):2:2:0xF6CD53[scaled];[0:0][scaled]overlay=x=W-w-16:y=16 \(tempURl.absoluteString)")
        
        
        let tmpDirURL = FileManager.default.temporaryDirectory
        let strName : String = "promptchu_\(self.randomStringWithLength(len: 13))"
        let strNameOfVideo : String = strName + ".\(tempURl.pathExtension)"
        let newURL = tmpDirURL.appendingPathComponent(strNameOfVideo)
        
        print("=============SAVE===========================")
        DispatchQueue.main.async {
            self.btnRedo.isUserInteractionEnabled = true
            self.btnSaveOutlet.isUserInteractionEnabled = true
            
            do {
                try FileManager.default.copyItem(at: tempURl, to: newURL)
                self.uploadFile(with: strName, type: newURL.pathExtension, videoURL: newURL)
                
            } catch let error {
                DTMessageHUD.dismiss()
                NSLog("Unable to copy file: \(error)")
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
                        let strName : String = "promptchu_\(self!.randomStringWithLength(len: 13))"
                        let strNameOfVideo : String = strName + ".\(self!.outputURL.pathExtension)"
                        let newURL = tmpDirURL.appendingPathComponent(strNameOfVideo)
                        
                        //                        let tempDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
                        //                        let targetURL = tempDirectoryURL.appendingPathComponent("\(resourceName).\(fileExtension)")
                        
                        //UISaveVideoAtPathToSavedPhotosAlbum(self!.outputURL!.path, nil, nil, nil)
                        print("=============SAVE===========================")
                        DispatchQueue.main.async {
                            //DTMessageHUD.dismiss()
                            self!.btnRedo.isUserInteractionEnabled = true
                            self!.btnSaveOutlet.isUserInteractionEnabled = true
                            
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
    
    
    
    
    
    //---------- //k*
//    func getUserShadows() {
//        let selfUserId = Auth.auth().currentUser!.uid
//        ApiManager().getShadowList(profileUserId: selfUserId, from: 0, size: 100) { (responseDictionary, error) in
//            if error == nil {
//                self.shadowsDataArray = responseDictionary.data
//                print("self.shadowsDataArray.count ====>\(self.shadowsDataArray)")
//                
//            }
//        }
//        
//    }
    
    @IBAction func tagButtonClicked(_ sender: Any) {
//        if (self.shadowsDataArray.count > 0) {
//            let storyBoard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
//            let nextVC = storyBoard.instantiateViewController(withIdentifier: "MergeTagPopUpViewController") as! MergeTagPopUpViewController
//            nextVC.modalPresentationStyle = .overCurrentContext
//            nextVC.shadowsDataArray = self.shadowsDataArray
//            nextVC.delegate = self
//            self.present(nextVC, animated: true, completion: nil)
//        }else {
//            print("No shadows available...")
//        }
//
    }
    
//    func mergeTagPopUpViewControllerDoneButtonClicked(passedShadowsDataArray: [UserShadowsArrayObject]) {
//        print("mergeTagPopUpViewControllerDoneButtonClicked :: passedShadowsDataArray = \(passedShadowsDataArray)")
//
//        var tagsArray:[String] = []
//        for i in 0..<passedShadowsDataArray.count {
//            print("passedShadowsDataArray[i].isSelectedForTag = \(passedShadowsDataArray[i].isSelectedForTag)")
//            if (passedShadowsDataArray[i].isSelectedForTag == true) {
//                tagsArray.append("\(passedShadowsDataArray[i]._id)")
//
//            }
//
//        }
//        dataDictToBePosted["tags"] = tagsArray  //Setup tagsArray to main Dict
//
//    }
}

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