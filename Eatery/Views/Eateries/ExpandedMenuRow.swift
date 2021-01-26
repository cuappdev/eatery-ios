//
//  MenuRow.swift
//  Eatery
//
//  Created by Sergio Diaz on 11/18/20.
//  Copyright © 2020 Cornell AppDev. All rights reserved.
//

import UIKit

class ExpandedMenuRow: UIView {

    var itemLabel: UILabel!
    var priceLabel: UILabel!
    var item: ExpandedMenu.Item!

    let padding: CGFloat = 15

    let leadPadding: CGFloat = 15
    let trailPadding: CGFloat = -15
    let lineOffset: CGFloat = 2

    init(item: ExpandedMenu.Item, hasSeparator: Bool) {
        super.init(frame: .zero)

        let separator = UIView()
        separator.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.06)
        addSubview(separator)

        separator.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(padding - lineOffset)
            make.trailing.equalToSuperview().offset(-padding + lineOffset)
        }

        self.item = item
        itemLabel = UILabel()
        itemLabel.text = item.name
        itemLabel.textColor = .black
        itemLabel.font = UIFont.systemFont(ofSize: 15)
        itemLabel.sizeToFit() // potential issue
        addSubview(itemLabel)

        itemLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(leadPadding)
        }

        priceLabel = UILabel()
        priceLabel.text = getPriceString()
        priceLabel.textColor = .lightGray
        priceLabel.font = UIFont.systemFont(ofSize: 15)
        priceLabel.sizeToFit()
        addSubview(priceLabel)

        priceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(trailPadding)
        }

        self.snp.makeConstraints { make in
            make.height.equalTo(CampusEateryExpandedMenuViewController.heightConst)
        }

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func getPriceString() -> String {
        item.priceString.replacingOccurrences(of: "/", with: " | ")
    }

}
