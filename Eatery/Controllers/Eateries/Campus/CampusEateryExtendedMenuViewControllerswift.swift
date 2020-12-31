//
//  CampusEateryExtendedMenuViewController.swift
//  Eatery
//
//  Created by Sergio Diaz on 12/20/20.
//  Copyright © 2020 Cornell AppDev. All rights reserved.
//

import UIKit

class CampusEateryExtendedMenuViewController: UIViewController {

    let meal: String
    let eatery: CampusEatery
    let menu: Menu?
    var contentHeight: CGFloat = 0

    var stackView: UIStackView!
    var itemViews: [UIView] = []

    static let heightConst: CGFloat = 44

    init(eatery: CampusEatery, meal: String) {
        self.eatery = eatery
        self.meal = meal

        self.menu = eatery.getMenu(meal: meal, onDayOf: Date())

        super.init(nibName: nil, bundle: nil)
    }

    init(eatery: CampusEatery, meal: String, val: Bool) {
        self.eatery = eatery
        self.meal = meal

        self.menu = HARDCODE.getRandomMenu()

        super.init(nibName: nil, bundle: nil)
    }

    init(eatery: CampusEatery, val: Bool, menu: Menu) {
        self.eatery = eatery
        self.meal = ""
        self.menu = menu

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        var itemValues: [[Menu.Item]] = []

        if let localMenu = self.menu {
            itemValues = localMenu.data.map { (_, values) in
                return values
            }
        }

        let simpleItemValues: [Menu.Item] = Array(itemValues.joined())

        for i in 0..<simpleItemValues.count {
            let hasSeparator = i == (simpleItemValues.count - 1) ? false : true
            let menuRow = ExtendedMenuRow(item: simpleItemValues[i], hasSeparator: hasSeparator)
            contentHeight += CampusEateryExtendedMenuViewController.heightConst

            itemViews.append(menuRow)
        }

        stackView = UIStackView(arrangedSubviews: itemViews)
        stackView.spacing = 0
        stackView.axis = .vertical
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

    }

}
