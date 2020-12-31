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
    private var viewControllers: [CampusEateryExtendedMenuViewController]!

    private var tabBar: TabBar!
    private var originalViews: [UIView]!
    private var tabBarStack: UIStackView!
    private var menuItemsStack: UIStackView!
    private var menuItemsHighToLowStack: UIStackView!
    private var menuItemsLowToHighStack: UIStackView!

    private var menuItemsView: UIView!
    private var filterButton: ExtendedFilterButton!
    private var filterLabel: UILabel!
    private var headerContainer: UIView!
    private var separatorView: SeparatorView!

    var scrollView: UIScrollView?
    var scrollOffset: CGFloat = 0

    private var beingMoved: Bool = false
    private var isManualScrolling: Bool = false

    init(eatery: CampusEatery, viewControllers: [CampusEateryExtendedMenuViewController]) {
        super.init(nibName: nil, bundle: nil)

        self.eatery = eatery
        self.viewControllers = viewControllers
        self.originalViews = viewControllers.map {
            $0.view
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        createTabBarStack()
        createMenuStack()
        createHighToLowStack()
        createLowToHighStack()
    }

    private func createTabBarStack() {
        let titleLabel = UILabel()
        titleLabel.text = "Menu"
        titleLabel.textColor = .black
        titleLabel.font = .boldSystemFont(ofSize: 26)

        headerContainer = UIView()
        headerContainer.layer.zPosition = 3
        headerContainer.backgroundColor = .white
        headerContainer.addSubview(titleLabel)

        filterButton = ExtendedFilterButton(frame: .zero, inactiveColor: .systemGray, activeColor: .eateryBlue)
        filterButton.addTarget(self, action: #selector(filterButtonPressed), for: .touchUpInside)
        headerContainer.addSubview(filterButton)

        filterLabel = UILabel()
        filterLabel.textColor = .eateryBlue
        filterLabel.font = .boldSystemFont(ofSize: 11)
        filterLabel.text = ""
        headerContainer.addSubview(filterLabel)

        separatorView = SeparatorView(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        separatorView.tintColor = .clear
        separatorView.isHidden = true
        headerContainer.addSubview(separatorView)

        headerContainer.snp.makeConstraints { make in
            make.height.equalTo(58)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        filterButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.height.equalTo(titleLabel.snp.height).multipliedBy(0.3)
            make.trailing.equalToSuperview()
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
            $0.meal
        }
        tabBar = ScrollableTextTabBarControl(sections: titles)
        tabBar.addTarget(self, action: #selector(manualScroll), for: .valueChanged)
        tabBar.backgroundColor = .white
        tabBar.layer.zPosition = 2
        view.addSubview(tabBar)

        tabBar.snp.makeConstraints { make in
            make.height.equalTo(40)
        }

        let tabBarItems: [UIView] = [headerContainer, tabBar]
        tabBarStack = UIStackView(arrangedSubviews: tabBarItems)
        tabBarStack.axis = .vertical
    }

    private func createMenuStack() {
        menuItemsView = UIView()

//        let filler = ExtendedMenuRow(item: Menu.Item(name: "", healthy: false, prices: []), hasSeparator: false)
//        originalViews.append(filler)

        menuItemsStack = UIStackView(arrangedSubviews: originalViews)
        menuItemsStack.axis = .vertical

        menuItemsView.addSubview(menuItemsStack)
        view.addSubview(menuItemsView)
        view.addSubview(tabBarStack) // Tabbar added here to account for z position

        tabBarStack.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(6)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        menuItemsView.snp.makeConstraints { make in
            make.top.equalTo(tabBar.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(5)
            make.bottom.equalToSuperview()
        }

        menuItemsStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func createHighToLowStack() {
        let sortedMenu = Menu(data: ["": Sort.menuMergeSort(getCompiledItems()).reversed()])
        let sortedVC = CampusEateryExtendedMenuViewController(eatery: eatery, val: true, menu: sortedMenu)
//        let filler = ExtendedMenuRow(item: Menu.Item(name: "", healthy: false, prices: []), hasSeparator: false)

        menuItemsHighToLowStack = UIStackView(arrangedSubviews: [sortedVC.view])
        menuItemsHighToLowStack.axis = .vertical
        menuItemsView.addSubview(menuItemsHighToLowStack)
        menuItemsHighToLowStack.isHidden = true

        self.menuItemsHighToLowStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func createLowToHighStack() {
        let sortedMenu = Menu(data: ["": Sort.menuMergeSort(getCompiledItems())])
        let sortedVC = CampusEateryExtendedMenuViewController(eatery: eatery, val: true, menu: sortedMenu)
//        let filler = ExtendedMenuRow(item: Menu.Item(name: "", healthy: false, prices: []), hasSeparator: false)

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
            UIView.animate(withDuration: duration) {
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

    private func animationDuration(from cur: CGFloat, to target: CGFloat, at pps: CGFloat) -> Double {
        let distance = fabs(cur - target)

        if distance < 300 {
            return Double(distance * (1/pps) * 6)
        } else if distance < 1200 {
            return Double(distance * (1/pps) * 3)
        }

        return Double(fabs(cur - target) * (1/pps)) * 1.75
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
        UIView.animate(withDuration: 0.35) {
            let adjustedPosTabBar = (self.headerContainer.frame.height / 2) - (self.tabBar.frame.height / 2)
            let adjustedPosMenuStack = (self.tabBar.frame.height / 2) + (self.menuItemsView.frame.height / 2)
            self.separatorView.isHidden = false
            self.tabBar.isUserInteractionEnabled = false
            self.tabBar.center.y = self.headerContainer.center.y + adjustedPosTabBar
            self.menuItemsView.center.y = self.tabBar.center.y + adjustedPosMenuStack
        }

        if filterButton.filterState == .hightolow {
            filterLabel.text = "Highest \u{2794} Lowest"
            self.switchToHighToLowStack()
        } else if filterButton.filterState == .lowtohigh {
            filterLabel.text = "Lowest \u{2794} Highest"
            self.switchToLowToHighStack()
        }
    }

    private func showTabBar() {
        UIView.animate(withDuration: 0.35) {
            let adjustedPosTabBar = (self.headerContainer.frame.height / 2) + (self.tabBar.frame.height / 2)
            let adjustedPosMenuStack = (self.tabBar.frame.height / 2) + (self.menuItemsView.frame.height / 2)
            self.separatorView.isHidden = true
            self.tabBar.isUserInteractionEnabled = true
            self.tabBar.center.y = self.headerContainer.center.y + adjustedPosTabBar
            self.menuItemsView.center.y = self.tabBar.center.y + adjustedPosMenuStack
        }

        switchToOriginalStack()
        filterLabel.text = ""
    }

    private func getCompiledItems() -> [Menu.Item] {
        let menus = viewControllers.map {
            $0.menu
        }

        var allItems: [Menu.Item] = []
        for menu in menus {
            if let currentMenu = menu {
                var tempArray: [Menu.Item] = []
                for key in currentMenu.data.keys {
                    tempArray.append(contentsOf: currentMenu.data[key]!)
                }
                allItems.append(contentsOf: tempArray)
            }
        }

        return allItems
    }

    private func switchToHighToLowStack() {
        menuItemsStack.isHidden = true
        menuItemsHighToLowStack.isHidden = false
    }

    private func switchToLowToHighStack() {
        menuItemsHighToLowStack.isHidden = true
        menuItemsLowToHighStack.isHidden = false
    }

    private func switchToOriginalStack() {
        menuItemsLowToHighStack.isHidden = true
        menuItemsStack.isHidden = false
    }

}
