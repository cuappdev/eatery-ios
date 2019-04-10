//
//  EateriesSharedViewController.swift
//  Eatery
//
//  Created by Ethan Fine on 3/15/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit
import Crashlytics
import NVActivityIndicatorView

// MARK: - Eateries Shared View Controller

class EateriesSharedViewController: UIViewController {

    var lastContentOffset: CGFloat = 0
    var lastScrollWasUserInitiated = false
    var pillAnimating = false
    
    var activeEateriesViewController: EateriesViewController!
    var campusEateriesViewController: EateriesViewController!
    var collegetownEateriesViewController: EateriesViewController!
    
    var pillViewController: PillViewController!
    
    override func viewDidLoad() {
        setupEateriesViewControllers()
        setupNavigation()
        setupPillViewController()
    }
    
    // MARK: Setup
    
    func setupEateriesViewControllers() {
        campusEateriesViewController = CampusEateriesViewController()
        campusEateriesViewController.scrollDelegate = self

        addChildViewController(campusEateriesViewController)
        view.addSubview(campusEateriesViewController.view)
        campusEateriesViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        campusEateriesViewController.didMove(toParentViewController: self)

        collegetownEateriesViewController = CollegetownEateriesViewController()
        collegetownEateriesViewController.scrollDelegate = self

        addChildViewController(collegetownEateriesViewController)
        view.addSubview(collegetownEateriesViewController.view)
        collegetownEateriesViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        collegetownEateriesViewController.didMove(toParentViewController: self)

        activeEateriesViewController = collegetownEateriesViewController

        setVisibleViewController(campusEateriesViewController)
    }
    
    func setupNavigation() {
        navigationItem.title = "Eateries"
        navigationController?.view.backgroundColor = .white
        navigationController?.hero.isEnabled = true
        navigationController?.hero.navigationAnimationType = .fade
        
        let mapButton = UIBarButtonItem(image: #imageLiteral(resourceName: "mapIcon"), style: .done, target: self, action: #selector(openMap))
        mapButton.imageInsets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 4.0, right: 8.0)
        navigationItem.rightBarButtonItems = [mapButton]
    }
    
    func setupPillViewController() {
        pillViewController = PillViewController()
        pillViewController.delegate = self
        
        addChildViewController(pillViewController)
        view.addSubview(pillViewController.view)
        pillViewController.view.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(55)
            make.bottom.equalTo(view.layoutMarginsGuide.snp.bottom).inset(8)
            make.height.equalTo(40)
        }
    }
    
    // MARK: User interaction utilities
    
    func setVisibleViewController(_ viewController: EateriesViewController) {
        if viewController === campusEateriesViewController {
            campusEateriesViewController.view.alpha = 1
            collegetownEateriesViewController.view.alpha = 0
        } else if viewController === collegetownEateriesViewController {
            campusEateriesViewController.view.alpha = 0
            collegetownEateriesViewController.view.alpha = 1
        }

        activeEateriesViewController = viewController
    }
    
    func showLocationSelectorView() {
        guard let tabBarMinY = tabBarController?.tabBar.frame.minY else { return }
        if pillViewController.view.frame.minY >= tabBarMinY && !pillAnimating {
            pillAnimating.toggle()
            
            self.pillViewController.view.snp.updateConstraints() { (make) in
                make.bottom.equalTo(self.view.layoutMarginsGuide.snp.bottom).inset(8)
            }
            view.setNeedsUpdateConstraints()
            
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            }) { (completed) in
                self.pillAnimating = false
            }
        }
    }
    
    @objc func openMap() {
        Answers.logMapOpened()

        activeEateriesViewController.pushMapViewController()
    }
    
    func hideLocationSelectorView() {
        guard let tabBarMinY = tabBarController?.tabBar.frame.minY else { return }
        if pillViewController.view.frame.minY < tabBarMinY && !pillAnimating {
            pillAnimating.toggle()
            
            pillViewController.view.snp.updateConstraints() { (make) in
                make.bottom.equalTo(view.layoutMarginsGuide.snp.bottom).offset(40)
            }
            view.setNeedsUpdateConstraints()
            
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            }) { (completed) in
                self.pillAnimating = false
            }
        }
    }

}

// MARK: - Pill View Controller Delegate

extension EateriesSharedViewController: PillViewControllerDelegate {
    
    func pillViewController(_ pvc: PillViewController, didUpdateLocation newLocation: Location) {
        switch newLocation {
        case .campus:
            setVisibleViewController(campusEateriesViewController)
        case .collegetown:
            setVisibleViewController(collegetownEateriesViewController)
        }
    }
    
}

// MARK: - Eateries View Controller Scroll Delegate

extension EateriesSharedViewController: EateriesViewControllerScrollDelegate {

    func eateriesViewController(_ evc: EateriesViewController, scrollViewWillBeginDragging scrollView: UIScrollView) {
        lastContentOffset = scrollView.contentOffset.y
        lastScrollWasUserInitiated = true
    }

    func eateriesViewController(_ evc: EateriesViewController, scrollViewDidScroll scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if lastScrollWasUserInitiated && lastContentOffset > offset {
            showLocationSelectorView()
        } else if lastScrollWasUserInitiated && lastContentOffset < offset {
            hideLocationSelectorView()
        }

        lastContentOffset = offset
        lastScrollWasUserInitiated = false
    }

}
