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

    private var collapseTitleLabelConstraint: Constraint?
    var titleCollapsed: Bool {
        get { collapseTitleLabelConstraint?.isActive ?? false }
        set { collapseTitleLabelConstraint?.isActive = newValue }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.trailing.equalToSuperview().inset(10)
        }

        collapseTitleLabelConstraint = titleLabel.snp.prepareConstraints({ make in
            make.height.equalTo(0)
        }).first
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

}

class MealStationItemTableViewCell: UITableViewCell {

    let contentLabel = UILabel()

    let favoritedStatus = UIImageView()

    let favoritedImage = UIImage(named: "goldStar")
    let unfavoritedImage = UIImage(named: "unselected")

    var favorited: Bool = false {
        didSet {
            favoritedStatus.image = favorited ? favoritedImage : unfavoritedImage
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        favoritedStatus.image = unfavoritedImage
        favoritedStatus.tintColor = .favoriteYellow
        favoritedStatus.contentMode = .scaleAspectFill
        addSubview(favoritedStatus)
        favoritedStatus.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(5)
            make.top.equalToSuperview().inset(5)
            make.height.lessThanOrEqualTo(15)
            make.width.lessThanOrEqualTo(15)
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

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

}
