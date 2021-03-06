//
//  LoopView.swift
//  圖片輪播
//
//  Created by 游宗翰 on 2016/10/15.
//  Copyright © 2016年 YU. All rights reserved.
//

import UIKit

class LoopView: UIView {
    
    fileprivate var pageControl : UIPageControl?
    fileprivate var imageScrollView : UIScrollView?
    fileprivate var currentPage: NSInteger?
    
    fileprivate var currentImgs = NSMutableArray()
    fileprivate var currentImages :NSMutableArray? {
        get{
            currentImgs.removeAllObjects()
            let count = self.images!.count
            var i = NSInteger(self.currentPage!+count-1)%count
            currentImgs.add(self.images![i])
            currentImgs.add(self.images![self.currentPage!])
            i = NSInteger(self.currentPage!+1)%count
            currentImgs.add(self.images![i])
            return currentImgs
        }
    }
    
    var images: NSArray?
    fileprivate var autoPlay : Bool?
    fileprivate var isFromNet : Bool?
    fileprivate var delay : TimeInterval?
    
    var delegate:LoopViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame:CGRect ,images:NSArray, autoPlay:Bool, delay:TimeInterval, isFromNet:Bool){
        self.init(frame: frame)
        self.images = images;
        self.autoPlay = autoPlay
        self.isFromNet = isFromNet
        self.delay = delay
        self.currentPage = 0
        
        createImageScrollView()
        createPageView()
        
        if images.count<2{
            self.autoPlay = false
            pageControl?.isHidden = true
        }
        
        if self.autoPlay == true {
            startAutoPlay()
        }
    }
    
//    deinit {
//        print("deinit")
//    }
    
    // 創建ScrollView
    fileprivate func createImageScrollView(){
        if images?.count == 0 {
            return
        }
        imageScrollView = UIScrollView(frame: self.bounds)
        imageScrollView?.showsHorizontalScrollIndicator = false
        imageScrollView?.showsVerticalScrollIndicator=false
        imageScrollView?.bounces = false
        imageScrollView?.delegate = self
        imageScrollView?.contentSize = CGSize(width: self.bounds.width*3, height: 0)
        imageScrollView?.contentOffset = CGPoint(x: self.frame.width, y: 0)
        imageScrollView?.isPagingEnabled = true
        self.addSubview(imageScrollView!)
        
        for index in 0..<3 {
            let imageView = UIImageView(frame: CGRect(x: self.bounds.width*CGFloat(index), y: 0, width: self.bounds.width, height: self.bounds.height))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoopView.imageViewClick)))
            imageView.clipsToBounds = true;
            imageView.contentMode = .scaleAspectFill
            
            if self.isFromNet == true {
                
            }
            else{
                
                imageView.image = (self.currentImages![index] as! UIImage);
            }
            imageScrollView?.addSubview(imageView)
            //print(imageScrollView?.subviews.count)
        }
        
    }
    
    // 創建pageControl
    fileprivate func createPageView(){
        if images?.count == 0 {
            return
        }
        let pageW: CGFloat = 80
        let pageH: CGFloat = 25
        let pageX: CGFloat = self.bounds.width - pageW
        let pageY: CGFloat = self.bounds.height - pageH
        pageControl = UIPageControl(frame: CGRect(x: pageX, y: pageY, width: pageW, height: pageH))
        pageControl?.numberOfPages = images!.count
        pageControl?.currentPage = 0
        pageControl?.isUserInteractionEnabled = false
        self.addSubview(pageControl!)
        
    }
    
    fileprivate func startAutoPlay() {
        self.perform(#selector(LoopView.nextPage), with: nil, afterDelay: delay!)
    }
    
    func nextPage() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(LoopView.nextPage), object: nil)
        imageScrollView!.setContentOffset(CGPoint(x: 2 * self.frame.width, y: 0), animated: true)
        self.perform(#selector(LoopView.nextPage), with: nil, afterDelay: delay!)
    }
    
    // 圖片滾動更新圖片
    fileprivate func refreshImages(){
        for i in 0..<imageScrollView!.subviews.count {
            let imageView = imageScrollView!.subviews[i] as! UIImageView
            imageView.clipsToBounds = true;
            imageView.contentMode = .scaleAspectFill
            if self.isFromNet == true {
                
            }
            else{
                imageView.image = (self.currentImages![i] as! UIImage);
            }
        }
        
        imageScrollView!.contentOffset = CGPoint(x: self.frame.width, y: 0)
    }
    
    // 圖片點擊
    func imageViewClick(){
        if self.delegate != nil && (self.delegate?.responds(to: #selector(LoopViewDelegate.adLoopView(_:IconClick:)))) != nil {
            self.delegate!.adLoopView(self, IconClick: currentPage!)
        }
    }
    
}

extension LoopView : UIScrollViewDelegate{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(CGPoint(x: self.frame.width, y: 0), animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let x = scrollView.contentOffset.x
        let width = self.frame.width
        if x >= 2*width {
            currentPage = (currentPage!+1) % self.images!.count
            pageControl!.currentPage = currentPage!
            refreshImages()
        }
        if x <= 0 {
            currentPage = (currentPage!+self.images!.count-1) % self.images!.count
            pageControl!.currentPage = currentPage!
            refreshImages()
        }
    }
}

// LoopViewDelegate
@objc protocol LoopViewDelegate:NSObjectProtocol {
    func adLoopView(_ adLoopView:LoopView ,IconClick index:NSInteger)
}
