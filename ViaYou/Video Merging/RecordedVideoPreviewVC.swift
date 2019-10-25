//
//  RecordedVideoPreviewVC.swift
//  Promptchu
//
//  Created by Netra Technosys on 18/07/19.
//  Copyright © 2019 Netra Technosys. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class RecordedVideoPreviewVC: UIViewController {
    
    @IBOutlet var viewBackMenu: UIView!
    @IBOutlet var viewVideoPlayer: UIView!
    @IBOutlet var viewButton: UIView!
    @IBOutlet var viewFrame: UIView!
    @IBOutlet var viewNext: UIView!
    @IBOutlet var btnBackMenu: UIButton!
    @IBOutlet var btnNextVC: UIButton!
    @IBOutlet var imgBackMenu: UIImageView!
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var videoURL: URL?
    var player: AVPlayer?
    var playerController : AVPlayerViewController?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        viewVideoPlayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        viewFrame.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        viewNext.frame = CGRect(x: 5, y: self.view.frame.size.height - 145, width: self.view.frame.size.width - 10, height: 140)
        
        viewFrame.layer.borderWidth = 5
        viewFrame.layer.borderColor = hexStringToUIColor(hex: "F8CC5F").cgColor
        //        viewButton.layer.cornerRadius = viewButton.frame.size.height / 2
        //        viewButton.layer.borderWidth = 3
        //        viewButton.layer.borderColor = UIColor.yellow.cgColor
        // btnNextVC.imageView?.contentMode = .scaleAspectFit
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        DispatchQueue.main.async() {
            self.player = AVPlayer(url: self.videoURL!)
            self.playerController = AVPlayerViewController()
            guard self.player != nil && self.playerController != nil else {
                return
            }
            self.playerController!.showsPlaybackControls = false
            self.playerController!.player = self.player!
            self.addChild(self.playerController!)
            self.playerController!.view.frame.size = self.viewVideoPlayer.frame.size
            self.playerController?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.viewVideoPlayer.addSubview(self.playerController!.view)
            //            self.player?.play()
            //            NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
            // Allow background audio to continue to play
            do {
                if #available(iOS 10.0, *) {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient, mode: .default, options: [])
                } else {
                }
            } catch let error as NSError {
                print(error)
            }
            do {
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error as NSError {
                print(error)
            }
        }
        self.navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        self.player?.pause()
        self.player = nil
        self.navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.isTranslucent = true
    }
    @IBAction func playButtonPressed(_ sender: Any) {
        self.player?.play()
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
        //self.player?.pause()
    }
    
    @IBAction func btnBackAction(_ sender: Any)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPressToNextVc(_ sender: Any)
    {
        DispatchQueue.main.async() {
            let infovc = self.storyboard?.instantiateViewController(withIdentifier: "InfoVC") as! InfoVC
            infovc.getVideoURL = self.videoURL
            self.navigationController?.pushViewController(infovc, animated: true)
        }
    }
    
    @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
        if self.player != nil {
            self.player!.seek(to: CMTime.zero)
            self.player!.play()
        }
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
