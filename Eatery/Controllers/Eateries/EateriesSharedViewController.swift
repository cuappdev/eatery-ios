//
//  EateriesSharedViewController.swift
//  Eatery
//
//  Created by Ethan Fine on 4/10/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import CoreLocation
import NVActivityIndicatorView
import UIKit

class EateriesSharedViewController: UIViewController {
    
    // Scroll

    private var lastContentOffset: CGFloat = 0
    
    private var showPillOnScrollStopTimer: Timer?

    // View Controllers

    private(set) lazy var campusEateriesViewController = CampusEateriesViewController()
    private(set) lazy var collegetownEateriesViewController = CollegetownEateriesViewController()

    private(set) lazy var pillViewController = PillViewController(
        leftViewController: campusEateriesViewController,
        rightViewController: collegetownEateriesViewController
    )
    
    var activeViewController: EateriesViewController {
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

    private let activityIndicator = NVActivityIndicatorView(
        frame: CGRect(x: 0, y: 0, width: 22, height: 22),
        type: .circleStrokeSpin,
        color: .white
    )

    // MARK: View Controller

    override func viewDidLoad() {
        super.viewDidLoad()

        pillViewController.delegate = self

        setUpNavigationItem()
        setUpNavigationBar()
        setUpChildViewControllers()
        setUpPillView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setUpLocationManager()
    }

    private func setUpNavigationItem() {
        navigationItem.title = "Eateries"
        navigationController?.hero.isEnabled = !UIAccessibility.isReduceMotionEnabled
        navigationController?.hero.navigationAnimationType = .fade

        let mapButton = UIBarButtonItem(image: #imageLiteral(resourceName: "mapIcon"), style: .done, target: self, action: #selector(openMap))
        mapButton.imageInsets = UIEdgeInsets(top: 0.0, left: 8.0, bottom: 4.0, right: 8.0)
        navigationItem.rightBarButtonItems = [mapButton]

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: activityIndicator)
    }
    
    private func setUpNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true

        let logo = UIImageView(image: UIImage(named: "appDevLogo"))
        logo.tintColor = .eateryBlue
        logo.contentMode = .scaleAspectFit
        navigationController?.navigationBar.addSubview(logo)
        logo.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(28.0)
        }

        campusEateriesViewController.appDevLogo = logo
        collegetownEateriesViewController.appDevLogo = logo
    }

    private func setUpChildViewControllers() {
        campusEateriesViewController.networkActivityIndicator = activityIndicator
        campusEateriesViewController.scrollDelegate = self

        collegetownEateriesViewController.scrollDelegate = self

        addChildViewController(pillViewController)
        view.addSubview(pillViewController.view)
        pillViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pillViewController.didMove(toParentViewController: self)
    }

    private func setUpPillView() {
        let pillView = pillViewController.pillView
        pillView.addTarget(self, action: #selector(pillSelectionDidChange(_:)), for: .valueChanged)

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
        AppDevAnalytics.shared.logFirebase(MapPressPayload())
        
        activeViewController.pushMapViewController()
    }

    @objc private func pillSelectionDidChange(_ sender: PillView) {
        if pillViewController.pillView.leftSegmentSelected {
            AppDevAnalytics.shared.logFirebase(CampusPressPayload())
        } else {
            AppDevAnalytics.shared.logFirebase(CollegetownPressPayload())
        }
    }

}

// MARK: - Eateries View Controller Scroll Delegate

extension EateriesSharedViewController: EateriesViewControllerScrollDelegate {
    
    func eateriesViewController(_ evc: EateriesViewController, scrollViewWillBeginDragging scrollView: UIScrollView) {
        showPillOnScrollStopTimer?.invalidate()
        showPillOnScrollStopTimer = nil
        
        lastContentOffset = scrollView.contentOffset.y
    }

    func eateriesViewController(_ evc: EateriesViewController, scrollViewDidStopScrolling scrollView: UIScrollView) {
        showPillOnScrollStopTimer = Timer.scheduledTimer(withTimeInterval: 0.35, repeats: false) { [weak self] _ in
            self?.pillViewController.setShowPill(true, animated: true)
        }
    }
    
    func eateriesViewController(_ evc: EateriesViewController, scrollViewDidScroll scrollView: UIScrollView) {
        let adjustedOffset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        
        if adjustedOffset < 0 {
            // disregard when the scrollView is "bounced"
            lastContentOffset = 0
        } else {
            let isScrollingDownward = adjustedOffset > lastContentOffset
            
            if isScrollingDownward, pillViewController.isShowingPill {
                pillViewController.setShowPill(false, animated: true)
            } else if !isScrollingDownward, !pillViewController.isShowingPill {
                pillViewController.setShowPill(true, animated: true)
            }
            
            lastContentOffset = adjustedOffset
        }
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

// MARK: - Pill View Controller Delegate

extension EateriesSharedViewController: PillViewControllerDelegate {

    func pillViewControllerSelectedSegmentDidChange(_ pillViewController: PillViewController) {
    }

}
