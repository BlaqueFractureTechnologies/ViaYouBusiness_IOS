//
//  UserTipsViewController.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 8/11/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class UserTipsViewController: UIViewController, UIScrollViewDelegate {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
//    @IBOutlet weak var scrollImageView: UIImageView!

    
    var currentPageNumber:Int = 0
    var _w:CGFloat = UIScreen.main.bounds.size.width
    var _h:CGFloat = UIScreen.main.bounds.size.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        startButton.alpha = 0
       // scrollView.frame = CGRect(x: 0, y: 0, width: _w, height: _h-80)
        
        for i in 0...4 {
            //            let imgOne = UIImageView(frame: CGRect(x: 0, y: 0, width: _w, height: _h - 80))
            //            imgOne.center = CGPoint(x: (_w/2.0)+(_w*CGFloat(i)), y: (_h/2.0)-40)
            //            scrollView.addSubview(imgOne)
            
//            let scrollImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height))
//            scrollImageView.center = CGPoint(x: self.scrollView.frame.width/2, y: self.scrollView.frame.height/2)
//            scrollView.addSubview(scrollImageView)
            let scrollImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.scrollView.frame.width-20, height: self.scrollView.frame.height))
            scrollImageView.center = CGPoint(x: (_w/4)+(_w*CGFloat(i)), y: (_h/2.0))
            scrollView.addSubview(scrollImageView)
            
            if (i==0) {
                scrollImageView.image = UIImage(named: "Onboarding_1")
            }else if (i==1) {
                scrollImageView.image = UIImage(named: "Onboarding_2")
                
            }else if (i==2) {
                scrollImageView.image = UIImage(named: "Onboarding_3")
                
            }else if (i==3) {
                scrollImageView.image = UIImage(named: "Onboarding_4")
            }else if (i==4) {
                scrollImageView.image = UIImage(named: "Onboarding_5")
                
            }
        }
        scrollView.contentSize = CGSize(width: 5*_w, height: 0)
        pageControl.numberOfPages = 5
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth:CGFloat = scrollView.frame.width
        currentPageNumber = Int(floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1)
        print("currentPage====\(currentPageNumber)")
        pageControl.currentPage = currentPageNumber
 
        if currentPageNumber > 3 { // 0 to 4
            skipButton.alpha = 0
            nextButton.alpha = 0
            startButton.alpha = 1
        } else {
            skipButton.alpha = 1
            nextButton.alpha = 1
            startButton.alpha = 0
        }
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        currentPageNumber = currentPageNumber+1
        scrollView.setContentOffset(CGPoint(x: CGFloat(currentPageNumber)*_w, y: 0), animated: true)
        pageControl.currentPage = currentPageNumber
        
        if currentPageNumber > 3 { // 0 to 4
            skipButton.alpha = 0
            nextButton.alpha = 0
            startButton.alpha = 1
        }
        
    }
    @IBAction func skipButtonClicked(_ sender: Any) {
//        UserDefaults.standard.set(true, forKey: "logged_in")
        //saving user details
//        let registeredNumber = UserDefaults.standard.string(forKey: "PhoneNumber") ?? "+61402993278"
//        let registeredEmail  = "test@zoleo.com";
//        DefaultWrapper().saveRegisteredMobileNumber(mobileNumber: registeredNumber)
//        DefaultWrapper().setRegisteredEmailAddress(RegisteredEmailAddress: registeredEmail)
//        self.performSegue(withIdentifier: .seeTips, sender: self)
    }
    
    @IBAction func startButtonClicked(_ sender: Any) {
        // UserDefaults.standard.set(true, forKey: "termsAndConditions")
//        UserDefaults.standard.set(true, forKey: "logged_in")
//        //saving user details
//        let registeredNumber = UserDefaults.standard.string(forKey: "PhoneNumber") ?? "+61402993278"
//        let registeredEmail  = "test@zoleo.com";
//        DefaultWrapper().saveRegisteredMobileNumber(mobileNumber: registeredNumber)
//        DefaultWrapper().setRegisteredEmailAddress(RegisteredEmailAddress: registeredEmail)
//        self.performSegue(withIdentifier: .seeTips, sender: self)
    }
}
