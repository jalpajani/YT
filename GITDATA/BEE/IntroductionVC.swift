//
//  IntroductionVC.swift
//  SwiftStructure
//
//  Created by  on 07/04/17.
//  Copyright © 2017 9spl. All rights reserved.
//

import UIKit
import Crashlytics

class IntroductionVC: UIViewController,UIScrollViewDelegate, UIPageViewControllerDelegate {
    
    //MARK:- Variable Declaration
    @IBOutlet weak var scrIntro: UIScrollView!
    @IBOutlet weak var ctrlPagingControll: UIPageControl!
    @IBOutlet weak var btnSkip: UIButton!
    @IBOutlet weak var lcwBtnPrevious: NSLayoutConstraint!
    @IBOutlet weak var lcwBtnNext: NSLayoutConstraint!
    @IBOutlet weak var lclBtnNext: NSLayoutConstraint!
    
    var bolIsPageControlUsed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        self.setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        let dicIntroResponse = getFromUserDefaultForKey(key_IsIntroSkipped)
        if dicIntroResponse == nil {
            //Keep Screen
        } else {
            let loginVC = storyBoard_Login.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.navigationController?.pushViewController(loginVC, animated: false)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - SetUp UI
    func setupUI()
    {
        self.setScrollData()
        self.lcwBtnPrevious.constant = 0
        self.lclBtnNext.constant = 0
    }
    
    func setScrollData()
    {
        for index in 0..<arrIntroPage.count {
            let imgIntro = UIImageView(image: UIImage(named: arrIntroPage[index] as! String))
            imgIntro.frame.origin.x = self.scrIntro.frame.size.width * CGFloat(index)
            imgIntro.frame.size = self.scrIntro.frame.size
            imgIntro.contentMode = UIViewContentMode.scaleToFill
            self.scrIntro.addSubview(imgIntro)
        }
        self.scrIntro.contentSize = CGSize(width: (self.scrIntro.frame.size.width * CGFloat(arrIntroPage.count)), height: self.scrIntro.frame.size.height)
        self.ctrlPagingControll.currentPage = 0
    }
    
    //MARK: - Set Paging Buttons
    func setPagingButtons()
    {
        if self.ctrlPagingControll.currentPage > 0 {
            self.lcwBtnPrevious.constant = 75
            self.lclBtnNext.constant = 10
        } else {
            self.lcwBtnPrevious.constant = 0
            self.lclBtnNext.constant = 0
        }
        if self.ctrlPagingControll.currentPage == arrIntroPage.count-1 {
            self.lcwBtnNext.constant = 0
            self.btnSkip.setTitle("Get Started", for: .normal)
        } else {
            self.lcwBtnNext.constant = 55
            self.btnSkip.setTitle("Skip", for: .normal)
        }
        self.bolIsPageControlUsed = false
    }
    //MARK: - Page Change
    @IBAction func changePage(_ sender: UIPageControl) {
        let intCurrPage = self.ctrlPagingControll.currentPage
        var frame = self.scrIntro.frame
        frame.origin.x = frame.size.width * CGFloat(intCurrPage)
        self.scrIntro.scrollRectToVisible(frame, animated: true)
        self.bolIsPageControlUsed = true
    }
    
    //MARK: - Scrollview Delegate
    func scrollViewDidScroll(_ sender: UIScrollView) {
        if self.bolIsPageControlUsed {
            return
        }
        let pageWidth: CGFloat = self.scrIntro.frame.size.width
        let intCurrPage = floor((self.scrIntro.contentOffset.x - pageWidth / 2) / pageWidth) + 1
        self.ctrlPagingControll.currentPage = Int(intCurrPage)
        self.setPagingButtons()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        self.bolIsPageControlUsed = false
    }
    
    //MARK: - @IBActions
    @IBAction func btnClickedSkip(_ sender: UIButton) {
        self.bolIsPageControlUsed = true
        switch sender.tag
        {
        case 0: //Previeous Button
            let intCurrPage = self.ctrlPagingControll.currentPage - 1
            var frame = self.scrIntro.frame
            frame.origin.x = frame.size.width * CGFloat(intCurrPage)
            self.scrIntro.scrollRectToVisible(frame, animated: true)
            self.ctrlPagingControll.currentPage = Int(intCurrPage)
            self.setPagingButtons()
            break
        case 1: //Next Button
            let intCurrPage = self.ctrlPagingControll.currentPage + 1
            var frame = self.scrIntro.frame
            frame.origin.x = frame.size.width * CGFloat(intCurrPage)
            self.scrIntro.scrollRectToVisible(frame, animated: true)
            self.ctrlPagingControll.currentPage = Int(intCurrPage)
            self.setPagingButtons()
            break
        case 2: //Skip Button
            //Crashlytics.sharedInstance().crash()
            setToUserDefaultForKey("yes" as AnyObject?, key: key_IsIntroSkipped)
            let loginVC = storyBoard_Login.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            navigationController?.pushViewController(loginVC, animated: true)
            break
        default: break
            
        }
        
    }
}
