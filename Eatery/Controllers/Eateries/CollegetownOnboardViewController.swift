//
//  CollegetownOnboardViewController.swift
//  Eatery
//
//  Created by Ethan Fine on 4/11/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class CollegetownOnboardViewController: UIViewController {
    
    var appDevLogo: UIImageView!
    var getStartedButton: UIButton!
    //var dismissButton: UIButton!
    
    var player: AVPlayer!
    let videoAspectRatio = 1.1
    var avpController = AVPlayerViewController()
    
    var eateryTabBarController: UITabBarController!
    
    override func viewDidLoad() {
        view.backgroundColor = .white

        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
        
        setupAppDevLogo()
        //setupDismissButton()
        setupAnimationVideo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        avpController.player?.play()
    }
    
    private func setupAppDevLogo() {
        let image = UIImage(named: "appDevLogoBlue")
        appDevLogo = UIImageView(image: image)
        appDevLogo.contentMode = .scaleAspectFit
        view.addSubview(appDevLogo)
        appDevLogo.snp.makeConstraints { make in
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.top.equalToSuperview().offset(72)
            make.leading.equalToSuperview().offset(32)
        }
    }
    
    /*private func setupDismissButton() {
        let image = UIImage(named: "closeIcon")?.withRenderingMode(.alwaysTemplate)
        dismissButton = UIButton(type: .custom)
        dismissButton.setImage(image, for: .normal)
        dismissButton.tintColor = .eateryBlue
        dismissButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        view.addSubview(dismissButton)
        dismissButton.snp.makeConstraints { make in
            make.width.equalTo(33)
            make.height.equalTo(33)
            make.top.equalTo(view.snp.topMargin).offset(72)
            make.trailing.equalToSuperview().inset(20)
        }
    }*/
    
    private func setupAnimationVideo() {
        let moviePath = Bundle.main.path(forResource: "collegetownonboard", ofType: "mp4")
        if let path = moviePath {
            let url = NSURL.fileURL(withPath: path)
            player = AVPlayer(url: url)
            
            avpController = AVPlayerViewController()
            avpController.player = player
            avpController.showsPlaybackControls = false
            avpController.view.backgroundColor = .white
            avpController.videoGravity = AVLayerVideoGravity.resize.rawValue
            addChildViewController(avpController)
            view.addSubview(avpController.view)
            
            avpController.view.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(20)
                make.trailing.equalToSuperview().inset(20)
                make.height.equalTo(avpController.view!.snp.width).multipliedBy(videoAspectRatio)
                make.bottom.equalTo(view.snp.bottomMargin).inset(100 + eateryTabBarController.tabBar.frame.height)
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(setupGetStartedButton), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        }
    }
    
    @objc func setupGetStartedButton() {
        getStartedButton = UIButton(type: .custom)
        getStartedButton.setTitle("Get Started", for: .normal)
        getStartedButton.backgroundColor = .eateryBlue
        getStartedButton.layer.cornerRadius = 20
        getStartedButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        view.addSubview(getStartedButton)
        getStartedButton.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(264)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.snp.bottom).inset(eateryTabBarController.tabBar.frame.height)
        }
        
        getStartedButton.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        let animation = UIViewPropertyAnimator(duration: 1, dampingRatio: 1.1, animations: {
            self.getStartedButton.transform = .identity
        })
         
        animation.startAnimation()
    }
    
    @objc private func dismissViewController() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            present(appDelegate.eateryTabBarController, animated: true, completion: nil)
        }
    }
    
}
