//
//  EateriesSharedViewController.swift
//  Eatery
//
//  Created by Ethan Fine on 4/10/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import Crashlytics
import CoreLocation
import UIKit

class EateriesSharedViewController: UIViewController {
    
    // Scroll

    var lastContentOffset: CGFloat = 0
    var lastScrollWasUserInitiated = false

    // View Controllers

    private var campusEateriesViewController: CampusEateriesViewController!
    private var collegetownEateriesViewController: CollegetownEateriesViewController!
    var pillViewController: PillViewController!

    private var activeViewController: EateriesViewController! {
        if pillViewController.pillView.leftSegmentSelected {
            return campusEateriesViewController
        } else {
            return collegetownEateriesViewController
        }
    }

    // Location

    private lazy var locationManager: CLLocationManager = {
        let l = CLLocationManager()
        l.delegate = self
        l.desiredAccuracy = kCLLocationAccuracyBest
        l.startUpdatingLocation()
        return l
    }()

    // MARK: View Controller

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationItem()
        setUpChildViewControllers()
        setUpPillView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setUpLocationManager()
    }

    private func setUpNavigationItem() {
        navigationItem.title = "Eateries"
        navigationController?.hero.isEnabled = true
        navigationController?.hero.navigationAnimationType = .fade

        let mapButton = UIBarButtonItem(image: #imageLiteral(resourceName: "mapIcon"), style: .done, target: self, action: #selector(openMap))
        mapButton.imageInsets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 4.0, right: 8.0)
        navigationItem.rightBarButtonItems = [mapButton]
    }

    private func setUpChildViewControllers() {
        campusEateriesViewController = CampusEateriesViewController()
        campusEateriesViewController.scrollDelegate = self

        collegetownEateriesViewController = CollegetownEateriesViewController()
        collegetownEateriesViewController.scrollDelegate = self

        pillViewController = PillViewController(leftViewController: campusEateriesViewController,
                                                rightViewController: collegetownEateriesViewController)
        addChildViewController(pillViewController)
        view.addSubview(pillViewController.view)
        pillViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pillViewController.didMove(toParentViewController: self)
    }

    private func setUpPillView() {
        let pillView = pillViewController.pillView

        pillView.leftImageView.image = UIImage(named: "campusIcon")
        pillView.leftLabel.text = "Campus"

        pillView.rightImageView.image = UIImage(named: "collegetownIcon")
        pillView.rightLabel.text = "Collegetown"
    }

    private func setUpLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            default: break
            }
        }
    }

    @objc private func openMap() {
        Answers.logMapOpened()

        activeViewController.pushMapViewController()
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
        
        if lastScrollWasUserInitiated, lastContentOffset > offset {
            pillViewController.setShowPill(true, animated: true)
        } else if lastScrollWasUserInitiated, lastContentOffset < offset {
            pillViewController.setShowPill(false, animated: true)
        }
        
        lastContentOffset = offset
        lastScrollWasUserInitiated = false
    }

}

// MARK: - Location Manager Delegate

extension EateriesSharedViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last

        campusEateriesViewController.userLocation = userLocation
        collegetownEateriesViewController.userLocation = userLocation
    }

}
