//
//  ScrollableViewController.swift
//  Eatery
//
//  Created by Sergio Diaz on 12/9/20.
//  Copyright © 2020 Cornell AppDev. All rights reserved.
//

import UIKit

class ScrollableViewController: UIViewController {

    private let eatery: CampusEatery
    /// The views for each menu section
    private let categoryViews: [ExpandedMenuCategoryView]
    // All menu items combined into array and sorted
    private let allItems: [ExpandedMenu.Item]

    private var headerContainer: ExpandedHeaderContainer!
    private var tabBar: TabBar!
    private var tabBarStack: UIStackView!
    private var menuItemsView: ExpandedMenuItemView!

    var scrollView: UIScrollView?
    var scrollOffset: CGFloat = 0
    private var fillerSpaceHeight: CGFloat = 0

    private var beingMoved = false
    private var orderedViewsCreated = false

    init(eatery: CampusEatery, categoryViews: [ExpandedMenuCategoryView], items: [ExpandedMenu.Item]) {
        self.eatery = eatery
        self.categoryViews = categoryViews
        self.allItems = items.sorted { item1, item2 in
            item1.getNumericPrice() < item2.getNumericPrice()
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
        let smallOffset: CGFloat = ExpandedMenuRow.heightConst

        // Scroll Offset is used below because it accounts for NavBar height and edge insets
        // reducedScreenSize accounts for the height of the screen minus all nav and tab bars
        let reducedScreenSize = screenSize + (scrollOffset - tabBarHeight) + smallOffset
        if categoryViews.count > 0 {
            let finalView = categoryViews[categoryViews.count - 1]
            let checkHeight = reducedScreenSize - (menuItemsView.getOriginalMaxY() - finalView.frame.minY)
            fillerSpaceHeight = checkHeight > 0 ? checkHeight : 0
        }

        scrollView?.contentSize.height += fillerSpaceHeight
    }

    private func createTabBarStack() {
        headerContainer = ExpandedHeaderContainer()
        headerContainer.backgroundColor = .white
        headerContainer.snp.makeConstraints { make in
            make.height.equalTo(58)
        }

        let titles = categoryViews.map {
            $0.category ?? "Unnamed"
        }
        tabBar = ScrollableTextTabBarControl(sections: titles, padding: 16)
        tabBar.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        tabBar.addTarget(self, action: #selector(manualScroll), for: .valueChanged)
        tabBar.backgroundColor = .white

        tabBar.snp.makeConstraints { make in
            make.height.equalTo(30)
        }

        tabBarStack = UIStackView(arrangedSubviews: [headerContainer, tabBar])
        tabBarStack.bringSubview(toFront: headerContainer)
        tabBarStack.axis = .vertical
        view.addSubview(tabBarStack)
        view.bringSubview(toFront: tabBarStack)
    }

    private func createMenuStack() {
        menuItemsView = ExpandedMenuItemView(frame: .zero, eatery: eatery, views: categoryViews, allMenuItems: allItems)
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
        don't do this, the tabBarStack will scroll unevenly with the rest of the scroll view.  */
    @objc func manualScroll() {
        let minOffset: CGFloat = 4
        let currentPos = scrollView?.contentOffset.y ?? 0
        let viewControllerPosOnParent = view.frame.origin.y
        let viewPos = categoryViews[tabBar.selectedSegmentIndex].frame.minY
        let targetPos = viewPos - scrollOffset + viewControllerPosOnParent + minOffset
        let topOfSelf = viewControllerPosOnParent - scrollOffset
        let duration = animationDuration(from: currentPos, to: targetPos, withConst: 0.01)

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

            UIView.animate(
                withDuration: firstDuration,
                delay: 0,
                options: .curveEaseIn,
                animations: {
                    self.scrollView?.contentOffset.y = viewControllerPosOnParent - self.scrollOffset
                }, completion: { completed in
                    if completed {
                        UIView.animate(withDuration: secondDuration, delay: 0, options: .curveEaseOut) {
                            self.scrollView?.contentOffset.y = targetPos
                        }
                    }
                }
            )

        }
    }

    /*  This function helps scroll animations look more proportional.  However, smaller distances should travel
        slower, proportionally, compared to larger distances.  That's why this function is logarithmic rather
        than linear.  If it were linear, shorter scrolls would look too short and choppy.   */
    private func animationDuration(from cur: CGFloat, to target: CGFloat, withConst propConstant: CGFloat) -> Double {
        let distance = fabs(cur - target)

        // Prop constant should be less than 0.1 because distances a scroll travels can be in the thousands. In
        // a practical worst case, we would have to scroll 5000 pixels. (ln(5000))^2 = 72 = 72.5 which is WAY too
        // long for an animation. Setting propConstant < 0.1 would make this more reasonable.
        return Double(log(distance) * log(distance) * propConstant)
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
        var selectionIndex = 0
        var testIndex = 1
        let viewControllerPosOnParent = view.frame.origin.y
        let currentPos = (scrollView?.contentOffset.y ?? 0) + scrollOffset - viewControllerPosOnParent

        while (testIndex - selectionIndex == 1) && testIndex < categoryViews.count {

            if currentPos > categoryViews[testIndex].frame.minY {
                selectionIndex = testIndex
            }
            testIndex += 1
        }

        tabBar.select(at: selectionIndex)
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categoryViews.forEach { categoryView in
            categoryView.reload()
        }
    }

}
