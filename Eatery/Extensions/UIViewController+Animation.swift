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
    func presentVCWithFadeInAnimation(_ vc: UIViewController, duration: Double) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionFade
        transition.subtype = kCATransitionFade
        view.window!.layer.add(transition, forKey: nil)
        present(vc, animated: false, completion: nil)
    }
    
    func dismissVCWithFadeOutAnimation(_ duration: Double) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        transition.type = kCATransitionFade
        transition.subtype = kCATransitionFade
        view.window!.layer.add(transition, forKey: nil)
        dismiss(animated: false, completion: nil)
    }
}
