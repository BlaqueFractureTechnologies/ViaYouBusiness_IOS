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


class DeletedVideosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    
    @IBOutlet weak var collectioView: UICollectionView!
    @IBOutlet weak var profilePicButton: UIButton!
    
    
    var dataArray:[FeedDataArrayObject] = []
    var bucketDataArray:BucketDataObject = BucketDataObject([:])
    var passedProfileImage = UIImage()
    var userId: String = ""
    let bucketName = "dev-promptchu"
    var contentUrl: URL!
    var s3Url: URL!
    
    var streetName: String = ""
    var countryCode: String = ""
    let profileImageUrlHeader:String = "https://dev-promptchu.s3.us-east-2.amazonaws.com/"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userId = Auth.auth().currentUser!.uid
        print(self.passedProfileImage)
        
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
        
        
        collectioView.reloadData()
        getResponseFromJSONFile()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        s3Url = AWSS3.default().configuration.endpoint.url
        
        UserDefaults.standard.set(false, forKey: "isTappedFromSingleVideo")
        
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
                            self.collectioView.reloadData()
                            
                        }
                        
                    }
                    
                }
            } catch {
                
            }
        }
    }
    
    func getResponseFromJSONFile() {
        
        //get deleted vdos
        ApiManager().ListDeletedScreencastAPI { (responseDict, error) in
            if error == nil {
                print("getNewsFeedsForYouResponseFromAPI :: responseDict\(responseDict.message)")
                if responseDict.data.count == 0 {
                    
                    DispatchQueue.main.async {
                        self.collectioView.reloadData()
                        
                    }
                }
                else {
                    
                    print("getNewsFeedsForYouResponseFromAPI :: responseDict\(responseDict.success)")
                    for i in 0..<responseDict.data.count {
                        let indexDict = responseDict.data[i]
                        self.dataArray.append(indexDict)
                        print("getLibraryResponseFromAPI :: filename\(indexDict.fileName)")
                    }
                    self.loadAllVideoImagesForDataArray()
                    //  self.loadVideoSize()
                    DispatchQueue.main.async {
                        self.collectioView.reloadData()
                        
                    }
                    
                }
            }
                
            else {
                print(error?.localizedDescription)
            }
        }
        //get deleted vdos end
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DeletedVideosCollectionViewCell", for: indexPath) as! DeletedVideosCollectionViewCell
        cell.configureCell(dataDict: dataArray[indexPath.row])
        
        cell.shareButton.tag = indexPath.row
        cell.shareButton.addTarget(self, action: #selector(shareButtonClicked), for: UIControl.Event.touchUpInside)
        
        
        return cell
    }
    
    @objc func shareButtonClicked(_ sender:UIButton) {
        print(dataArray[sender.tag]._id)
        let tappedPostId = dataArray[sender.tag]._id
        ApiManager().restoreVideosAPI(postId: tappedPostId) { (response, error) in
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
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.size.width/2.0)-10
        return CGSize(width: cellWidth, height: cellWidth*1.41)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt...")
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
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    
}

