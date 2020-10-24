//
//  EateryTabBarController.swift
//  Eatery
//
//  Created by Kevin Chan on 11/9/18.
//  Copyright © 2018 CUAppDev. All rights reserved.
//

import BLTNBoard
import SwiftyUserDefaults
import UIKit
import WatchConnectivity

class EateryTabBarController: UITabBarController {

    // MARK: View controllers

    let eateriesViewController = CampusEateriesViewController()
    let lookAheadViewController = LookAheadViewController()
    let brbViewController = BRBViewController()
    
    let eateriesNavigationController: EateryNavigationController
    
    init() {
        self.eateriesNavigationController = EateryNavigationController(rootViewController: eateriesViewController)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        delegate = self
        
        eateriesNavigationController.delegate = self
        eateriesNavigationController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "eateryTabIcon.png"),
            tag: 0
        )
        
        let lookAheadNavigationController = EateryNavigationController(rootViewController: lookAheadViewController)
        lookAheadNavigationController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "menu icon"), tag: 1)

        let brbNavigationController = EateryNavigationController(rootViewController: brbViewController)
        brbNavigationController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "accountIcon.png"), tag: 2)

        let navigationControllers = [
            eateriesNavigationController,
            lookAheadNavigationController,
            brbNavigationController
        ]
        navigationControllers.forEach {
            $0.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }

        setViewControllers(navigationControllers, animated: false)

        tabBar.barTintColor = .white
        tabBar.tintColor = .eateryBlue
        tabBar.shadowImage = UIImage()
        
    }

    func tabBarControllerSupportedInterfaceOrientations(
        _ tabBarController: UITabBarController
    ) -> UIInterfaceOrientationMask {
        .portrait
    }

    func tabBarControllerPreferredInterfaceOrientationForPresentation(
        _ tabBarController: UITabBarController
    ) -> UIInterfaceOrientation {
        .portrait
    }
}

extension EateryTabBarController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if selectedViewController === viewController,
            viewController === eateriesNavigationController {
            if eateriesNavigationController.viewControllers.count > 1 {
                eateriesNavigationController.popViewController(animated: true)
            } else {
                eateriesViewController.scrollToTop(animated: true)
            }
        }

        return true
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 0: AppDevAnalytics.shared.logFirebase(EateryPressPayload())
        case 1: AppDevAnalytics.shared.logFirebase(LookAheadPressPayload())
        case 2: AppDevAnalytics.shared.logFirebase(BRBPressPayload())
        default:
            break
        }

    }

}

extension EateryTabBarController: UINavigationControllerDelegate {
    
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        viewController.extendedLayoutIncludesOpaqueBars = true

        let isParallax = viewController is ImageParallaxScrollViewController
        navigationController.setNavigationBarHidden(isParallax, animated: true)
    }
    
}
