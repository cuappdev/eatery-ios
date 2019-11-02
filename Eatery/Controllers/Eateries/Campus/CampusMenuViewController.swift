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

    private let infoView = CampusMenuInfoView()

    init(eatery: CampusEatery, userLocation: CLLocation?) {
        self.eatery = eatery

        super.init(eatery: eatery, userLocation: userLocation)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addMenuInfoView(CampusMenuInfoView())
        addSeparatorView()
        addPopularTimesView()
        addSeparatorView()
        addDirectionsButton()
        addBlockSeparator()

        addMenuLabel()
        addMenuPageViewController()
    }

    private func addPopularTimesView() {
        let popularTimesView = PopularTimesView(eatery: eatery)
        popularTimesView.layoutDelegate = self
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
            make.height.equalTo(34.0)
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
        // meals sorted by start time without lite lunch
        let meals = eatery
            .eventsByName(onDayOf: Date())
            .sorted { $0.1.start < $1.1.start }
            .map { $0.key }
            .filter { $0 != "Lite Lunch" }

        var viewControllers: [CampusEateryMealTableViewController] = []
        for meal in meals {
            let viewController = CampusEateryMealTableViewController(eatery: eatery, meal: meal, date: Date())
            viewControllers.append(viewController)
        }

        let pageViewController = TabbedPageViewController(viewControllers: viewControllers)
        pageViewController.delegate = self

        addChildViewController(pageViewController)
        addToStackView(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)

        pageViewController.view.hero.modifiers = createHeroModifiers(.fade, .translate)

        if let currentEvent = eatery.activeEvent(atExactly: Date()) {
            for (index, viewController) in viewControllers.enumerated() {
                if viewController.event?.desc == currentEvent.desc
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

extension CampusMenuViewController: PopularTimesViewLayoutDelegate {

    func popularTimesContentSizeDidChange(_ popularTimesView: PopularTimesView) {
        view.layoutIfNeeded()
    }

}

extension CampusMenuViewController: TabbedPageViewControllerDelegate {

    func tabbedPageViewController(_ tabbedPageViewController: TabbedPageViewController, titleForViewController viewController: UIViewController) -> String? {
        guard let mealViewController = viewController as? CampusEateryMealTableViewController else {
            return nil
        }

        return mealViewController.meal
    }

    func tabbedPageViewController(_ tabbedPageViewController: TabbedPageViewController,
                                  heightOfContentForViewController viewController: UIViewController) -> CGFloat {
        guard let mealViewController = viewController as? CampusEateryMealTableViewController else {
            return 0
        }

        mealViewController.tableView.layoutIfNeeded()
        return mealViewController.tableView.contentSize.height
    }
    
}


