//
//  EateriesNavigationController.swift
//  ScrollImageView
//
//  Created by William Ma on 9/21/19.
//  Copyright © 2019 William Ma. All rights reserved.
//

import UIKit

class EateriesNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        // allow swipe back gesture even if navigation bar is hidden
        interactivePopGestureRecognizer?.delegate = nil
    }

}

extension EateriesNavigationController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let isParallax = viewController is ImageParallaxScrollViewController
        setNavigationBarHidden(isParallax, animated: true)
    }

}
