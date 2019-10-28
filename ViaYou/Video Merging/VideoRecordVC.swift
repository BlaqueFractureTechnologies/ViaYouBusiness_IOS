//
//  VideoRecordVC.swift
//  Promptchu
//
//  Created by Netra Technosys on 16/07/19.
//  Copyright © 2019 Netra Technosys. All rights reserved.
//

import UIKit
import AVFoundation

class VideoRecordVC: UIViewController,AVCaptureFileOutputRecordingDelegate
{
    @IBOutlet var viewFrame: UIView!
    @IBOutlet weak var videoView: UIView!
    
    @IBOutlet weak var recordBtnOutlet: UIButton!
    
    @IBOutlet weak var lblShowTimer: UILabel!
    
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!

    var timer = Timer()
    var timerforRecord = Timer()
    
    var currentTimeCounter = 1
   
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
//        viewFrame.layer.borderWidth = 5
//        viewFrame.layer.borderColor = hexStringToUIColor(hex: "F8CC5F").cgColor
        
        recordBtnOutlet.imageView?.contentMode = .scaleAspectFit
        
        lblShowTimer.isHidden = true
        lblShowTimer.layer.cornerRadius = self.lblShowTimer.frame.size.height / 2
        lblShowTimer.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.currentTimeCounter = 1
        if setupSession()
        {
            setupPreview()
            startSession()
        }
        else
        {
            print("Not set Setup session")
        }
        lblShowTimer.text = "00:00"
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    func setupPreview()
    {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = videoView.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoView.layer.addSublayer(previewLayer)
    }
    
    func setupSession() -> Bool
    {
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        // Setup Camera
        let camera = AVCaptureDevice.default(for: AVMediaType.video)!
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input)
            {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        return true
    }
 
    //MARK:- Camera Session
    func startSession()
    {
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
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation
    {
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
    func tempURL() -> URL?
    {
        let directory = NSTemporaryDirectory() as NSString
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        return nil
    }  
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!)
    {
        print("didStartRecordingToOutputFileAt")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?)
    {
        if (error != nil)
        {
            print("Error recording movie: \(error!.localizedDescription)")
        } else
        {
            let videoRecorded = outputURL! as URL
            print("=======video stop=========")
            print(videoRecorded)
            getVideoTime()
           // performSegue(withIdentifier: "goToPreview", sender: nil)

//            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//            let recordVC = storyBoard.instantiateViewController(withIdentifier: "RecordedVideoPreviewVC") as! RecordedVideoPreviewVC
//            recordVC.videoURL = outputFileURL
//            let navVC = UINavigationController(rootViewController: recordVC)
//            navVC.isNavigationBarHidden = true
//            self.navigationController?.pushViewController(recordVC, animated: true) RecordFantVideoVC
//            let recordVC = self.storyboard?.instantiateViewController(withIdentifier: "RecordedVideoPreviewVC") as! RecordedVideoPreviewVC
//            recordVC.videoURL = outputFileURL
//            self.navigationController?.pushViewController(recordVC, animated: true)
            let recordVC = self.storyboard?.instantiateViewController(withIdentifier: "RecordFantVideoVC") as! RecordFantVideoVC
            recordVC.getVideoURL = outputFileURL
            self.navigationController?.pushViewController(recordVC, animated: true)
        }
    }
    
    func getVideoTime()
    {
        UserDefaults.standard.set(self.currentTimeCounter, forKey: "videotime")
    }
    
    @objc func stopRecording() {
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
            stopSession()
            print("** Stop Recording **")
        }
    }
    
    @IBAction func btnRecoerVideo(_ sender: Any)
    {
        if movieOutput.isRecording == false
        {
            let connection = movieOutput.connection(with: AVMediaType.video)
            if (connection?.isVideoOrientationSupported)!
            {
                connection?.videoOrientation = currentVideoOrientation()
            }
            
            if (connection?.isVideoStabilizationSupported)!
            {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            let device = activeInput.device
            if (device.isSmoothAutoFocusSupported)
            {
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
             self.lblShowTimer.isHidden = false
            print("=====recording Start=====")
            timer.invalidate()
            timerforRecord.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(stopRecording), userInfo: nil, repeats: false)
            self.currentTimeCounter = 1
            timerforRecord = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (returnedTimer) in
                
                self.lblShowTimer.text = String(format: "00:%02i", self.currentTimeCounter)
                self.currentTimeCounter += 1
                if self.currentTimeCounter > 61
                {
                    self.currentTimeCounter = 0
                }
            }
        }
        else
        {
            stopRecording()
            self.lblShowTimer.isHidden = true
            timer.invalidate()
            timerforRecord.invalidate()
        }
    }
    
    override func didReceiveMemoryWarning() {
        if (self.isViewLoaded) && (self.view.window == nil) {
            self.view = nil
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
}

