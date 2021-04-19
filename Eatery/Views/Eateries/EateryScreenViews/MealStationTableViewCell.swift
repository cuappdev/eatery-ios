//
//  MealStationTableViewCell.swift
//  Eatery
//
//  Created by Eric Appel on 5/6/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import SnapKit
import UIKit

class MealStationTableViewCell: UITableViewCell {

    let titleLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.trailing.equalToSuperview().inset(10)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

}

class MealStationItemTableViewCell: UITableViewCell {

    let contentLabel = UILabel()
    private let favoritedStatus = UIImageView()

    let seperator = UIView()

    var favorited = false {
        didSet {
            favoritedStatus.image = favorited ? .favoritedImage : .unfavoritedImage
            favoritedStatus.tintColor = favorited ? .favoriteYellow : .lightGray
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        favoritedStatus.image = .unfavoritedImage
        favoritedStatus.tintColor = .lightGray
        favoritedStatus.contentMode = .scaleAspectFill
        addSubview(favoritedStatus)
        favoritedStatus.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(EateriesViewController.collectionViewMargin)
            make.bottom.top.equalToSuperview().inset(5)
            make.height.width.lessThanOrEqualTo(20)
        }

        contentLabel.numberOfLines = 0
        contentLabel.font = .systemFont(ofSize: 14)
        contentLabel.textColor = .lightGray
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(favoritedStatus.snp.trailing).offset(10)
            make.bottom.equalToSuperview()
        }

        seperator.backgroundColor = .separator
        addSubview(seperator)
        seperator.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(EateriesViewController.collectionViewMargin)
            make.height.equalTo(1)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

}
