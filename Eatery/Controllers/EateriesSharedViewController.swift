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

protocol EateriesViewControllerProtocol { // TODO ETHAN RENAME AFTER CHANGING EATERIESVC {
    
    var eateries: [Eatery] { get }
    
    func processEateries()
    func eateriesToPresent(searchText: String, filters: Set<Filter>) -> [Eatery]
    
}

class EateriesSharedViewController: UIViewController, UISearchBarDelegate, PillDelegate {
    
    var appDevLogo: UIView?
    var searchBar: UISearchBar!
    var filterBar: FilterBar!
    var collectionView: UICollectionView!
    var activityIndicator: NVActivityIndicatorView!
    
    var filters: Set<Filter> = []
    
    var lastContentOffset: CGFloat = 0
    var lastScrollWasUserInitiated = false
    var pillAnimating = false
    
    var visibleViewController: EateriesViewControllerProtocol!
    var campusViewController: EateriesViewControllerProtocol!
    var collegeTownViewController: EateriesViewControllerProtocol!
    
    var pillViewController: PillViewController!
    
    override func viewDidLoad() {
        setupLoadingView()
        setupEateriesViewControllers()
        setupNavigation()
        setupBars()
        setupPillViewController()
    }
    
    // MARK: Setup
    
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
    
    func setupEateriesViewControllers() {
        let eateriesVC = EateriesViewController()
        eateriesVC.eateriesSharedViewController = self
        visibleViewController = eateriesVC;
        campusViewController = eateriesVC;
        collegeTownViewController = eateriesVC;
        let ctVC = collegeTownViewController as! UIViewController
        
        addChildViewController(eateriesVC)
        addChildViewController(ctVC)
        view.addSubview(ctVC.view)
        view.addSubview(eateriesVC.view)
        
        eateriesVC.view.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        ctVC.view.snp.makeConstraints { (make) in
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
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            
            let logo = UIImageView(image: UIImage(named: "appDevLogo"))
            logo.tintColor = .white
            logo.contentMode = .scaleAspectFit
            navigationController?.navigationBar.addSubview(logo)
            logo.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.size.equalTo(28.0)
            }
            
            self.appDevLogo = logo
        }
    }
    
    func setupBars() {
        searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .white
        searchBar.delegate = self
        searchBar.placeholder = "Search eateries and menus"
        searchBar.autocapitalizationType = .none
        searchBar.enablesReturnKeyAutomatically = false
        
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(collectionViewMargin / 2)
            make.leading.trailing.equalToSuperview().inset(collectionViewMargin / 2)
        }
        
        filterBar = FilterBar()
        filterBar.delegate = self
        
        view.addSubview(filterBar)
        filterBar.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(filterBarHeight)
        }
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
    
    func setVisibleViewController(_ viewController: EateriesViewControllerProtocol) {
        if let newVisibleVC = viewController as? UIViewController {
            view.sendSubview(toBack: newVisibleVC.view)
        }
        if let oldVisibleVC = visibleViewController as? UIViewController {
            view.sendSubview(toBack: oldVisibleVC.view)
        }
        
        visibleViewController = viewController;
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
        
        let eateries = visibleViewController.eateries
        let mapViewController = MapViewController(eateries: eateries)
        mapViewController.mapEateries(eateries)
        navigationController?.pushViewController(mapViewController, animated: true)
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
    
    func didUpdateLocation(newLocation: Location) {
        switch newLocation {
        case .campus:
            filterBar.setDisplayedFilters(filters: Filter.getCampusFilters())
            setVisibleViewController(campusViewController)
        case .collegetown:
            filterBar.setDisplayedFilters(filters: Filter.getCollegetownFilters())
            setVisibleViewController(collegeTownViewController)
        }
    }
    
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
        
        appDevLogo?.alpha = min(0.9, (-15.0 - offset) / 100.0)
        
        func handleLargeBarLogo() {
            let margin: CGFloat = 4.0
            let width: CGFloat = appDevLogo?.frame.width ?? 0.0
            let navBarWidth: CGFloat = (navigationController?.navigationBar.frame.width ?? 0.0) / 2
            let navBarHeight: CGFloat = (navigationController?.navigationBar.frame.height ?? 0.0) / 2
            
            appDevLogo?.transform = CGAffineTransform(translationX: navBarWidth - margin - width, y: navBarHeight - margin - width)
            appDevLogo?.tintColor = .white
        }
        
        let largeTitle: Bool
        if #available(iOS 11.0, *) { largeTitle = true } else { largeTitle = false }
        
        if largeTitle && traitCollection.verticalSizeClass != .compact {
            handleLargeBarLogo()
        } else {
            appDevLogo?.transform = CGAffineTransform(translationX: 0.0, y: -offset - 20.0)
            appDevLogo?.tintColor = .eateryBlue
        }
        
        view.endEditing(true)
    }
    
    
}

extension EateriesSharedViewController: FilterBarDelegate {
    
    func updateFilters(filters: Set<Filter>) {
        self.filters = filters
        visibleViewController.processEateries()
        collectionView.reloadData()
    }
    
}
