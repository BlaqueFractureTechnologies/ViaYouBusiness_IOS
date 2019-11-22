//
//  NoScreenCastsPopUpViewController.swift
//  ViaYou
//
//  Created by Arya S on 29/09/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class NoScreenCastsPopUpViewController: UIViewController {
    
    @IBOutlet weak var titleBra: UIView!
    @IBOutlet weak var popUpBgView: UIView!
    @IBOutlet weak var bottomPlusButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        popUpBgView.addDropShadow()
        
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(displayBottomPlusButtonCircularWave), userInfo: nil, repeats: false)
    }
    
    @objc func displayBottomPlusButtonCircularWave() {
        self.view.layoutIfNeeded()
        
        let wave = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        wave.backgroundColor = self.view.themeRedColor()
        wave.layer.cornerRadius = wave.frame.size.width/2.0
        wave.clipsToBounds = true
        self.view.addSubview(wave)
        self.view.bringSubviewToFront(bottomPlusButton)
        self.view.bringSubviewToFront(popUpBgView)
        
        wave.center = CGPoint(x: UIScreen.main.bounds.size.width/2.0, y: UIScreen.main.bounds.size.height)
        
        UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseIn, animations: {
            wave.transform = CGAffineTransform(scaleX: 50.0, y: 50.0)
            //wave.alpha = 0
        }) { (completed) in
            
        }
    }
    
    @IBAction func dismissPopUp() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
