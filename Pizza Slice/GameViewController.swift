//
//  GameViewController.swift
//  Pizza Slice
//
//  Created by William Entriken on 17/10/2014.
//  Copyright (c) 2014 William Entriken. All rights reserved.
//

import UIKit
import QuartzCore
import SpriteKit
import iAd

class GameViewController: UIViewController, ADBannerViewDelegate {
    var adBannerView:ADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adBannerView = ADBannerView(adType: ADAdType.Banner)
        adBannerView.delegate = self
        adBannerView.hidden = true
        view.addSubview(adBannerView)

        let skView = SKView(frame: self.view.frame)
        self.view.addSubview(skView)
        let scene = GameScene(size: self.view.frame.size)
        skView.presentScene(scene)
    }
    
    // http://stackoverflow.com/q/16796783/300224
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        adBannerView.center = CGPoint(x: adBannerView.center.x, y: view.bounds.size.height - adBannerView.frame.size.height / 2)
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        adBannerView.hidden = false
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        adBannerView.hidden = true
    }
}
