//
//  EateriesSharedViewController.swift
//  Eatery
//
//  Created by Ethan Fine on 4/10/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import AppDevAnnouncements
import CoreLocation
import NVActivityIndicatorView
import UIKit

class EateriesSharedViewController: UIViewController {
    
    // Scroll

    private var lastContentOffset: CGFloat = 0
    private var showPillOnScrollStopTimer: Timer?

    // View Controllers

    private lazy var campusEateriesVC = CampusEateriesViewController()
    private lazy var campusNavigationVC = EateryNavigationController(rootViewController: campusEateriesVC)
    private lazy var collegetownEateriesVC = CollegetownEateriesViewController()
    private lazy var collegetownNavigationVC = EateryNavigationController(rootViewController: collegetownEateriesVC)
    private lazy var pillViewController = PillViewController(
        leftViewController: campusNavigationVC,
        rightViewController: collegetownNavigationVC
    )

    var activeNavigationController: EateryNavigationController {
        if pillViewController.pillView.leftSegmentSelected {
            return campusNavigationVC
        } else {
            return collegetownNavigationVC
        }
    }

    var activeViewController: EateriesViewController {
        pillViewController.pillView.leftSegmentSelected
            ? campusEateriesVC
            : collegetownEateriesVC
    }

    // Location

    private lazy var locationManager: CLLocationManager = {
        let l = CLLocationManager()
        l.delegate = self
        l.desiredAccuracy = kCLLocationAccuracyBest
        l.startUpdatingLocation()
        return l
    }()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View Controller

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpEateriesViewControllers()
        setUpPillView()

        pillViewController.delegate = self

        // Present announcement if there are any new ones to present
        presentAnnouncement { presented in
            if presented {
                AppDevAnalytics.shared.logFirebase(AnnouncementPresentedPayload())
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setUpLocationManager()
    }

    func preselectEatery(withName name: String) {
        campusEateriesVC.preselectEatery(withName: name)
    }

    private func setUpEateriesViewControllers() {
        campusNavigationVC.delegate = self
        campusEateriesVC.scrollDelegate = self

        collegetownNavigationVC.delegate = self
        collegetownEateriesVC.scrollDelegate = self
        collegetownEateriesVC.loadViewIfNeeded()

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

    @objc private func pillSelectionDidChange(_ sender: PillView) {
        if pillViewController.pillView.leftSegmentSelected {
            AppDevAnalytics.shared.logFirebase(CampusPressPayload())
        } else {
            AppDevAnalytics.shared.logFirebase(CollegetownPressPayload())
        }
    }

    private func updateShowPill() {
        let showPill =
            (pillViewController.pillView.leftSegmentSelected && campusNavigationVC.viewControllers.count == 1)
            || (!pillViewController.pillView.leftSegmentSelected && collegetownNavigationVC.viewControllers.count == 1)

        pillViewController.setShowPill(showPill, animated: true)
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

        campusEateriesVC.userLocation = userLocation
        collegetownEateriesVC.userLocation = userLocation
    }

}

// MARK: - Pill View Controller Delegate

extension EateriesSharedViewController: PillViewControllerDelegate {

    func pillViewControllerSelectedSegmentDidChange(_ pillViewController: PillViewController) {
        updateShowPill()
    }

}

// MARK: - Navigation Controller Delegate

extension EateriesSharedViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.extendedLayoutIncludesOpaqueBars = true

        let isParallax = viewController is ImageParallaxScrollViewController
        navigationController.setNavigationBarHidden(isParallax, animated: true)
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        updateShowPill()
    }

}
