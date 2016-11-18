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
    var cellImageFrame: CGRect?
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
            
            let originalHeaderFrame = menuViewController.menuHeaderView.frame
            
            menuViewController.menuHeaderView.backgroundImageView.frame = self.cellImageFrame ?? menuViewController.menuHeaderView.backgroundImageView.frame
            menuViewController.menuHeaderView.frame.origin = cellFrame?.origin ?? CGPoint.zero
            menuViewController.menuHeaderView.frame.size.width = cellFrame?.size.width ?? 0.0
            menuViewController.menuHeaderView.layoutIfNeeded()
            menuViewController.outerScrollView.subviews.forEach { $0.alpha = 0.0 }
            menuViewController.outerScrollView.backgroundColor = UIColor.clear
            menuViewController.menuHeaderView.alpha = 0.0
            menuViewController.pageViewController.view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: [.curveEaseInOut], animations: {
                eateriesGridViewController.view.alpha = 0.0
                eateriesGridViewController.view.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
                menuViewController.pageViewController.view.transform = CGAffineTransform.identity
                menuViewController.outerScrollView.subviews.forEach { $0.alpha = 1.0 }
                menuViewController.outerScrollView.backgroundColor = UIColor.groupTableViewBackground
                menuViewController.menuHeaderView.subviews.forEach { $0.alpha = 1.0 }
                menuViewController.menuHeaderView.frame = originalHeaderFrame
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
            UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, options: [.curveEaseInOut], animations: {
                eateriesGridViewController.view.alpha = 1.0
                eateriesGridViewController.view.transform = CGAffineTransform.identity
                menuViewController.view.alpha = 0.0
                menuViewController.pageViewController.view.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                menuViewController.menuHeaderView.frame.origin = CGPoint(x: self.cellFrame?.origin.x ?? 0.0, y: (self.cellFrame?.origin.y ?? 0.0) + 64.0)
                menuViewController.menuHeaderView.frame.size.width = self.cellFrame?.size.width ?? 0.0
                menuViewController.menuHeaderView.layoutIfNeeded()
                menuViewController.menuHeaderView.alpha = 0.0
            }, completion: { finished in
                menuViewController.menuHeaderView.removeFromSuperview()
                transitionContext.completeTransition(finished)
            })

        }
    }
}
