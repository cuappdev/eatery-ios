//
//  CampusEateryExtendedMenuViewController.swift
//  Eatery
//
//  Created by Sergio Diaz on 12/20/20.
//  Copyright © 2020 Cornell AppDev. All rights reserved.
//

import UIKit

class CampusEateryExpandedMenuViewController: UIViewController {

    let eatery: CampusEatery
    let category: String
    let menu: [ExpandedMenu.Item]

    var contentHeight: CGFloat = 0
    static let heightConst: CGFloat = 44

    init(eatery: CampusEatery, category: String, menu: [ExpandedMenu.Item]) {
        self.eatery = eatery
        self.category = category
        self.menu = menu

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        var itemViews: [UIView] = []

        for i in 0..<menu.count {
            let menuRow = ExpandedMenuRow(item: menu[i])
            contentHeight += CampusEateryExpandedMenuViewController.heightConst
            itemViews.append(menuRow)
        }

        let stackView = UIStackView(arrangedSubviews: itemViews)
        stackView.spacing = 0
        stackView.axis = .vertical
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}
