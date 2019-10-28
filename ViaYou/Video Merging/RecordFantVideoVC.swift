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
    
    @IBOutlet weak var btnNectVc: UIButton!
    
    @IBOutlet weak var lblRecordTime: UILabel!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if setupSession() {
            setupPreview()
            startSession()
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
        playVideoView.layer.borderWidth = 5
        playVideoView.layer.borderColor = hexStringToUIColor(hex: "F8CC5F").cgColor
        captureVideoView.layer.borderWidth = 5
        captureVideoView.layer.borderColor = hexStringToUIColor(hex: "F8CC5F").cgColor
        //        viewNextVcBtn.layer.cornerRadius = viewNextVcBtn.frame.size.height/2
        //        viewNextVcBtn.clipsToBounds = true
        //        viewNextVcBtn.layer.borderWidth = 5
        //        viewNextVcBtn.layer.borderColor = UIColor.white.cgColor
        //  viewRecordBtn.isHidden = false
        btnNectVc.isHidden = true
        lblRecordTime.layer.cornerRadius = self.lblRecordTime.frame.size.height / 2
        lblRecordTime.clipsToBounds = true
        btnRecord.imageView?.contentMode = .scaleAspectFit
        btnNectVc.imageView?.contentMode = .scaleAspectFit
    }
    func PlayVideo() {
        //let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
        let player = AVPlayer(url: getVideoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 5, y: 5, width: self.view.frame.size.width, height: self.view.frame.size.height )
        playVideoView.layer.addSublayer(playerLayer)
        player.play()
    }
    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = captureVideoView.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        captureVideoView.layer.addSublayer(previewLayer)
    }
//    override func viewDidLayoutSubviews() {
//        self.configureVideoOrientation()
//    }
//
//    private func configureVideoOrientation() {
//        if let previewLayer = self.previewLayer,
//            let connection = previewLayer.connection {
//            let orientation = UIDevice.current.orientation
//
//            if connection.isVideoOrientationSupported,
//                let videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) {
//                previewLayer.frame = captureVideoView.bounds
//                connection.videoOrientation = videoOrientation
//            }
//        }
//    }
    func setupSession() -> Bool {
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        // Setup Camera
        // var camera = AVCaptureDevice.default(for: AVMediaType.video)!
        
        do {
            let input = try AVCaptureDeviceInput(device: self.cameraWithPosition(position: .front)!)
            // camera = AVCaptureDevice.Position.front
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        // Setup Microphone
        let microphone = AVCaptureDevice.default(for: AVMediaType.audio)!
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
                print(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }
        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
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
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //
    //        let vc = segue.destination as! VideoPlaybackViewController
    //
    //        vc.videoURL = sender as? URL
    //
    //    }
    
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
        captureVideoView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height )
        previewLayer.frame = CGRect(x: 5, y: 5, width: self.view.frame.size.width, height: self.view.frame.size.height )        
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
            print("=======video stop=========")
            stopSession()
            btnNectVc.isHidden = false
            self.lblRecordTime.text = String(format: "00:%02i", self.currentTimeCounter)
            lbltimer.invalidate()
        }
    }
    
    func lableCount()
    {
        lbltimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true)
        { (returnedTimer) in
            
            self.lblRecordTime.text = String(format: "00:%02i", self.currentTimeCounter)
            self.currentTimeCounter = self.currentTimeCounter + 1
            print(self.currentTimeCounter)
            print(self.videoTime)
            
            if self.currentTimeCounter == self.videoTime - 1
            {
                self.lbltimer.invalidate()
                self.lblRecordTime.text = String(format: "00:%02i", self.currentTimeCounter)
            }
        }
    }
    
    @IBAction func btnShootVideo(_ sender: Any)
    {
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
}
