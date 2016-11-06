//
//  EateryNavigationAnimator.swift
//  Eatery
//
//  Created by Daniel Li on 11/4/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class EateryNavigationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var cellFrame: CGRect?
    var eateryDistanceText: String?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        if let eateriesGridViewController = transitionContext.viewController(forKey: .from) as? EateriesGridViewController,
            let menuViewController = transitionContext.viewController(forKey: .to) as? MenuViewController {
            menuViewController.view.frame = transitionContext.finalFrame(for: menuViewController)
            containerView.addSubview(menuViewController.view)
            let menuHeaderViewDefaultFrame = menuViewController.menuHeaderView.frame
            
            menuViewController.menuHeaderView.distanceLabel.text = eateryDistanceText
            menuViewController.menuHeaderView.frame = self.cellFrame ?? menuViewController.menuHeaderView.frame
            menuViewController.menuHeaderView.layoutIfNeeded()
            menuViewController.outerScrollView.subviews.forEach { $0.alpha = 0.0 }
            menuViewController.menuHeaderView.alpha = 1.0
            menuViewController.pageViewController.view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                eateriesGridViewController.view.alpha = 0.0
                eateriesGridViewController.view.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
                menuViewController.pageViewController.view.transform = CGAffineTransform.identity
                menuViewController.outerScrollView.subviews.forEach { $0.alpha = 1.0 }
                menuViewController.menuHeaderView.frame = menuHeaderViewDefaultFrame
                menuViewController.menuHeaderView.layoutIfNeeded()
            }, completion: { finished in
                transitionContext.completeTransition(finished)
            })
            
            
        }
        
        if let menuViewController = transitionContext.viewController(forKey: .from) as? MenuViewController,
            let eateriesGridViewController = transitionContext.viewController(forKey: .to) as? EateriesGridViewController {
            containerView.addSubview(eateriesGridViewController.view)
            containerView.addSubview(menuViewController.menuHeaderView)
            menuViewController.menuHeaderView.frame = menuViewController.outerScrollView.convert(menuViewController.menuHeaderView.frame, to: containerView)
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                eateriesGridViewController.view.alpha = 1.0
                eateriesGridViewController.view.transform = CGAffineTransform.identity
                menuViewController.view.alpha = 0.0
                menuViewController.pageViewController.view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                menuViewController.menuHeaderView.frame = self.cellFrame?.offsetBy(dx: 0.0, dy: 64.0) ?? menuViewController.menuHeaderView.frame
                menuViewController.menuHeaderView.layoutIfNeeded()
            }, completion: { finished in
                menuViewController.menuHeaderView.removeFromSuperview()
                transitionContext.completeTransition(finished)
            })

        }
    }
}
