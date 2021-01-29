//
//  ExpandedMenuItemsView.swift
//  Eatery
//
//  Created by Sergio Diaz on 1/27/21.
//  Copyright © 2021 Cornell AppDev. All rights reserved.
//

import UIKit

enum MenuStackType {
    case original, highToLow, lowToHigh
}

class ExpandedMenuItemView: UIView {

    private var menuItemsStack: UIStackView!
    private var menuItemsHighToLowStack: UIStackView?
    private var menuItemsLowToHighStack: UIStackView?

    private var eatery: CampusEatery!
    private var allMenuItems: [ExpandedMenu.Item]!

    init(frame: CGRect, eatery: CampusEatery, views: [UIView], allMenuItems: [ExpandedMenu.Item]) {
        super.init(frame: frame)

        self.eatery = eatery
        self.allMenuItems = allMenuItems

        menuItemsStack = UIStackView(arrangedSubviews: views)
        menuItemsStack.axis = .vertical
        addSubview(menuItemsStack)

        menuItemsStack.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(5)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Explain these too
    func createHighToLowStack() {
        // Items are reversed since this is the high to low stack, but elements are sorted from low to high
        let reversedItems = Array(allMenuItems.reversed())
        let sortedVC = CampusEateryExpandedMenuViewController(eatery: eatery, category: "", menu: reversedItems)

        menuItemsHighToLowStack = UIStackView(arrangedSubviews: [sortedVC.view])
        if let menuItemsHighToLowStack = menuItemsHighToLowStack {
            menuItemsHighToLowStack.axis = .vertical
            addSubview(menuItemsHighToLowStack)
            menuItemsHighToLowStack.isHidden = true

            menuItemsHighToLowStack.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }

    func createLowToHighStack() {
        let sortedVC = CampusEateryExpandedMenuViewController(eatery: eatery, category: "", menu: allMenuItems)

        menuItemsLowToHighStack = UIStackView(arrangedSubviews: [sortedVC.view])
        if let menuItemsLowToHighStack = menuItemsLowToHighStack {
            menuItemsLowToHighStack.axis = .vertical
            addSubview(menuItemsLowToHighStack)
            menuItemsLowToHighStack.isHidden = true

            menuItemsLowToHighStack.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }

    func switchVisibleStack(type: MenuStackType) {
        switch type {
        case .original:
            menuItemsStack.isHidden = false
            menuItemsLowToHighStack!.isHidden = true
        case .highToLow:
            menuItemsStack.isHidden = true
            menuItemsHighToLowStack!.isHidden = false
        case .lowToHigh:
            menuItemsHighToLowStack!.isHidden = true
            menuItemsLowToHighStack!.isHidden = false
        }
    }

    func getOriginalMaxY() -> CGFloat {
        menuItemsStack.frame.maxY
    }

}
