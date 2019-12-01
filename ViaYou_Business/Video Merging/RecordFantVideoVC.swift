//
//  RecordFantVideoVC.swift
//  Promptchu
//
//  Created by Netra Technosys on 16/07/19.
//  Copyright © 2019 Netra Technosys. All rights reserved.
//

import UIKit
import AVFoundation

class RecordFantVideoVC: UIViewController,AVCaptureFileOutputRecordingDelegate {
    
    @IBOutlet weak var playVideoView: UIView!
    @IBOutlet weak var captureVideoView: UIView!
    @IBOutlet weak var viewRecordBtn: UIView!
    @IBOutlet weak var viewNextVcBtn: UIView!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var lblRecordTime: UILabel!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var redLineView: UIView!
    @IBOutlet weak var switchCamButton: UIButton!
    @IBOutlet weak var volumeButton: UIButton!
    
    
    var getVideoURL: URL!
    //shoot Video
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    var timer = Timer()
    var lbltimer = Timer()
    var currentTimeCounter = 0
    var videoTime = Int()
    var isLongerThanBackVideo: Bool = false
    var currentDirection: CameraDirection = .front
    
    var totalVideoTime: Int = 0
    
    enum CameraDirection {
        case front
        case back
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switchCamButton.alpha = 1
        topLabel.text = "Push the red button!"
        let myMutableString = NSMutableAttributedString(string: topLabel.text ?? "", attributes: nil)
        myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red:214.0/255.0, green:85.0/255.0, blue:107.0/255.0, alpha: 1.0), range: NSRange(location:0,length:8))
        topLabel.attributedText = myMutableString
        //  setupSession()
        if setupSession() {
            setupPreview()
            startSession()
            print(getVideoURL)
        }
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ViewSetUp()
        PlayVideo()
        
        self.currentTimeCounter = 1
        videoTime = UserDefaults.standard.value(forKey: "videotime") as! Int
    }
    
    func ViewSetUp() {
        
        captureVideoView.layer.borderWidth = 3
        captureVideoView.layer.borderColor = hexStringToUIColor(hex: "D6556B").cgColor
        lblRecordTime.layer.cornerRadius = self.lblRecordTime.frame.size.height / 2
        lblRecordTime.clipsToBounds = true
        btnRecord.imageView?.contentMode = .scaleAspectFit
    }
    var playerLayer  = AVPlayerLayer()
    func PlayVideo() {
        //let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
        //mute audio
        //mute audio ends
        let player = AVPlayer(url: getVideoURL!)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height )
        playVideoView.layer.addSublayer(playerLayer)
        //playVideoView.backgroundColor = UIColor.red
        //player.isMuted = true
        player.play()
    }
    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = self.captureVideoView.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        captureVideoView.layer.addSublayer(previewLayer)
    }
    
    func setupSession() -> Bool {
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        // Setup Camera
        // var camera = AVCaptureDevice.default(for: AVMediaType.video)!
        
        if currentDirection == .front {
            do {
                let input = try AVCaptureDeviceInput(device: self.cameraWithPosition(position: .front)!)
                // camera = AVCaptureDevice.Position.front
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                    activeInput = input
                }
                
            }
            catch {
                print("Error setting device video input: \(error)")
                
            }
        }
        else if currentDirection == .back {
            do {
                let input = try AVCaptureDeviceInput(device: self.cameraWithPosition(position: .back)!)
                // camera = AVCaptureDevice.Position.front
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                    activeInput = input
                }
            } catch {
                print("Error setting device video input: \(error)")
                
            }
            
        }
        // Setup Microphone
        let microphone = AVCaptureDevice.default(for: AVMediaType.audio)!
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
                //print(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
        }
        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        //        setupPreview()
        //        startSession()
        //        print(getVideoURL)
        return true
    }
    
    //MARK:- Camera Session
    func startSession() {
        
        if !captureSession.isRunning {
            DispatchQueue.main.async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            DispatchQueue.main.async {
                self.captureSession.stopRunning()
            }
        }
    }
    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        for device in devices {
            if device.position == position
            {
                return device //as? AVCaptureDevice
            }
        }
        return nil
    }
    
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
    
    func startRecording() {
        
        if movieOutput.isRecording == false {
            
            let connection = movieOutput.connection(with: AVMediaType.video)
            
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }
            
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            let device = activeInput.device
            
            if (device.isSmoothAutoFocusSupported) {
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
            }
            //EDIT2: And I forgot this
            outputURL = tempURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            self.overlayView.isHidden = true
            self.topLabel.alpha = 0
            self.bottomLabel.alpha = 0
            self.redLineView.alpha = 0
            self.btnRecord.setBackgroundImage(UIImage(named: "stop_record"), for: .normal)
            print("=====recording Start=====")
            lableCount()
            self.currentTimeCounter = 0
            //  timer = Timer.scheduledTimer(timeInterval: TimeInterval(videoTime), target: self, selector: #selector(stopRecording), userInfo: nil, repeats: false)
            timer = Timer.scheduledTimer(timeInterval: TimeInterval(videoTime), target: self, selector: #selector(continueRecordingAfterBackCamStopped), userInfo: nil, repeats: false)
        }
        else {
            stopRecording()
        }
        
    }
    //    @objc func stopvideo()
    //    {
    //        stopRecording()
    //    }
    
    @objc func continueRecordingAfterBackCamStopped() {
        self.isLongerThanBackVideo = true
        captureVideoView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height )
        previewLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height )
    }
    
    @objc func stopRecording() {
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
            print("stop--==-")
        }
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            
            let videoRecorded = outputURL! as URL
            self.btnRecord.setBackgroundImage(UIImage(named: "record_new"), for: .normal)
            print("=======video stop=========")
            stopSession()
            self.lblRecordTime.text = String(format: "00:%02i", self.currentTimeCounter)
            print(self.currentTimeCounter)
            print(self.videoTime)
            if self.videoTime > self.currentTimeCounter {
                self.totalVideoTime = (self.videoTime) * 1000
            }
            else {
                self.totalVideoTime = (self.currentTimeCounter) * 1000
            }
            print(self.totalVideoTime)
            lbltimer.invalidate()
            //
            let mergeVideo = self.storyboard?.instantiateViewController(withIdentifier: "MergeVideo") as! MergeVideo
            //        mergeVideo.smallViewURL = outputURL
            mergeVideo.bigVideoURL = getVideoURL
            mergeVideo.urlOfSmallVideo = outputURL
            mergeVideo.totalVideoTime = self.totalVideoTime
            self.navigationController?.pushViewController(mergeVideo, animated: true)
            //
            
        }
    }
    
    func lableCount()
    {
        lbltimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true)
        { (returnedTimer) in
            
            self.lblRecordTime.text = String(format: "00:%02i", self.currentTimeCounter)
            self.currentTimeCounter = self.currentTimeCounter + 1
            //  print(self.currentTimeCounter)
            //  print(self.videoTime)
            //
            //            if self.currentTimeCounter == self.videoTime - 1
            //            {
            //                self.lbltimer.invalidate()
            //                self.lblRecordTime.text = String(format: "00:%02i", self.currentTimeCounter)
            //            }
        }
    }
    
    @IBAction func btnShootVideo(_ sender: Any)
    {
        switchCamButton.alpha = 0
        startRecording()
        PlayVideo()
        // viewRecordBtn.isHidden = true
    }
    
    @IBAction func btnPressToNextVC(_ sender: Any)
    {
        let mergeVideo = self.storyboard?.instantiateViewController(withIdentifier: "MergeVideo") as! MergeVideo
        //        mergeVideo.smallViewURL = outputURL
        mergeVideo.bigVideoURL = getVideoURL
        mergeVideo.urlOfSmallVideo = outputURL
        mergeVideo.totalVideoTime = self.totalVideoTime
        self.navigationController?.pushViewController(mergeVideo, animated: true)
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
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
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        DispatchQueue.main.async {
            //self.viewFrame.layoutIfNeeded()
            //self.lblShowTimer.layer.cornerRadius = self.lblShowTimer.frame.size.height / 2.0
            self.playerLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height )
            if self.isLongerThanBackVideo == true {
                self.previewLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height )
                self.captureVideoView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height )
            }
            else {
                self.previewLayer.frame = self.captureVideoView.bounds
            }
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.configureVideoOrientation()
    }
    
    private func configureVideoOrientation() {
        if let previewLayer = self.previewLayer,
            let connection = previewLayer.connection {
            let orientation = UIDevice.current.orientation
            
            if connection.isVideoOrientationSupported,
                let videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) {
                previewLayer.frame = self.captureVideoView.bounds
                connection.videoOrientation = videoOrientation
            }
        }
    }
    
    @IBAction func volumeButtonClicked(_ sender: Any) {
    }
    
    @IBAction func switchCamButtonClicked(_ sender: Any) {
        //Change camera source
        if (currentDirection == .front) {
            currentDirection = .back
        } else {
            currentDirection = .front
        }
        captureSession.removeInput(activeInput)
        _ = setupSession()
    }
    
    var isSmallViewDragInProgress:Bool = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isLongerThanBackVideo == false {
            if let touch = touches.first {
                let touchLocation = touch.location(in: self.view)
                let captureVideoViewFrame = captureVideoView.bounds
                if (captureVideoViewFrame.contains(touchLocation)) {
                    print("touchesBegan :: Clicked Inside captureVideoViewFrame...")
                    isSmallViewDragInProgress = true
                }
            }
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isLongerThanBackVideo == false {
            if let touch = touches.first {
                let touchLocation = touch.location(in: self.view)
                if (isSmallViewDragInProgress == true) {
                    captureVideoView.center = touchLocation
                }
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSmallViewDragInProgress = true
    }
    
    
    //remove audio from video
    
    //remove audio from video ends
}


