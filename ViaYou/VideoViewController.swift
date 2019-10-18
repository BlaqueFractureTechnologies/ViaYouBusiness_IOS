//
//  VideoViewController.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 18/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit
import AVFoundation
import WebKit
import AVKit
import AssetsLibrary
import Photos
import AWSS3
import AWSCore
import AWSCognito
import Firebase
import CoreLocation

class VideoViewController: UIViewController {
    
    @IBOutlet var videoViewContainer: UIView!
    @IBOutlet var seekBar: UISlider!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var bottomButtonsContainerView: UIView!
    @IBOutlet var bottomButtonsContainerBottomMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    let captureSession = AVCaptureSession()
    var activeInput: AVCaptureDeviceInput!
    let movieOutput = AVCaptureMovieFileOutput()
    var outputURL: URL!
    var lbltimer = Timer()
    var currentTimeCounter = 0
    let bucketName = "dev-promptchu"
    var userID: String = ""
    var s3Url: URL!
    
    @IBOutlet weak var commentRecordButton: UIButton!
    
    var player:AVPlayer = AVPlayer()
    var playerLayer:AVPlayerLayer = AVPlayerLayer()
    var isPlayCompleted:Bool = false
    var videoUrl: String = ""
    var postId: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //        var videoUrl = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4?playsinline=1"
        
        
        videoUrl = videoUrl.replacingOccurrences(of: " ", with: "%20")
        print("Video url is: \(videoUrl)")
        
        self.player = AVPlayer(url: URL(string: videoUrl)!)
        self.view.layoutIfNeeded()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoViewContainer.bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoViewContainer.layer.addSublayer(playerLayer)
        player.prepareForInterfaceBuilder()
        
        playerLayer.videoGravity = AVLayerVideoGravity(rawValue: AVLayerVideoGravity.resizeAspectFill.rawValue)
        
        if let duration = player.currentItem?.asset.duration {
            let seconds = CMTimeGetSeconds(duration)
            let totalVideoDuration:Float = Float(seconds*1000.0)
            seekBar.minimumValue  = 0
            seekBar.maximumValue = totalVideoDuration
            seekBar.trackRect(forBounds: seekBar.bounds)
        }
        
        let interval = CMTime(seconds:1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) { time in
            let currentPlayingTime:Float = Float(CMTimeGetSeconds(time)*1000.0)
            self.seekBar.value = currentPlayingTime
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
       // pauseButton.alpha = 0
        
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardDidShowNotification),name: UIResponder.keyboardWillShowNotification,object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardDidShowNotification),name: UIResponder.keyboardWillHideNotification,object: nil)
        
        
        
        self.currentTimeCounter = 1
        
        
    }


    
    @objc func keyboardDidShowNotification(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardOriginY = keyboardFrame.cgRectValue.origin.y
            //print("keyboardOriginY====>\(keyboardOriginY)")
            
            var bottomSafeAreaheight:CGFloat = 0.0
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.keyWindow
                bottomSafeAreaheight = window?.safeAreaInsets.bottom ?? 0.0
            }
            //print("bottomSafeAreaheight====>\(bottomSafeAreaheight)")
            
            let deviceHeight = UIScreen.main.bounds.size.height
            //print("deviceHeight====>\(deviceHeight)")
            
            let bottomMargin = deviceHeight-keyboardOriginY
            DispatchQueue.main.async {
                if (keyboardOriginY>=deviceHeight) {
                    self.bottomButtonsContainerBottomMarginConstraint.constant = bottomMargin
                }else {
                    self.bottomButtonsContainerBottomMarginConstraint.constant = bottomMargin-bottomSafeAreaheight
                }
                self.view.layoutIfNeeded()
                self.videoViewContainer.layoutIfNeeded()
                self.playerLayer.layoutIfNeeded()
                self.playerLayer.frame = self.videoViewContainer.bounds
                
            }
        }
    }
    
    @IBAction func playButtonClicked(_ sender: Any) {
        if (isPlayCompleted == true) {
            player.seek(to: CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        }
        //commentField.resignFirstResponder()
        player.play()
        playerLayer.videoGravity = AVLayerVideoGravity(rawValue: AVLayerVideoGravity.resizeAspect.rawValue)
        playButton.alpha = 0
       // pauseButton.alpha = 1
    }
    
    @objc func playerItemDidPlayToEndTime() {
        print("playerItemDidPlayToEndTime.........")
        self.seekBar.minimumTrackTintColor = UIColor.red
        playButton.alpha = 0.5
     //   pauseButton.alpha = 0
        isPlayCompleted = true
    }
    
    
    //MARK:-
   
    

    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }
    
    //EDIT 1: I FORGOT THIS AT FIRST
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    
    @IBAction func backButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


