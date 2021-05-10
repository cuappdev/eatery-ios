//
//  EateryNavigationController.swift
//  ScrollImageView
//
//  Created by William Ma on 9/21/19.
//  Copyright © 2019 William Ma. All rights reserved.
//

import UIKit

class EateryNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // allow swipe back gesture even if navigation bar is hidden
        interactivePopGestureRecognizer?.delegate = nil

        navigationBar.prefersLargeTitles = true
        navigationBar.barTintColor = .eateryBlue
        navigationBar.tintColor = .white
        if #available(iOS 13.0, *) {
            navigationBar.standardAppearance = .eateryDefault
            navigationBar.scrollEdgeAppearance = .eateryDefault
        } else {
            navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navigationBar.isTranslucent = false
        }
    }

}
