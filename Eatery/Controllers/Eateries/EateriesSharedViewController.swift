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

class EateriesSharedViewController: UIViewController, UISearchBarDelegate {
    
    var lastContentOffset: CGFloat = 0
    var lastScrollWasUserInitiated = false
    var pillAnimating = false
    
    var activeEateriesViewController: EateriesViewController!
    var campusEateriesViewController: EateriesViewController!
    
    var pillViewController: PillViewController!
    
    override func viewDidLoad() {
        setupEateriesViewControllers()
        setupNavigation()
        setupPillViewController()
    }
    
    // MARK: Setup
    
    func setupEateriesViewControllers() {
        activeEateriesViewController = CampusEateriesViewController()
        campusEateriesViewController = activeEateriesViewController
        
        addChildViewController(activeEateriesViewController)
        view.addSubview(activeEateriesViewController.view)
        
        activeEateriesViewController.view.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
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
        view.sendSubview(toBack: viewController.view)
        view.sendSubview(toBack: activeEateriesViewController.view)

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
        
        //let eateries = visibleViewController.eateries
        /*let mapViewController = MapViewController(eateries: eateriesViewController.eateries)
        mapViewController.mapEateries(eateries)
         navigationController?.pushViewController(mapViewController, animated: true)*/ // TODO: ethan update to work with merge
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
    
    // MARK: Listeners
    
    // TODO ethan: make into procedural methods (rather than delegate implementations) and call from eateriesVCs since these are no longer called
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastContentOffset = scrollView.contentOffset.y
        lastScrollWasUserInitiated = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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

extension EateriesSharedViewController: PillDelegate {
    
    func didUpdateLocation(newLocation: Location) {
        switch newLocation {
        case .campus:
            print("TODO")
            //setVisibleViewController(campusViewController) TODO: ETHAN merge
        case .collegetown:
            print("TODO")
            //setVisibleViewController(collegeTownViewController) TODO: ETHAN merge
        }
    }
    
}
