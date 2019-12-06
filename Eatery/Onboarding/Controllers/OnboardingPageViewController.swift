//
//  OnboardingPageViewController.swift
//  Eatery
//
//  Created by Reade Plunkett on 11/12/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import CHIPageControl
import UIKit

class OnboardingPageViewController: UIPageViewController {

    private var pages = [OnboardingViewController]()
    private let pageControl = CHIPageControlJaloro()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .eateryBlue

        pages = [
            OnboardingInfoViewController(title: "Menus", subtitle: "See what’s being served at any campus eatery.", animation: "menus"),
            OnboardingInfoViewController(title: "Collegetown", subtitle: "Find info about your favorite Collegetown spots.", animation: "collegetown"),
            OnboardingInfoViewController(title: "Transactions", subtitle: "Track your swipes, BRBs, meal history, and more.", animation: "transactions"),
            OnboardingLoginViewController(title: "Login", subtitle: "To get the most out of Eatery, log in with your NetID.")
        ]

        pages.forEach({ $0.delegate = self })

        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
        pageControl.tintColor = UIColor(white: 1, alpha: 0.3)
        pageControl.currentPageTintColor = .white
        pageControl.padding = 16
        pageControl.elementWidth = 24
        pageControl.elementHeight = 5
        pageControl.radius = 2.5
        pageControl.numberOfPages = pages.count
        pageControl.set(progress: 0, animated: true)
        view.addSubview(pageControl)

        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(40)
        }
    }

}

extension OnboardingPageViewController: OnboardingViewControllerDelegate {

    func onboardingViewControllerDidTapNext(_ viewController: OnboardingViewController) {
        if let viewControllerIndex = pages.index(of: viewController) {
            if viewControllerIndex < pages.count - 1 {
                setViewControllers([pages[viewControllerIndex + 1]], direction: .forward, animated: true, completion: nil)
                self.pageControl.set(progress: viewControllerIndex + 1, animated: true)
            } else if viewControllerIndex == pages.count - 1 {
                let eateryTabBarController = EateryTabBarController()
                guard let appDelegate = UIApplication.shared.delegate else {
                    return
                }
                appDelegate.window??.rootViewController = eateryTabBarController
            }
        }
    }

}
