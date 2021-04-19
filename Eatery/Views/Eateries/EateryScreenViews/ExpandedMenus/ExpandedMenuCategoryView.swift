//
//  CampusEateryExtendedMenuViewController.swift
//  Eatery
//
//  Created by Sergio Diaz on 12/20/20.
//  Copyright © 2020 Cornell AppDev. All rights reserved.
//

import UIKit

class ExpandedMenuCategoryView: UIView {

    let eatery: CampusEatery!
    let category: String!
    let menu: [ExpandedMenu.Item]!

    /// Public variable that allows other VCs to easily get height of this view
    var contentHeight: CGFloat = 0
    
    private var stackView: UIStackView?
    
    init(eatery: CampusEatery, category: String, menu: [ExpandedMenu.Item]) {
        self.eatery = eatery
        self.category = category
        self.menu = menu

        super.init(frame: .zero)

        var itemViews: [UIView] = []

        for item in menu {
            let menuRow = ExpandedMenuRow(item: item)
            contentHeight += ExpandedMenuRow.heightConst
            itemViews.append(menuRow)
        }

        let stackView = UIStackView(arrangedSubviews: itemViews)
        stackView.spacing = 0
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.stackView = stackView

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension ExpandedMenuCategoryView: Reloadable {
    func reload() {
        guard let stackView = stackView else { return }
        stackView.subviews.forEach { view in
            if let expandedMenuRow = view as? ExpandedMenuRow {
                expandedMenuRow.checkFavorite()
            }
        }
    }
}
