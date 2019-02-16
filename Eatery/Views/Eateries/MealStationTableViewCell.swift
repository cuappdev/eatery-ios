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
        get { return collapseTitleLabelConstraint?.isActive ?? false }
        set { collapseTitleLabelConstraint?.isActive = newValue }
    }

    let contentLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.trailing.equalToSuperview().inset(10)
        }

        contentLabel.numberOfLines = 0
        contentLabel.font = .systemFont(ofSize: 14)
        contentLabel.textColor = .lightGray
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview()
        }

        collapseTitleLabelConstraint = titleLabel.snp.prepareConstraints({ make in
            make.height.equalTo(0)
        }).first
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

}
