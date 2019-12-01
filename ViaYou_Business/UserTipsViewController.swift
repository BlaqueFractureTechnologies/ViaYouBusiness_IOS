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
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    
    var currentPage:Int = 0
    var passedProfileImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        finishButton.alpha = 0
        prevButton.alpha = 0.65
        setUpScrollViewElements()
    }
    
    func setUpScrollViewElements() {
        let _w = UIScreen.main.bounds.size.width
        scrollView.layoutIfNeeded()
        for i in 0...3 {
            let infoImage = UIImageView(frame: scrollView.bounds)
            infoImage.backgroundColor = UIColor.clear
            infoImage.center = CGPoint(x: (_w/2.0)+(_w*CGFloat(i)), y: scrollView.frame.size.height/2.0)
            infoImage.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            infoImage.image = UIImage(named: "tutorial_\(i+1)")
            infoImage.contentMode = .scaleAspectFit
            scrollView.addSubview(infoImage)
        }
        scrollView.contentSize = CGSize(width: (_w*CGFloat(4)), height: 0)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        print("currentPage====>\(currentPage)")
        pageControl.currentPage = currentPage
        nextButton.alpha = 1.0
        prevButton.alpha = 1.0
        if (currentPage==3) {
            nextButton.alpha = 0.5
            finishButton.alpha = 1
            skipButton.alpha = 0
        }
        if (currentPage==0) {
            prevButton.alpha = 0.5
            finishButton.alpha = 0
        }
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        let _w = UIScreen.main.bounds.size.width
        if (currentPage>=3) {
            return
        }
        currentPage = currentPage+1
        print("nextButtonClicked :: currentPage====>\(currentPage)")
        if (currentPage==3) { nextButton.alpha = 0.65 }
        prevButton.alpha = 1.0
        scrollView.setContentOffset(CGPoint(x: (_w*CGFloat(currentPage)), y: 0), animated: true)
        pageControl.currentPage = currentPage
    }
    
    @IBAction func prevButtonClicked(_ sender: Any) {
        let _w = UIScreen.main.bounds.size.width
        if (currentPage<=0) {
            return
        }
        currentPage = currentPage-1
        print("prevButtonClicked :: currentPage====>\(currentPage)")
        if (currentPage==0) { prevButton.alpha = 0.65 }
        nextButton.alpha = 1.0
        scrollView.setContentOffset(CGPoint(x: (_w*CGFloat(currentPage)), y: 0), animated: true)
        pageControl.currentPage = currentPage
    }
    
    @IBAction func skipButtonClicked(_ sender: Any) {
        print("skipButtonClicked...")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let homeVC = storyBoard.instantiateViewController(withIdentifier: "LibraryFeedsViewController") as! LibraryFeedsViewController
        print(self.passedProfileImage)
        homeVC.passedProfileImage = self.passedProfileImage
        let navVC = UINavigationController(rootViewController: homeVC)
        navVC.isNavigationBarHidden = true
        self.navigationController?.present(navVC, animated: true, completion: nil)
    }
    
    @IBAction func finishButtonClicked(_ sender: Any) {
        print("finishButtonClicked...")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let homeVC = storyBoard.instantiateViewController(withIdentifier: "LibraryFeedsViewController") as! LibraryFeedsViewController
        print(self.passedProfileImage)
        homeVC.passedProfileImage = self.passedProfileImage
        let navVC = UINavigationController(rootViewController: homeVC)
        navVC.isNavigationBarHidden = true
        self.navigationController?.present(navVC, animated: true, completion: nil)
        
    }
    
}

