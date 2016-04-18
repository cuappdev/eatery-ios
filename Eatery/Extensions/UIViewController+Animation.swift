//
//  UIViewController+Animation.swift
//  Eatery
//
//  Created by Annie Cheng on 4/18/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func presentVCWithFadeInAnimation(vc: UIViewController, duration: Double) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionFade
        transition.subtype = kCATransitionFade
        view.window!.layer.addAnimation(transition, forKey: nil)
        presentViewController(vc, animated: false, completion: nil)
    }
    
    func dismissVCWithFadeOutAnimation(duration: Double) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        transition.type = kCATransitionFade
        transition.subtype = kCATransitionFade
        view.window!.layer.addAnimation(transition, forKey: nil)
        dismissViewControllerAnimated(false, completion: nil)
    }
}