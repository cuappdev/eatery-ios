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
    let accountManager = BRBAccountManager()

    override func viewDidLoad() {
        delegate = self
        accountManager.delegate = self
        accountManager.queryBRBDataWithSavedLogin()
        
        let eateriesNavigationController = EateryNavigationController(rootViewController: eateriesSharedViewController)
        eateriesNavigationController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "eateryTabIcon.png"), tag: 0)

        let lookAheadNavigationController = EateryNavigationController(rootViewController: lookAheadViewController)
        lookAheadNavigationController.tabBarItem = UITabBarItem(title: nil, image: #imageLiteral(resourceName: "menu icon"), tag: 1)

        let brbNavigationController = EateryNavigationController(rootViewController: brbViewController)
        brbNavigationController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "accountIcon.png"), tag: 2)

        let navigationControllers = [eateriesNavigationController, lookAheadNavigationController, brbNavigationController]
        navigationControllers.forEach { $0.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0) }

        setViewControllers(navigationControllers, animated: false)

        tabBar.barTintColor = .white
        tabBar.tintColor = .eateryBlue
        tabBar.shadowImage = UIImage()
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

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 0:
            AppDevAnalytics.shared.logFirebase(EateryPressPayload())
        case 1:
            AppDevAnalytics.shared.logFirebase(LookAheadPressPayload())
        case 2:
            AppDevAnalytics.shared.logFirebase(BRBPressPayload())
        default:
            break
        }

    }

}

extension EateryTabBarController: BRBAccountManagerDelegate {
    
    func BRBAccountManagerDidQueryAccount(account: BRBAccount) {
        brbViewController.accountViewController?.account = account
        brbViewController.accountViewController?.tableView.reloadData()
        brbViewController.isLoading = false
    }
    
    func BRBAccountManagerDidFailToQueryAccount(with error: String) {
        brbViewController.showErrorAlert(error: error)
    }
    
}
