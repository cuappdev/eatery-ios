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

protocol EateriesViewControllerDelegateShared { // TODO ETHAN RENAME AFTER CHANGING EATERIESVC {
    
    var eateries: [Eatery] { get }
    
    func processEateries()
    func eateriesToPresent(searchText: String, filters: Set<Filter>) -> [Eatery]
    
}

class EateriesSharedViewController: UIViewController, UISearchBarDelegate {
    
    var searchBar: UISearchBar! // MOVE BACK TO CHILD
    var filterBar: FilterBar!
    var collectionView: UICollectionView!
    var activityIndicator: NVActivityIndicatorView!
    
    var filters: Set<Filter> = []
    
    var lastContentOffset: CGFloat = 0
    var lastScrollWasUserInitiated = false
    var pillAnimating = false
    
    var activeEateriesViewController: EateriesViewController!
    var campusEateriesViewController: EateriesViewController!
    /*var visibleViewController: EateriesViewControllerDelegate!
    var campusViewController: EateriesViewControllerDelegate!
    var collegeTownViewController: EateriesViewControllerDelegate!*/ //MERGE REDONE
    
    var pillViewController: PillViewController!
    
    override func viewDidLoad() {
        setupEateriesViewControllers()
        setupNavigation()
        setupBars()
        setupPillViewController()
        /*setupLoadingView()
        endLoadingIndicator() // TODO ethan: end when appropriate*/
    }
    
    // MARK: Setup
    
    func setupEateriesViewControllers() {
        activeEateriesViewController = CampusEateriesViewController()
        campusEateriesViewController = activeEateriesViewController
        //eateriesViewController.delegate = CampusEateriesViewController()
        
        addChildViewController(activeEateriesViewController)
        view.addSubview(activeEateriesViewController.view)
        
        activeEateriesViewController.view.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        //eateriesViewController.updateState(.presenting, animated: true)
        /*visibleViewController = eateriesVC;
        campusViewController = eateriesVC;
        collegeTownViewController = TemporaryCollegetownDemoViewController();
        let ctVC = collegeTownViewController as! UIViewController*/
        /*addChildViewController(eateriesVC.delegate)
        addChildViewController(eateriesVC)
        addChildViewController(ctVC)
        view.addSubview(ctVC.view)
        view.addSubview(eateriesVC.view)
        
        eateriesVC.view.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        ctVC.view.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }*/ //MERGE REDONE
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
    
    func setupBars() {
        /*searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .white
        searchBar.delegate = self
        searchBar.placeholder = "Search eateries and menus"
        searchBar.autocapitalizationType = .none
        searchBar.enablesReturnKeyAutomatically = false
        
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(EateriesViewController.collectionViewMargin / 2)
            make.leading.trailing.equalToSuperview().inset(EateriesViewController.collectionViewMargin / 2)
        }
        
        filterBar = FilterBar()
        filterBar.delegate = self
        
        view.addSubview(filterBar)
        filterBar.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(filterBarHeight)
        }*/ // MERGE REMOVED
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
    
    func setupLoadingView() {
        let size: CGFloat = 44.0
        let indicator = NVActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: size, height: size), type: .circleStrokeSpin, color: .transparentEateryBlue)
        view.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        indicator.startAnimating()
        activityIndicator = indicator
    }
    
    // MARK: User interaction utilities
    
    func setVisibleViewController(_ viewController: EateriesViewControllerDelegate) {
        if let newVisibleVC = viewController as? UIViewController {
            view.sendSubview(toBack: newVisibleVC.view)
        }
        /*if let oldVisibleVC = visibleViewController as? UIViewController {
            view.sendSubview(toBack: oldVisibleVC.view)
        }
        
         visibleViewController = viewController;*/ // TODO: ETHAN MERGE CONFLICT
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
        navigationController?.pushViewController(mapViewController, animated: true)*/ // MERGE REMOVED
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
    
    // MARK: View Procedures
    func endLoadingIndicator() { // TODO ethan: end at appropriate time
        UIView.animate(withDuration: 0.35, animations: {
            self.activityIndicator.alpha = 0.0
        }) { (completed) in
            self.activityIndicator.stopAnimating()
        }
    }
    
    // MARK: Listeners
    
    // TODO ethan: make into methods and call from eateriesVCs since these are no longer called
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastContentOffset = scrollView.contentOffset.y
        lastScrollWasUserInitiated = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset = scrollView.contentOffset.y
        
        if lastScrollWasUserInitiated && lastContentOffset > offset {
            showLocationSelectorView()
        } else if lastScrollWasUserInitiated && lastContentOffset < offset {
            hideLocationSelectorView()
        }
        
        lastContentOffset = offset
        lastScrollWasUserInitiated = false
        
        if #available(iOS 11.0, *) {
            offset += scrollView.adjustedContentInset.top
        } else {
            offset += scrollView.contentInset.top
        }
        
        let maxHeaderOffset = searchBar.frame.height + filterBar.frame.height
        let headerOffset = min(maxHeaderOffset, offset)
        
        let transform = CGAffineTransform(translationX: 0.0, y: -headerOffset)
        searchBar.transform = transform
        filterBar.transform = transform
        
        view.endEditing(true)
    }
    
    
}

/*extension EateriesSharedViewController: FilterBarDelegate {
    
    func updateFilters(filters: Set<Filter>) {
        self.filters = filters
        visibleViewController.processEateries()
        (visibleViewController as! EateriesViewController).collectionView.reloadData()
    }
    
}*/ // TODO REMOVE ETHAN

extension EateriesSharedViewController: PillDelegate {
    
    func didUpdateLocation(newLocation: Location) {
        switch newLocation {
        case .campus:
            filterBar.setDisplayedFilters(filters: Filter.getCampusFilters())
        //setVisibleViewController(campusViewController) TODO: ETHAN merge
        case .collegetown:
            filterBar.setDisplayedFilters(filters: Filter.getCollegetownFilters())
            //setVisibleViewController(collegeTownViewController) TODO: ETHAN merge
        }
    }
    
}
