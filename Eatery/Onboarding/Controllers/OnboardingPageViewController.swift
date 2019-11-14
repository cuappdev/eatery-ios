//
//  OnboardingPageViewController.swift
//  Eatery
//
//  Created by Reade Plunkett on 11/12/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit
import CHIPageControl

class OnboardingPageViewController: UIPageViewController {

    var pages = [OnboardingViewController]()
    let pageControl = CHIPageControlJaloro()

    let models = [
        OnboardingModel(title: "Menus", subtitle: "See what’s being served at any campus eatery.", image: UIImage(named: "menuIcon")!),
        OnboardingModel(title: "Collegetown", subtitle: "Find info about your favorite Collegetown spots.", image: UIImage(named: "ctownIcon")!),
        OnboardingModel(title: "Transactions", subtitle: "Track your swipes, BRBs, meal history, and more.", image: UIImage(named: "transactionsIcon")!),
        OnboardingModel(title: "Login", subtitle: "To get the most out of Eatery, log in with your NetID.", image: nil)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .eateryBlue

        pages = [
            OnboardingViewController(model: models[0], nibName: nil, bundle: nil),
            OnboardingViewController(model: models[1], nibName: nil, bundle: nil),
            OnboardingViewController(model: models[2], nibName: nil, bundle: nil),
            OnboardingLoginViewController(model: models[3], nibName: nil, bundle: nil)
        ]

        for page in pages { page.delegate = self }

        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)
        self.pageControl.tintColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.30)
        self.pageControl.currentPageTintColor = .white
        self.pageControl.padding = 16
        self.pageControl.elementWidth = 24
        self.pageControl.elementHeight = 5
        self.pageControl.radius = 2.5
        self.pageControl.numberOfPages = self.pages.count
        self.pageControl.set(progress: 0, animated: true)
        self.view.addSubview(self.pageControl)

        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
        }
    }

}

extension OnboardingPageViewController: OnboardingViewControllerDelegate {

    func onboardingViewControllerDidTapNextButton(viewController: OnboardingViewController) {
        if let viewControllerIndex = self.pages.index(of: viewController) {
            if viewControllerIndex < self.pages.count - 1 {
                setViewControllers([pages[viewControllerIndex + 1]], direction: .forward, animated: true, completion: nil)
                self.pageControl.set(progress: viewControllerIndex + 1, animated: true)
            } else if viewControllerIndex == self.pages.count - 1 {
                let eateryTabBarController = EateryTabBarController()
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window!.rootViewController = eateryTabBarController
            }
        }
    }

}
