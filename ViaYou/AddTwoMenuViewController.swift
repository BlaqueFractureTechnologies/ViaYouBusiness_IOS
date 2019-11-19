//
//  AddTwoMenuViewController.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 25/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit
import AVKit
@objc protocol AddTwoMenuViewControllerDelegate{
    @objc optional func AddTwoMenuViewController_screencastButtonClicked()
    @objc optional func AddTwoMenuViewController_videomergeButtonClicked()
}

class AddTwoMenuViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    @IBOutlet weak var dualScreencastButton: UIButton!
    @IBOutlet weak var videoMergeButton: UIButton!
    
    var delegate:AddTwoMenuViewControllerDelegate?
    let imagePickerController = UIImagePickerController()
    var videoURL: URL!


    override func viewDidLoad() {
        super.viewDidLoad()
        dualScreencastButton.layer.cornerRadius = self.dualScreencastButton.frame.size.height / 2
        dualScreencastButton.clipsToBounds = true
        videoMergeButton.layer.cornerRadius = self.videoMergeButton.frame.size.height / 2
        videoMergeButton.clipsToBounds = true

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func dualScreenCastButtonClicked(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.AddTwoMenuViewController_screencastButtonClicked!()
        }
//        DispatchQueue.main.async {
//            self.chooseImage(source: .savedPhotosAlbum)
//        }
//            let alert = UIAlertController(title: "Choose your option", message: "", preferredStyle: UIAlertController.Style.alert)
//            alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { action in
//                DispatchQueue.main.async {
//                    self.chooseImage(source: .savedPhotosAlbum)
//                }
//            }))
//            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
        
            
//        imagePickerController.sourceType = .photoLibrary
//
//        imagePickerController.delegate = self
//
//        imagePickerController.mediaTypes = ["public.movie"]
//
//        present(imagePickerController, animated: true, completion: nil)
        
        //}
    }
//     func chooseImage(source:UIImagePickerController.SourceType) {
//        imagePickerController.sourceType = .photoLibrary
//        imagePickerController.delegate = self
//        imagePickerController.mediaTypes = ["public.movie"]
//
//        present(imagePickerController, animated: true, completion: nil)
//    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let videoURL = info[.mediaURL] as? URL
        print(videoURL)
        // get the asset
        let asset = AVURLAsset(url: videoURL!)
        
        // get the time in seconds
        let durationInSeconds = asset.duration.seconds
        print(durationInSeconds)
        UserDefaults.standard.set(durationInSeconds, forKey: "videotime")
        
        let recordVC = self.storyboard?.instantiateViewController(withIdentifier: "RecordFantVideoVC") as! RecordFantVideoVC
        recordVC.getVideoURL = videoURL
        self.navigationController?.pushViewController(recordVC, animated: true)
//        let videoURL = info["UIImagePickerControllerReferenceURL"] as? NSURL
//        print(videoURL!)
//        imagePickerController.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func videoMergeButtonClicked(_ sender: Any) {

        self.dismiss(animated: true) {
            self.delegate?.AddTwoMenuViewController_videomergeButtonClicked!()
            
        }

    }
    
}
