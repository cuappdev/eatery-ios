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

    let eateriesSharedViewController = EateriesSharedViewController()
    let lookAheadViewController = LookAheadViewController()
    let brbViewController = BRBViewController()

    lazy var watchAppRedesignBulletinManager: BLTNItemManager = {
        let page = BLTNPageItem(title: "Eatery Watch App Redesign")
        let manager = BLTNItemManager(rootItem: page)

        page.image = UIImage(named: "watchAppPreview")

        page.descriptionText = "Eatery for watchOS has been completely redone. Browse menus and hours right from your wrist."

        page.actionButtonTitle = "Open Watch App"
        page.actionHandler = { _ in
            if let url = URL(string: "itms-watch://"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }

        page.alternativeButtonTitle = "Not now"
        page.alternativeHandler = { _ in
            manager.dismissBulletin()
        }

        return manager
    }()

    override func viewDidLoad() {
        delegate = self
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !Defaults[\.hasShownWatchRedesign], WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
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
        case 0: AppDevAnalytics.shared.logFirebase(EateryPressPayload())
        case 1: AppDevAnalytics.shared.logFirebase(LookAheadPressPayload())
        case 2: AppDevAnalytics.shared.logFirebase(BRBPressPayload())
        default:
            break
        }

    }

}

extension EateryTabBarController: WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated, session.isPaired {
            DispatchQueue.main.async {
                self.watchAppRedesignBulletinManager.showBulletin(above: self)
            }

            Defaults[\.hasShownWatchRedesign] = true
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
    }

    func sessionDidDeactivate(_ session: WCSession) {
    }

}
