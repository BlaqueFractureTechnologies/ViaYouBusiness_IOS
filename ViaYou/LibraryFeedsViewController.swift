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

class LibraryFeedsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var collectioView: UICollectionView!
    @IBOutlet weak var bottomPlusButton: UIButton!
    @IBOutlet weak var profilePicButton: UIButton!
    
    var dataArray:[FeedDataArrayObject] = []
    var passedProfileImage = UIImage()
    var userId: String = ""
    var invitationUrl: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userId = Auth.auth().currentUser!.uid
        print(self.passedProfileImage)
        self.profilePicButton.setBackgroundImage(self.passedProfileImage, for: .normal)
        collectioView.reloadData()
        getResponseFromJSONFile()
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
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(displayBottomPlusButtonCircularWave), userInfo: nil, repeats: false)
    }
    
    
    func getResponseFromJSONFile() {
        
        ApiManager().getAllPostsAPI(from: "0", size: "10") { (responseDict, error) in
            if error == nil {
                print("getNewsFeedsForYouResponseFromAPI :: responseDict\(responseDict.success)")
                for i in 0..<responseDict.data.count {
                    let indexDict = responseDict.data[i]
                    indexDict.isInfoPopUpDisplaying = false
                    self.dataArray.append(indexDict)
                    print("getLibraryResponseFromAPI :: filename\(indexDict.fileName)")
                }
                self.loadAllVideoImagesForDataArray()
                DispatchQueue.main.async {
                    self.collectioView.reloadData()
                    
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
        let cellWidth = (collectionView.frame.size.width/3.0)-10
        return CGSize(width: cellWidth, height: cellWidth*1.41)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt...")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "NoScreenCastsPopUpViewController") as! NoScreenCastsPopUpViewController
        nextVC.modalPresentationStyle = .overCurrentContext
        let navVC = UINavigationController(rootViewController: nextVC)
        navVC.isNavigationBarHidden = true
        self.navigationController?.present(navVC, animated: false, completion: nil)
    }
    
    @IBAction func plusButtonClicked() {
        print("didSelectItemAt...")
        
        
        
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

    
    func loadAllVideoImagesForDataArray() {
        for i in 0..<dataArray.count {
            let userID = dataArray[i].user._id
            let videoName = dataArray[i].fileName
            var videUrlString = "https://dev-promptchu.s3.us-east-2.amazonaws.com/posts/\(userID)/\(videoName)"
            videUrlString = videUrlString.replacingOccurrences(of: " ", with: "%20")
            print("videUrlString :: \(videUrlString)")
            
            DispatchQueue.global(qos: .userInitiated).async {
                let image = self.previewImageFromVideo(url: URL(string: videUrlString)! as NSURL)
                if (image != nil) {
                    self.dataArray[i].user.videoImage = image!
                    DispatchQueue.main.async {
                        print("****Loaded image at index :: \(i)")
                        self.collectioView.reloadData()
                    }
                }
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
    
}
