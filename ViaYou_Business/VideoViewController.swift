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
    //    @IBOutlet var bottomButtonsContainerView: UIView!
    //    @IBOutlet var bottomButtonsContainerBottomMarginConstraint: NSLayoutConstraint!
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
        
        DispatchQueue.main.async {
            self.setUpVideoPlayer()
        }
    }
    
    func setUpVideoPlayer() {
        
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
        
        //        if let duration = player.currentItem?.asset.duration {
        //            let seconds = CMTimeGetSeconds(duration)
        //            var totalVideoDuration:Float = Float(seconds*1000.0)
        //            if (totalVideoDuration.isNaN == true) {
        //                totalVideoDuration = 0
        //            }
        //
        //            seekBar.minimumValue  = 0
        //            seekBar.maximumValue = totalVideoDuration
        //            seekBar.trackRect(forBounds: seekBar.bounds)
        //        }
        
//        let activityIndicator  = UIActivityIndicatorView(style: .white)
//        activityIndicator.center = CGPoint(x: UIScreen.main.bounds.size.width/2.0, y: UIScreen.main.bounds.size.height/2.0)
//        activityIndicator.hidesWhenStopped = true
//        self.view.addSubview(activityIndicator)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: URL(string: self.videoUrl)!)
            let duration = asset.duration
            let seconds = CMTimeGetSeconds(duration)
            var totalVideoDuration:Float = Float(seconds*1000.0)
            if (totalVideoDuration.isNaN == true) {
                totalVideoDuration = 0
            }
            DispatchQueue.main.async {
                self.seekBar.minimumValue  = 0
                self.seekBar.maximumValue = totalVideoDuration
                self.seekBar.trackRect(forBounds: self.seekBar.bounds)
                print("Loaded video...")
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
        
        let interval = CMTime(seconds:1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) { time in
            let currentPlayingTime:Float = Float(CMTimeGetSeconds(time)*1000.0)
            self.seekBar.value = currentPlayingTime
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        
        self.currentTimeCounter = 1
        
    }
    
    
    @IBAction func playButtonClicked(_ sender: Any) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
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
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        player.pause()
        
    }
}


