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
        menuItemsStack.spacing = 8
        menuItemsStack.backgroundColor = .wash
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

    func createHighToLowStackIfNeeded() {
        guard menuItemsHighToLowStack == nil else { return }

        // Items are reversed since this is the high to low stack, but elements are sorted from low to high
        let reversedItems = Array(allMenuItems.reversed())
        let sortedVC = ExpandedMenuCategoryView(eatery: eatery, category: "", menu: reversedItems)

        let highToLowStack = UIStackView(arrangedSubviews: [sortedVC])
        highToLowStack.axis = .vertical
        addSubview(highToLowStack)
        highToLowStack.isHidden = true

        highToLowStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        menuItemsHighToLowStack = highToLowStack
    }

    func createLowToHighStackIfNeeded() {
        guard menuItemsLowToHighStack == nil else { return }

        let sortedVC = ExpandedMenuCategoryView(eatery: eatery, category: "", menu: allMenuItems)

        let lowToHighStack = UIStackView(arrangedSubviews: [sortedVC])
        lowToHighStack.axis = .vertical
        addSubview(lowToHighStack)
        lowToHighStack.isHidden = true

        lowToHighStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        menuItemsLowToHighStack = lowToHighStack
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
