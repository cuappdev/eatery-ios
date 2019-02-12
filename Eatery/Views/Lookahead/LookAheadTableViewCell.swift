//
//  LookAheadTableViewCell.swift
//  Eatery
//
//  Created by William Ma on 2/12/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import SnapKit
import UIKit

class LookAheadTableViewCell: UITableViewCell {

    private static let upArrow = UIImage(named: "upArrow.png")
    private static let downArrow = UIImage(named: "downArrow.png")

    private let eateryNameLabel = UILabel()
    var eateryName: String? {
        get { return eateryNameLabel.text }
        set { eateryNameLabel.text = newValue }
    }

    private let eateryStatusLabel = UILabel()
    var eateryStatus: String? {
        get { return eateryStatusLabel.text }
        set { eateryStatusLabel.text = newValue }
    }
    var eateryStatusColor: UIColor? {
        get { return eateryStatusLabel.textColor }
        set { eateryStatusLabel.textColor = newValue }
    }

    private let eateryHoursLabel = UILabel()
    var eateryHours: String? {
        get { return eateryHoursLabel.text }
        set { eateryHoursLabel.text = newValue }
    }
    var eateryHoursColor: UIColor? {
        get { return eateryHoursLabel.textColor }
        set { eateryHoursLabel.textColor = newValue }
    }

    private let moreInfoIndicatorImageView = UIImageView()
    var moreInfoIndicatorIsHidden: Bool {
        get { return moreInfoIndicatorImageView.isHidden }
        set { moreInfoIndicatorImageView.isHidden = newValue }
    }

    private let menuView = LookAheadMenuView()
    var menu: [(Eatery.MenuCategory, [String])] {
        get { return menuView.menu }
        set { menuView.menu = newValue }
    }

    private var collapseMenuViewConstraints = [Constraint]()
    private var expandMenuViewConstraints = [Constraint]()

    var isExpanded = false {
        didSet {
            moreInfoIndicatorImageView.image =
                isExpanded ? LookAheadTableViewCell.upArrow : LookAheadTableViewCell.downArrow

            if isExpanded {
                expandMenuView()
            } else {
                collapseMenuView()
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        clipsToBounds = true
        selectionStyle = .none

        let eateryInfoContainer = UIView()
        contentView.addSubview(eateryInfoContainer)
        eateryInfoContainer.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }

        eateryNameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        eateryNameLabel.setContentHuggingPriority(.required, for: .vertical)
        eateryNameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        eateryInfoContainer.addSubview(eateryNameLabel)
        eateryNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(13)
            make.leading.equalToSuperview().inset(10)
        }

        eateryStatusLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        eateryStatusLabel.setContentHuggingPriority(.required, for: .vertical)
        eateryStatusLabel.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
        eateryStatusLabel.font = .systemFont(ofSize: 12, weight: .medium)
        eateryInfoContainer.addSubview(eateryStatusLabel)
        eateryStatusLabel.snp.makeConstraints { make in
            make.top.equalTo(eateryNameLabel.snp.bottom)
            make.leading.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(12)
        }

        eateryHoursLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        eateryHoursLabel.setContentHuggingPriority(.required, for: .vertical)
        eateryHoursLabel.font = eateryStatusLabel.font
        eateryInfoContainer.addSubview(eateryHoursLabel)
        eateryHoursLabel.snp.makeConstraints { make in
            make.top.equalTo(eateryNameLabel.snp.bottom)
            make.leading.equalTo(eateryStatusLabel.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(10)
        }

        moreInfoIndicatorImageView.contentMode = .scaleAspectFit
        moreInfoIndicatorImageView.image = LookAheadTableViewCell.upArrow
        eateryInfoContainer.addSubview(moreInfoIndicatorImageView)
        moreInfoIndicatorImageView.snp.makeConstraints { make in
            make.trailing.equalTo(eateryInfoContainer.snp.trailingMargin).inset(8)
            make.width.equalTo(16)
            make.height.equalTo(10)
            make.centerY.equalToSuperview()
            make.leading.equalTo(eateryNameLabel.snp.trailing).inset(8)
        }

        let menuViewLayoutGuide = UILayoutGuide()
        contentView.addLayoutGuide(menuViewLayoutGuide)
        menuViewLayoutGuide.snp.makeConstraints { make in
            make.top.equalTo(eateryInfoContainer.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        menuView.setContentCompressionResistancePriority(.required, for: .vertical)
        contentView.addSubview(menuView)
        menuView.snp.makeConstraints { make in
            make.top.equalTo(eateryInfoContainer.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        collapseMenuViewConstraints = menuViewLayoutGuide.snp.prepareConstraints { make in
            make.height.equalTo(0).priority(.high)
        }
        expandMenuViewConstraints = menuViewLayoutGuide.snp.prepareConstraints { make in
            make.height.equalTo(menuView.snp.height).priority(.high)
        }

        collapseMenuView()
    }

    private func expandMenuView() {
        for constraint in collapseMenuViewConstraints {
            constraint.deactivate()
        }
        for constraint in expandMenuViewConstraints {
            constraint.activate()
        }
    }

    private func collapseMenuView() {
        for constraint in expandMenuViewConstraints {
            constraint.deactivate()
        }
        for constraint in collapseMenuViewConstraints {
            constraint.activate()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

}
