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

    struct ScrollSession {

        /// The offset of the scroll view when the user started scrolling
        let start: CGFloat

        /// The offset of the scroll view just before the current update
        var prev: CGFloat

        var prevTime: TimeInterval

        /// The current offset of the scroll view
        var curr: CGFloat

        var currTime: TimeInterval

        init(start: CGFloat) {
            self.start = start
            self.prev = start
            self.curr = start
            self.prevTime = Date().timeIntervalSinceReferenceDate
            self.currTime = self.prevTime
        }

    }

    private let eatery: CampusEatery

    private let orderButton = UIButton()
    private var orderButtonIsHidden = false
    private var scroll: ScrollSession?
    private var showOrderButtonTimer: Timer?

    private var infoView: CampusMenuInfoView!
    private var scrollableVC: ScrollableViewController?

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

        if eatery.eateryType != .dining {
            addExtendedMenuViewController()
        } else {
            addMenuLabel()
            addTabbedMenuViewController()
        }

        setUpOrderButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let scrollableVC = scrollableVC {
            scrollableVC.scrollView = scrollView
            scrollableVC.scrollOffset = scrollOffset ?? 0
        }
    }

    private func addMenuInfoView() {
        infoView = CampusMenuInfoView()
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
            make.height.equalTo(44)
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview()
        }

        addToStackView(containerView)

        menuLabel.hero.modifiers = createHeroModifiers(.fade, .translate)
    }

    private func addTabbedMenuViewController() {
        view.backgroundColor = .white  // Changing background color here simplifies ScrollableViewController

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

    private func addExtendedMenuViewController() {
        view.backgroundColor = .wash  // Changing background color here simplifies ScrollableViewController

        guard !eatery.orderedExpandedCategories.isEmpty else { return }

        let expandedMenu = eatery.expandedMenu
        var views: [ExpandedMenuCategoryView] = []
        var menuItems: [ExpandedMenu.Item] = []

        for category in eatery.orderedExpandedCategories {
            let menu = expandedMenu?.data[category] ?? []
            let extendedMenuVC = ExpandedMenuCategoryView(eatery: eatery, category: category, menu: menu)
            views.append(extendedMenuVC)
            menuItems.append(contentsOf: menu)
        }

        let scrollVC = ScrollableViewController(eatery: eatery, categoryViews: views, items: menuItems)
        addChildViewController(scrollVC)
        addToStackView(scrollVC.view)
        scrollVC.didMove(toParentViewController: self)
        scrollVC.view.hero.modifiers = createHeroModifiers(.fade, .translate)
        scrollableVC = scrollVC
    }

    private func setUpOrderButton() {
        orderButton.setImage(UIImage(named: "link"), for: .normal)

        switch eatery.reservationType {
        case .get:
            if let url = URL.getUrl, UIApplication.shared.canOpenURL(url) {
                orderButton.setTitle("Order on GET", for: .normal)
            } else {
                orderButton.isHidden = true
            }

        case .url(let url):
            if UIApplication.shared.canOpenURL(url) {
                orderButton.setTitle("Reserve on OpenTable", for: .normal)
            } else {
                orderButton.isHidden = true
            }

        case .none:
            orderButton.isHidden = true
        }

        orderButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        orderButton.backgroundColor = .eateryBlue
        orderButton.layer.cornerRadius = 8
        orderButton.layer.shadowRadius = 4
        orderButton.layer.shadowColor = UIColor(hex: 0x959DA5).cgColor
        orderButton.layer.shadowOpacity = 0.5
        orderButton.layer.shadowOffset = .zero
        orderButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        orderButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        orderButton.hero.modifiers = createHeroModifiers(.fade)

        // force the image on the right-hand side of the button
        orderButton.semanticContentAttribute = .forceRightToLeft

        orderButton.adjustsImageWhenHighlighted = false
        orderButton.addTarget(self, action: #selector(highlightOrderButton), for: .touchDown)
        orderButton.addTarget(self, action: #selector(unhighlightOrderButton), for: .touchUpOutside)
        orderButton.addTarget(self, action: #selector(orderButtonPressed), for: .touchUpInside)

        view.addSubview(orderButton)
        orderButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottomMargin).inset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }

    @objc private func orderButtonPressed(_ sender: UIButton) {
        let url: URL?
        switch eatery.reservationType {
        case .get: url = .getUrl
        case .url(let externalUrl): url = externalUrl
        case .none: url = nil
        }

        if let url = url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

        unhighlightOrderButton()
    }

    @objc private func highlightOrderButton() {
        orderButton.backgroundColor = .darkEateryBlue
    }

    @objc private func unhighlightOrderButton() {
        orderButton.backgroundColor = .eateryBlue
    }

    private func orderButtonMaxYTransform() -> CGFloat {
        // distance from the top of the order button to the bottom of the view
        // plus some additional padding
        max(0, view.frame.maxY - (orderButton.center.y - orderButton.bounds.height / 2) + 16)
    }

    private func setOrderButtonHidden(_ isHidden: Bool, animated: Bool) {
        orderButtonIsHidden = isHidden

        let animation = UIViewPropertyAnimator(duration: 0.35, dampingRatio: 1.0) {
            if isHidden {
                self.orderButton.transform.ty = self.orderButtonMaxYTransform()
            } else {
                self.orderButton.transform.ty = 0
            }
        }

        animation.startAnimation()
        if !animated {
            animation.stopAnimation(false)
            animation.finishAnimation(at: .end)
        }
    }

    @objc private func directionsButtonPressed(_ sender: UIButton) {
        openDirectionsToEatery()
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scroll = ScrollSession(start: scrollView.contentOffset.y)
        showOrderButtonTimer?.invalidate()
        showOrderButtonTimer = nil
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)

        if let scrollableVC = self.scrollableVC {
            scrollableVC.scrollMenuBar()
            scrollableVC.changeTabBarIndex()
        }

        guard var scroll = scroll else {
            return
        }

        scroll.prev = scroll.curr
        scroll.prevTime = scroll.currTime
        scroll.curr = scrollView.contentOffset.y
        scroll.currTime = Date().timeIntervalSinceReferenceDate

        // distance from the top of the order button to the bottom of the view
        // plus some additional padding
        let maxYTransform = orderButtonMaxYTransform()

        let dampeningFactor: CGFloat = 0.5

        orderButton.transform.ty =
            (0...maxYTransform).clamp(orderButton.transform.ty + dampeningFactor * (scroll.curr - scroll.prev))

        self.scroll = scroll
    }

    private func shouldHideOrderButton(scroll: ScrollSession, orderButtonIsHidden: Bool) -> Bool {
        let now = Date().timeIntervalSinceReferenceDate
        guard scroll.prevTime < now else {
            return false
        }

        // if the user is scrolling with enough velocity in one direction or
        // another, hide or show the order button accordingly

        let requiredVelocity: CGFloat = 500

        // take into account the current time in case the user holds their
        // finger on the scroll view, then releases
        let deltaT = CGFloat(now - scroll.prevTime)
        let deltaY = scroll.curr - scroll.prev
        let velocity = deltaY / deltaT
        if velocity > requiredVelocity {
            return true
        } else if velocity < -requiredVelocity {
            return false
        }

        let fractionToBottom = (0...1).clamp(orderButton.transform.ty / orderButtonMaxYTransform())
        let boundary: CGFloat = 1 / 2
        if orderButtonIsHidden {
            return fractionToBottom > 1 - boundary
        } else {
            return fractionToBottom > boundary
        }
    }

    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        if let scroll = scroll {
            setOrderButtonHidden(
                shouldHideOrderButton(scroll: scroll, orderButtonIsHidden: orderButtonIsHidden),
                animated: true
            )
            self.scroll = nil
        }

        showOrderButtonTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
            self?.setOrderButtonHidden(false, animated: true)
        }
    }

}

extension CampusMenuViewController: TabbedPageViewControllerDelegate {
    func tabbedPageViewController(
        _ tabbedPageViewController: TabbedPageViewController,
        titleForViewController viewController: UIViewController
    ) -> String? {
        guard let mealViewController = viewController as? CampusEateryMealTableViewController else {
            return ""
        }

        return mealViewController.meal
    }

    func tabbedPageViewController(
        _ tabbedPageViewController: TabbedPageViewController,
        heightOfContentForViewController viewController: UIViewController
    ) -> CGFloat {
        guard let mealTableViewController = viewController as? CampusEateryMealTableViewController else {
            return 0
        }

        mealTableViewController.tableView.layoutIfNeeded()
        return mealTableViewController.tableView.contentSize.height
    }

}
