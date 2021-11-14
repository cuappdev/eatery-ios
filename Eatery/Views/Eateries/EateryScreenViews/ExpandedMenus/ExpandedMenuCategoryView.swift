//
//  ExpandedMenuCategoryView.swift
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
    let categoryLabel: UILabel!

    /// Public variable that allows other VCs to easily get height of this view
    var contentHeight: CGFloat = 0

    private var stackView: UIStackView

    init(eatery: CampusEatery, category: String, menu: [ExpandedMenu.Item]) {
        self.eatery = eatery
        self.category = category
        self.menu = menu

        var itemViews: [UIView] = []

        for item in menu {
            let menuRow = ExpandedMenuRow(item: item)
            contentHeight += ExpandedMenuRow.heightConst
            itemViews.append(menuRow)
        }

        stackView = UIStackView(arrangedSubviews: itemViews)
        stackView.spacing = 0
        stackView.axis = .vertical

        categoryLabel = UILabel()
        categoryLabel.text = category
        categoryLabel.font = .systemFont(ofSize: 18)

        super.init(frame: .zero)
        backgroundColor = .white

        addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview()
        }

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reload() {
        for case let view as ExpandedMenuRow in subviews {
            view.checkFavorite()
        }
    }

}
