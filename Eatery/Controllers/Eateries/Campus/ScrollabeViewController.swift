//
//  ScrollabeViewController2.swift
//  Eatery
//
//  Created by Sergio Diaz on 12/9/20.
//  Copyright © 2020 Cornell AppDev. All rights reserved.
//

import UIKit

class ScrollableViewController: UIViewController {

    private var eatery: CampusEatery!
    private var viewControllers: [CampusEateryExpandedMenuViewController]!
    private var allItems: [ExpandedMenu.Item]!

    private var originalViews: [UIView]!
    private var tabBar: TabBar!
    private var tabBarStack: UIStackView!
    private var menuItemsStack: UIStackView!
    private var menuItemsHighToLowStack: UIStackView!
    private var menuItemsLowToHighStack: UIStackView!

    private var menuItemsView: UIView!
    private var filterButton: ExtendedFilterButton!
    private var filterLabel: UILabel!
    private var headerContainer: UIView!
    private var separatorView: SeparatorView!

    let tabBarPadding: CGFloat = 16
    var scrollView: UIScrollView?
    var scrollOffset: CGFloat = 0
    var fillerSpaceHeight: CGFloat = 0

    private var beingMoved = false
    private var isManualScrolling = false
    private var orderedViewsCreated = false

    init(eatery: CampusEatery, viewControllers: [CampusEateryExpandedMenuViewController], items: [ExpandedMenu.Item]) {
        super.init(nibName: nil, bundle: nil)

        self.eatery = eatery
        self.viewControllers = viewControllers
        self.originalViews = viewControllers.map {
            $0.view
        }

        self.allItems = Sort.expandedMenuMergeSort(items)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .wash

        createTabBarStack()
        createMenuStack()
        orderedViewsCreated = false
    }

    override func viewDidAppear(_ animated: Bool) {
        let screenSize = UIScreen.main.bounds.height
        let tabBarHeight = (self.tabBarController?.tabBar.frame.height) ?? 0
        let smallOffset: CGFloat = CampusEateryExpandedMenuViewController.heightConst

        // Scroll Offset is used below because it accounts for NavBar height and edge insets
        // reducedScreenSize accounts for the height of the screen minus all nav and tab bars
        let reducedScreenSize = screenSize + (scrollOffset - tabBarHeight) + smallOffset
        if originalViews.count > 0 {
            let finalView = originalViews[originalViews.count - 1]
            let checkHeight = reducedScreenSize - (menuItemsStack.frame.maxY - finalView.frame.minY)
            fillerSpaceHeight = checkHeight > 0 ? checkHeight : 0
        }

        self.scrollView?.contentSize.height += fillerSpaceHeight
    }

    private func createTabBarStack() {
        headerContainer = UIView()
        headerContainer.layer.zPosition = 3
        headerContainer.backgroundColor = .white
        headerContainer.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

        headerContainer.snp.makeConstraints { make in
            make.height.equalTo(58)
        }

        let titleLabel = UILabel()
        titleLabel.text = "Menu"
        titleLabel.textColor = .black
        titleLabel.font = .boldSystemFont(ofSize: 26)
        titleLabel.preservesSuperviewLayoutMargins = true
        headerContainer.addSubview(titleLabel)

        filterButton = ExtendedFilterButton(frame: .zero, inactiveColor: .systemGray, activeColor: .eateryBlue)
        filterButton.addTarget(self, action: #selector(filterButtonPressed), for: .touchUpInside)
        filterButton.preservesSuperviewLayoutMargins = true
        headerContainer.addSubview(filterButton)

        filterLabel = UILabel()
        filterLabel.textColor = .eateryBlue
        filterLabel.font = .boldSystemFont(ofSize: 11)
        filterLabel.text = ""
        filterLabel.preservesSuperviewLayoutMargins = true
        headerContainer.addSubview(filterLabel)

        separatorView = SeparatorView(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        separatorView.tintColor = .clear
        separatorView.isHidden = true
        headerContainer.addSubview(separatorView)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(tabBarPadding)
            make.centerY.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        filterButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.height.equalTo(titleLabel.snp.height).multipliedBy(0.3)
            make.trailing.equalToSuperview().offset(-tabBarPadding)
            make.width.equalTo(filterButton.snp.height).multipliedBy(1.71)
        }

        filterLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.trailing.equalTo(filterButton.snp.leading).offset(-6)
        }

        separatorView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }

        let titles = viewControllers.map {
            $0.category
        }
        tabBar = ScrollableTextTabBarControl(sections: titles, padding: 16)
        tabBar.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        tabBar.addTarget(self, action: #selector(manualScroll), for: .valueChanged)
        tabBar.backgroundColor = .white
        tabBar.layer.zPosition = 2

        tabBar.snp.makeConstraints { make in
            make.height.equalTo(40)
        }

        tabBarStack = UIStackView(arrangedSubviews: [headerContainer, tabBar])
        tabBarStack.axis = .vertical
    }

    private func createMenuStack() {
        menuItemsView = UIView()
        menuItemsView.backgroundColor = .white

        menuItemsStack = UIStackView(arrangedSubviews: originalViews)
        menuItemsStack.axis = .vertical
        menuItemsView.addSubview(menuItemsStack)
        view.addSubview(menuItemsView)
        view.addSubview(tabBarStack) // Tabbar added here to account for z position

        tabBarStack.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        menuItemsView.snp.makeConstraints { make in
            make.top.equalTo(tabBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        menuItemsStack.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(5)
        }

    }

    private func createHighToLowStack() {
        let reversedItems = Array(allItems.reversed())
        let sortedVC = CampusEateryExpandedMenuViewController(eatery: eatery, category: "", menu: reversedItems)

        menuItemsHighToLowStack = UIStackView(arrangedSubviews: [sortedVC.view])
        menuItemsHighToLowStack.axis = .vertical
        menuItemsView.addSubview(menuItemsHighToLowStack)
        menuItemsHighToLowStack.isHidden = true

        self.menuItemsHighToLowStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func createLowToHighStack() {
        let sortedVC = CampusEateryExpandedMenuViewController(eatery: eatery, category: "", menu: allItems)

        menuItemsLowToHighStack = UIStackView(arrangedSubviews: [sortedVC.view])
        menuItemsLowToHighStack.axis = .vertical
        menuItemsView.addSubview(menuItemsLowToHighStack)
        menuItemsLowToHighStack.isHidden = true

        self.menuItemsLowToHighStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc func manualScroll() {
        let currentPos = self.scrollView?.contentOffset.y
        let viewControllerPosOnParent = self.view.frame.origin.y
        let viewPos = originalViews[tabBar.selectedSegmentIndex].frame.minY
        let minOffset: CGFloat = 4
        let targetPos = viewPos - self.scrollOffset + viewControllerPosOnParent + minOffset
        let topOfSelf = viewControllerPosOnParent - self.scrollOffset
        let pixPS: CGFloat = 2500

        self.isManualScrolling = true

        if self.scrollView?.contentOffset.y ?? 0 > topOfSelf {
            let duration = animationDuration(from: currentPos ?? 0, to: targetPos, at: pixPS)
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
                self.scrollView?.contentOffset.y = targetPos
            }
        } else {
            let duration = animationDuration(from: currentPos ?? 0, to: targetPos, at: pixPS)
            let firstProp = fabs((currentPos ?? 0) - topOfSelf) / fabs((currentPos ?? 0) - targetPos)
            let secondProp = fabs(topOfSelf - targetPos) / fabs((currentPos ?? 0) - targetPos)
            let firstDuration = duration * Double(firstProp)
            let secondDuration = duration * Double(secondProp)

            UIView.animate(withDuration: firstDuration, delay: 0, options: .curveEaseIn, animations: {
                self.scrollView?.contentOffset.y = viewControllerPosOnParent - self.scrollOffset
            }, completion: { completed in
                if completed {
                    UIView.animate(withDuration: secondDuration, delay: 0, options: .curveEaseOut) {
                        self.scrollView?.contentOffset.y = targetPos
                    }
                }
            })

        }

        self.isManualScrolling = false
    }

    // Function helps animations look more proprotional and smooth
    private func animationDuration(from cur: CGFloat, to target: CGFloat, at pps: CGFloat) -> Double {
        let distance = fabs(cur - target)

        switch distance {
        case 0..<75:
            return Double(distance * (1/pps) * 36)
        case 75..<150:
            return Double(distance * (1/pps) * 18)
        case 150..<300:
            return Double(distance * (1/pps) * 6)
        case 300..<1200:
            return Double(distance * (1/pps) * 3)
        default:
            return Double(fabs(cur - target) * (1/pps)) * 1.5
        }
    }

    func scrollMenuBar() {
        let tabBarStackOriginalPos = self.view.frame.origin.y
        let scrollPos = scrollView?.contentOffset.y ?? 0

        if (scrollPos + scrollOffset) > tabBarStackOriginalPos {
            let newPos = (scrollPos + scrollOffset) - tabBarStackOriginalPos
            tabBarStack.center.y = newPos + (tabBarStack.frame.height / 2)
            beingMoved = true
        } else if beingMoved {
            tabBarStack.center.y = tabBarStack.frame.height / 2
        }
    }

    func changeTabBarIndex() {
        if !self.isManualScrolling {
            var selectionIndex = 0
            var testIndex = 1
            let viewControllerPosOnParent = self.view.frame.origin.y
            let currentPos = (scrollView?.contentOffset.y ?? 0) + scrollOffset - viewControllerPosOnParent

            while (testIndex - selectionIndex == 1) && testIndex < originalViews.count {

                if currentPos > originalViews[testIndex].frame.minY {
                    selectionIndex = testIndex
                }
                testIndex += 1
            }

            tabBar.select(at: selectionIndex)
        }
    }

    @objc func filterButtonPressed() {
        filterButton.pressed()

        if filterButton.filterState != .inactive {
            hideTabBar()
        } else {
            showTabBar()
            filterLabel.text = ""
        }
    }

    private func hideTabBar() {
        UIView.animate(withDuration: 0.45) {
            let adjustedPosTabBar = (self.headerContainer.frame.height / 2) - (self.tabBar.frame.height / 2)
            let adjustedPosMenuStack = (self.tabBar.frame.height / 2) + (self.menuItemsView.frame.height / 2)
            self.separatorView.isHidden = false
            self.tabBar.isUserInteractionEnabled = false
            self.tabBar.center.y = self.headerContainer.center.y + adjustedPosTabBar
            self.menuItemsView.center.y = self.tabBar.center.y + adjustedPosMenuStack
        }

        if filterButton.filterState == .hightolow {
            self.scrollView?.contentSize.height -= self.tabBar.frame.height // Does not animate when subtracted
            self.switchToHighToLowStack()
        } else if filterButton.filterState == .lowtohigh {
            self.switchToLowToHighStack()
        }
    }

    private func showTabBar() {
        UIView.animate(withDuration: 0.45) {
            let adjustedPosTabBar = (self.headerContainer.frame.height / 2) + (self.tabBar.frame.height / 2)
            let adjustedPosMenuStack = (self.tabBar.frame.height / 2) + (self.menuItemsView.frame.height / 2)
            self.separatorView.isHidden = true
            self.tabBar.isUserInteractionEnabled = true
            self.tabBar.center.y = self.headerContainer.center.y + adjustedPosTabBar
            self.menuItemsView.center.y = self.tabBar.center.y + adjustedPosMenuStack
            self.scrollView?.contentSize.height += self.tabBar.frame.height
        }

        switchToOriginalStack()
    }

    private func getCompiledItems() -> [ExpandedMenu.Item] {
        var allMenus: [ExpandedMenu.Item] = []
        for controller in viewControllers {
            allMenus += controller.menu
        }

        return allMenus
    }

    private func switchToHighToLowStack() {
        if !orderedViewsCreated {
            createHighToLowStack()
        }
        filterLabel.text = "Highest \u{2794} Lowest"
        menuItemsStack.isHidden = true
        menuItemsHighToLowStack.isHidden = false
    }

    private func switchToLowToHighStack() {
        if !orderedViewsCreated {
            createLowToHighStack()
            orderedViewsCreated = true
        }
        filterLabel.text = "Lowest \u{2794} Highest"
        menuItemsHighToLowStack.isHidden = true
        menuItemsLowToHighStack.isHidden = false

    }

    private func switchToOriginalStack() {
        filterLabel.text = ""
        menuItemsLowToHighStack.isHidden = true
        menuItemsStack.isHidden = false
    }

}
