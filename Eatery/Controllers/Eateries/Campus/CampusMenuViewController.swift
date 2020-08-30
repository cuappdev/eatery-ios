//
//  CampusMenuViewController.swift
//  Eatery
//
//  Created by William Ma on 10/13/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import CoreLocation
import Hero
import MapKit
import UIKit

class CampusMenuViewController: EateriesMenuViewController {

    private let eatery: CampusEatery

    init(eatery: CampusEatery, userLocation: CLLocation?) {
        self.eatery = eatery

        super.init(eatery: eatery, userLocation: userLocation)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addMenuInfoView()
        addSeparatorView()

        if !eatery.swipeDataByHour.isEmpty {
            addPopularTimesView()
            addSeparatorView()
        }

        addDirectionsButton()
        addBlockSeparator()

        addMenuLabel()
        addMenuPageViewController()
    }

    private func addMenuInfoView() {
        let infoView = CampusMenuInfoView()
        infoView.configure(eatery: eatery, userLocation: userLocation, meal: "Lunch")
        addToStackView(infoView)

        infoView.hero.id = EateriesViewController.AnimationKey.infoContainer.id(eatery: eatery)
        let fadeModifiers = createHeroModifiers(.fade)
        infoView.hoursHero.modifiers = fadeModifiers
        infoView.statusHero.modifiers = fadeModifiers
        infoView.locationHero.modifiers = fadeModifiers
        infoView.distanceHero.modifiers = fadeModifiers
    }

    private func addPopularTimesView() {
        let popularTimesView = PopularTimesView(eatery: eatery)
        addToStackView(popularTimesView)

        popularTimesView.hero.modifiers = createHeroModifiers(.fade)
    }

    private func addDirectionsButton() {
        let directionsButton = UIButton(type: .system)
        directionsButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        directionsButton.setTitle("Get Directions", for: .normal)
        directionsButton.tintColor = .eateryBlue
        directionsButton.addTarget(self, action: #selector(directionsButtonPressed(_:)), for: .touchUpInside)
        directionsButton.snp.makeConstraints { make in
            make.height.equalTo(34)
        }

        addToStackView(directionsButton)

        directionsButton.hero.modifiers = createHeroModifiers(.fade)
    }

    private func addMenuLabel() {
        let containerView = UIView()

        let menuLabel = UILabel()
        menuLabel.text = "Menu"
        menuLabel.textColor = .black
        menuLabel.font = .boldSystemFont(ofSize: 24)

        containerView.addSubview(menuLabel)
        menuLabel.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }

        addToStackView(containerView)

        menuLabel.hero.modifiers = createHeroModifiers(.fade, .translate)
    }

    private func addMenuPageViewController() {
        let viewControllers = eatery.meals(onDayOf: Date()).map {
            CampusEateryMealTableViewController(eatery: eatery, meal: $0)
        }

        let pageViewController = TabbedPageViewController(viewControllers: viewControllers)
        pageViewController.delegate = self

        addChildViewController(pageViewController)
        addToStackView(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)

        pageViewController.view.hero.modifiers = createHeroModifiers(.fade, .translate)

        if let currentEvent = eatery.currentActiveEvent() {
            for (index, viewController) in viewControllers.enumerated() {
                let event = eatery.getEvent(meal: viewController.meal, onDayOf: Date())
                if event?.desc == currentEvent.desc
                    || currentEvent.desc == "Lite Lunch" && viewController.meal == "Lunch" {
                    pageViewController.currentViewControllerIndex = index
                }
            }
        }
    }

    @objc private func directionsButtonPressed(_ sender: UIButton) {
        openDirectionsToEatery()
    }

}

extension CampusMenuViewController: TabbedPageViewControllerDelegate {

    func tabbedPageViewController(
        _ tabbedPageViewController: TabbedPageViewController,
        titleForViewController viewController: UIViewController
    ) -> String? {
        guard let mealViewController = viewController as? CampusEateryMealTableViewController else {
            return nil
        }

        return mealViewController.meal
    }

    func tabbedPageViewController(
        _ tabbedPageViewController: TabbedPageViewController,
        heightOfContentForViewController viewController: UIViewController
    ) -> CGFloat {
        guard let mealViewController = viewController as? CampusEateryMealTableViewController else {
            return 0
        }

        mealViewController.tableView.layoutIfNeeded()
        return mealViewController.tableView.contentSize.height
    }

}
