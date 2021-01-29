//
//  ScrollableViewController.swift
//  Eatery
//
//  Created by Sergio Diaz on 12/9/20.
//  Copyright © 2020 Cornell AppDev. All rights reserved.
//

import UIKit

class ScrollableViewController: UIViewController {

    private let eatery: CampusEatery!
    private let viewControllers: [CampusEateryExpandedMenuViewController]!  // The VCs for each menu section
    private let originalViews: [UIView]!    // The views of the VCs for each menu section
    private let allItems: [ExpandedMenu.Item]!  // All menu items combined into array and sorted

    private var headerContainer: ExpandedHeaderContainer!
    private var tabBar: TabBar!
    private var tabBarStack: UIStackView!
    private var menuItemsView: ExpandedMenuItemView!

    var scrollView: UIScrollView?
    var scrollOffset: CGFloat = 0
    private var fillerSpaceHeight: CGFloat = 0

    private var beingMoved = false
    private var isManualScrolling = false
    private var orderedViewsCreated = false

    init(eatery: CampusEatery, viewControllers: [CampusEateryExpandedMenuViewController], items: [ExpandedMenu.Item]) {
        self.eatery = eatery
        self.viewControllers = viewControllers
        self.originalViews = viewControllers.map { $0.view }
        self.allItems = items.sorted { item1, item2 in
            if item1.getNumericPrice() > item2.getNumericPrice() {
                return false
            }
            return true
        }

        super.init(nibName: nil, bundle: nil)
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
        let tabBarHeight = (tabBarController?.tabBar.frame.height) ?? 0
        let smallOffset: CGFloat = CampusEateryExpandedMenuViewController.heightConst

        // Scroll Offset is used below because it accounts for NavBar height and edge insets
        // reducedScreenSize accounts for the height of the screen minus all nav and tab bars
        let reducedScreenSize = screenSize + (scrollOffset - tabBarHeight) + smallOffset
        if originalViews.count > 0 {
            let finalView = originalViews[originalViews.count - 1]
            let checkHeight = reducedScreenSize - (menuItemsView.getOriginalMaxY() - finalView.frame.minY)
            fillerSpaceHeight = checkHeight > 0 ? checkHeight : 0
        }

        scrollView?.contentSize.height += fillerSpaceHeight
    }

    private func createTabBarStack() {
        headerContainer = ExpandedHeaderContainer()
        headerContainer.backgroundColor = .white
        headerContainer.addFilterButtonTarget(self, action: #selector(filterButtonPressed), forEvent: .touchUpInside)

        headerContainer.snp.makeConstraints { make in
            make.height.equalTo(58)
        }

        let titles = viewControllers.map {
            $0.category
        }
        tabBar = ScrollableTextTabBarControl(sections: titles, padding: 16)
        tabBar.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        tabBar.addTarget(self, action: #selector(manualScroll), for: .valueChanged)
        tabBar.backgroundColor = .white

        tabBar.snp.makeConstraints { make in
            make.height.equalTo(40)
        }

        tabBarStack = UIStackView(arrangedSubviews: [headerContainer, tabBar])
        tabBarStack.bringSubview(toFront: headerContainer)
        tabBarStack.axis = .vertical
        view.addSubview(tabBarStack)
        view.bringSubview(toFront: tabBarStack)
    }

    private func createMenuStack() {
        menuItemsView = ExpandedMenuItemView(frame: .zero, eatery: eatery, views: originalViews, allMenuItems: allItems)
        menuItemsView.backgroundColor = .white
        view.addSubview(menuItemsView)
        view.sendSubview(toBack: menuItemsView)

        tabBarStack.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        menuItemsView.snp.makeConstraints { make in
            make.top.equalTo(tabBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

    }

    /*  This function manages the automatic scroll that occurs when a user presses a button in the tabbar
        to go to a specific expanded menu category. This can happen in 2 ways:
        1. The user presses the button after already scrolling past the top of this ViewController
        2. The user presses the button before scrolling past this view controller
        (i.e. scrollView is near the top of CampusMenuViewController)
        The first operation is very simple, as visible by the "if" statement below. However, the second
        (occurs in "else) is much more complicated because we have to split the automatic scroll operation
        into two pieces: scrolling to the top of this view controller and scrolling to the target.  If we
        don't do this, the tabBarStack will scroll unevenly with the rest of the scroll view.   */
    @objc func manualScroll() {
        let minOffset: CGFloat = 4
        let currentPos = scrollView?.contentOffset.y ?? 0
        let viewControllerPosOnParent = view.frame.origin.y
        let viewPos = originalViews[tabBar.selectedSegmentIndex].frame.minY
        let targetPos = viewPos - scrollOffset + viewControllerPosOnParent + minOffset
        let topOfSelf = viewControllerPosOnParent - scrollOffset
        let duration = animationDuration(from: currentPos, to: targetPos, withConst: 0.03)

        isManualScrolling = true

        if currentPos > topOfSelf {
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
                self.scrollView?.contentOffset.y = targetPos
            }
        } else {
            // firstProp represents the proportion of animation time spent scrolling from currentPos to the top of self
            // secondProp represents the proportion of animation time spent scrolling from the top of self to targetPos
            let firstProp = fabs((currentPos) - topOfSelf) / fabs((currentPos) - targetPos)
            let secondProp = fabs(topOfSelf - targetPos) / fabs((currentPos) - targetPos)
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

        isManualScrolling = false
    }

    /*  This function helps scroll animations look more proportional.  However, smaller distances should travel
        slower, proportionally, compared to larger distances.  That's why this function is logarithmic rather
        than linear.  If it were linear, shorter scrolls would look too short and choppy.   */
    private func animationDuration(from cur: CGFloat, to target: CGFloat, withConst propConstant: CGFloat) -> Double {
        let distance = fabs(cur - target)
        return Double(log(distance) * log(distance) * propConstant) // Prop constant should be less than 0.1
    }

    func scrollMenuBar() {
        let tabBarStackOriginalPos = view.frame.origin.y
        let scrollPosWithOffset = (scrollView?.contentOffset.y ?? 0) + scrollOffset

        if scrollPosWithOffset > tabBarStackOriginalPos {
            let newPos = scrollPosWithOffset - tabBarStackOriginalPos
            tabBarStack.center.y = newPos + (tabBarStack.frame.height / 2)
            beingMoved = true
        } else if beingMoved {
            tabBarStack.center.y = tabBarStack.frame.height / 2
        }
    }

    func changeTabBarIndex() {
        if !isManualScrolling {
            var selectionIndex = 0
            var testIndex = 1
            let viewControllerPosOnParent = view.frame.origin.y
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
        headerContainer.filterButtonPressed()

        if headerContainer.getFilterButtonState() != .inactive {
            hideTabBar()
        } else {
            showTabBar()
            headerContainer.setFilterLabelText(to: "")
        }
    }

    private func hideTabBar() {
        UIView.animate(withDuration: 0.45) {
            let adjustedPosTabBar = (self.headerContainer.frame.height / 2) - (self.tabBar.frame.height / 2)
            let adjustedPosMenuStack = (self.tabBar.frame.height / 2) + (self.menuItemsView.frame.height / 2)
            self.headerContainer.setSeparatorViewHidden(to: false)
            self.tabBar.isUserInteractionEnabled = false
            self.tabBar.center.y = self.headerContainer.center.y + adjustedPosTabBar
            self.menuItemsView.center.y = self.tabBar.center.y + adjustedPosMenuStack
        }

        if headerContainer.getFilterButtonState() == .hightolow {
            scrollView?.contentSize.height -= tabBar.frame.height // Does not animate when subtracted
            switchToHighToLowStack()
        } else if headerContainer.getFilterButtonState() == .lowtohigh {
            switchToLowToHighStack()
        }
    }

    private func showTabBar() {
        UIView.animate(withDuration: 0.45) {
            let adjustedPosTabBar = (self.headerContainer.frame.height / 2) + (self.tabBar.frame.height / 2)
            let adjustedPosMenuStack = (self.tabBar.frame.height / 2) + (self.menuItemsView.frame.height / 2)
            self.headerContainer.setSeparatorViewHidden(to: true)
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
            menuItemsView.createHighToLowStack()
        }
        headerContainer.setFilterLabelText(to: "Highest \u{2794} Lowest")
        menuItemsView.switchVisibleStack(type: .highToLow)
    }

    private func switchToLowToHighStack() {
        if !orderedViewsCreated {
            menuItemsView.createLowToHighStack()
            orderedViewsCreated = true
        }
        headerContainer.setFilterLabelText(to: "Lowest \u{2794} Highest")
        menuItemsView.switchVisibleStack(type: .lowToHigh)

    }

    private func switchToOriginalStack() {
        headerContainer.setFilterLabelText(to: "")
        menuItemsView.switchVisibleStack(type: .original)
    }

}
