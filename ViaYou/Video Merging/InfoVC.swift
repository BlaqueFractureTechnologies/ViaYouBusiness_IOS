//
//  InfoVC.swift
//  Promptchu
//
//  Created by Netra Technosys on 16/07/19.
//  Copyright © 2019 Netra Technosys. All rights reserved.
//

import UIKit
import AVFoundation

class InfoVC: UIViewController {

    @IBOutlet weak var videoPlayView: UIView!
    @IBOutlet weak var frontVideoView: UIView!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var lblShowTime: UILabel!
    
    var getVideoURL:URL!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        videoPlayView.layer.borderWidth = 5
        videoPlayView.layer.borderColor = hexStringToUIColor(hex: "F8CC5F").cgColor
        frontVideoView.layer.borderWidth = 5
        frontVideoView.layer.borderColor = hexStringToUIColor(hex: "F8CC5F").cgColor
        lblShowTime.layer.cornerRadius = self.lblShowTime.frame.size.height / 2
        lblShowTime.clipsToBounds = true
        btnRecord.imageView?.contentMode = .scaleAspectFit
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        print("InfoVC")
    }
    
    override var prefersStatusBarHidden: Bool
    {
        return true
    }
    
    func PlayVideo()
    {
        let player = AVPlayer(url: getVideoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 5, y: 5, width: videoPlayView.frame.size.width - 10, height: videoPlayView.frame.size.height - 10)
        videoPlayView.layer.addSublayer(playerLayer)
        player.play()
    }
  
    @IBAction func btnPressToNextVC(_ sender: Any)
    {
        let frontVideo = self.storyboard?.instantiateViewController(withIdentifier: "RecordFantVideoVC") as! RecordFantVideoVC
        frontVideo.getVideoURL = getVideoURL
        self.navigationController?.pushViewController(frontVideo, animated: true)
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
