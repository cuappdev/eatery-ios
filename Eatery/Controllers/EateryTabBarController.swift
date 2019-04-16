//
//  EateryTabBarController.swift
//  Eatery
//
//  Created by Kevin Chan on 11/9/18.
//  Copyright © 2018 CUAppDev. All rights reserved.
//

import UIKit

class EateryTabBarController: UITabBarController {

    // MARK: View controllers

    let eateriesSharedViewController = EateriesSharedViewController()
    let lookAheadViewController = LookAheadViewController()
    let brbViewController = BRBViewController()

    override func viewDidLoad() {
        delegate = self

        let eateriesNavigationController = UINavigationController(rootViewController: eateriesSharedViewController)
        eateriesNavigationController.navigationBar.barStyle = .black
        eateriesNavigationController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "eateryTabIcon.png"), tag: 0)

        let lookAheadNavigationController = UINavigationController(rootViewController: lookAheadViewController)
        lookAheadNavigationController.navigationBar.barStyle = .black
        lookAheadNavigationController.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "menu icon"), tag: 1)

        let brbNavigationController = UINavigationController(rootViewController: brbViewController)
        brbNavigationController.navigationBar.barStyle = .black
        brbNavigationController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "infoIcon.png"), tag: 2)

        let navigationControllers = [eateriesNavigationController, lookAheadNavigationController, brbNavigationController]
        navigationControllers.forEach { $0.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0) }

        setViewControllers(navigationControllers, animated: false)
    }
    
    func tabBarControllerSupportedInterfaceOrientations(_ tabBarController: UITabBarController) -> UIInterfaceOrientationMask {
        return .portrait
    }
    
    func tabBarControllerPreferredInterfaceOrientationForPresentation(_ tabBarController: UITabBarController) -> UIInterfaceOrientation {
        return .portrait
    }

}

extension EateryTabBarController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if selectedViewController === viewController,
            let navigationController = viewController as? UINavigationController,
            let eateriesSharedVC = navigationController.viewControllers.first as? EateriesSharedViewController {
            eateriesSharedVC.activeViewController.scrollToTop()
        }

        return true
    }

}
