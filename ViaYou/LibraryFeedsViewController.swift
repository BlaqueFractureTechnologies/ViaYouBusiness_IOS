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

class LibraryFeedsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectioView: UICollectionView!
    @IBOutlet weak var bottomPlusButton: UIButton!
    @IBOutlet weak var profilePicButton: UIButton!
    
    var dataArray:[String] = []
    var passedUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //get facebook profile picture
        let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"id, email, name, picture.width(480).height(480)"])
        graphRequest.start(completionHandler: { (connection, result, error) in
            if error != nil {
                print("Error",error!.localizedDescription)
            }
            else{
                print(result!)
                let field = result! as? [String:Any]
                //self.userNameLabel.text = field!["name"] as? String
                if let imageURL = ((field!["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String {
                    print(imageURL)
                    let url = URL(string: imageURL)
                    let data = NSData(contentsOf: url!)
                    let image = UIImage(data: data! as Data)
                    self.profilePicButton.setBackgroundImage(image, for: .normal)
                }
            }
        })
        //get facebook profile picture ends
        
        for _ in 0..<10 {
            dataArray.append("0")
        }
        collectioView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LibraryFeedsCollectionViewCell", for: indexPath) as! LibraryFeedsCollectionViewCell
        cell.configureCell(data: dataArray[indexPath.row])
        
        cell.infoButton.tag = indexPath.row
        cell.infoButton.addTarget(self, action: #selector(infoButtonClicked), for: UIControl.Event.touchUpInside)
        
        cell.infoSliderCloseButton.tag = indexPath.row
        cell.infoSliderCloseButton.addTarget(self, action: #selector(infoSliderCloseButtonClicked), for: UIControl.Event.touchUpInside)
        
        return cell
    }
    
    @objc func infoButtonClicked(_ sender:UIButton) {
        print("infoButtonClicked...")
        if (dataArray[sender.tag] == "0") {
            dataArray[sender.tag] = "1"
        }else {
            dataArray[sender.tag] = "0"
        }
        collectioView.reloadData()
    }
    
    @objc func infoSliderCloseButtonClicked(_ sender:UIButton) {
        print("infoSliderCloseButtonClicked...")
        if (dataArray[sender.tag] == "0") {
            dataArray[sender.tag] = "1"
        }else {
            dataArray[sender.tag] = "0"
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
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: "LessSpacePopUpViewController") as! LessSpacePopUpViewController
        nextVC.modalPresentationStyle = .overCurrentContext
        let navVC = UINavigationController(rootViewController: nextVC)
        navVC.isNavigationBarHidden = true
        self.navigationController?.present(navVC, animated: false, completion: nil)
    }
    
}
