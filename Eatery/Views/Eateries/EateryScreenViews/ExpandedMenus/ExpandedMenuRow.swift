//
//  ExpandedMenuRow.swift
//  Eatery
//
//  Created by Sergio Diaz on 11/18/20.
//  Copyright © 2020 Cornell AppDev. All rights reserved.
//

import SwiftyUserDefaults
import UIKit

class ExpandedMenuRow: UIView {

    private var itemLabel = UILabel()
    private var priceLabel = UILabel()
    private let favoritedStatus = UIImageView()
    private var favorited = false {
        didSet {
            DefaultsKeys.toggleFavoriteFood(item.name, favorited)
            didToggleFavorites()
        }
    }
    private func didToggleFavorites() {
        favoritedStatus.image = favorited ? .favoritedImage : .unfavoritedImage
        favoritedStatus.tintColor = favorited ? .favoriteYellow : .lightGray
    }
    func checkFavorite() {
        favorited = DefaultsKeys.isFavoriteFood(item.name)
    }

    private var item: ExpandedMenu.Item!

    private let padding: CGFloat = 15

    private let leadPadding: CGFloat = 15
    private let trailPadding: CGFloat = -15
    private let lineOffset: CGFloat = 2

    /// Constant used multiple times in codebase to get/set height of ExpandedMenuRows
    static let heightConst: CGFloat = 44

    @objc func toggleFavorites() {
        favorited.toggle()
    }

    init(item: ExpandedMenu.Item) {
        super.init(frame: .zero)

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleFavorites)))
        let separator = UIView()
        separator.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.06)
        addSubview(separator)

        separator.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(padding - lineOffset)
            make.trailing.equalToSuperview().offset(-padding + lineOffset)
        }

        favoritedStatus.contentMode = .scaleAspectFill
        favorited = DefaultsKeys.isFavoriteFood(item.name)
        toggleFavorites()

        addSubview(favoritedStatus)
        favoritedStatus.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(leadPadding)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
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
            make.leading.equalTo(favoritedStatus.snp.trailing).offset(leadPadding)
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
            make.height.equalTo(ExpandedMenuRow.heightConst)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func getPriceString() -> String {
        item.priceString.replacingOccurrences(of: "/", with: " | ")
    }

}
