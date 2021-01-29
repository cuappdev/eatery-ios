//
//  ExpandedHeaderContainer.swift
//  Eatery
//
//  Created by Sergio Diaz on 1/27/21.
//  Copyright © 2021 Cornell AppDev. All rights reserved.
//

import UIKit

class ExpandedHeaderContainer: UIView {

    private var filterButton: ExpandedFilterButton!
    private var filterLabel: UILabel!
    private var separatorView: SeparatorView!

    private let tabBarPadding: CGFloat = 16

    override init(frame: CGRect) {
        super.init(frame: frame)

        let titleLabel = UILabel()
        titleLabel.text = "Menu"
        titleLabel.textColor = .black
        titleLabel.font = .boldSystemFont(ofSize: 26)
        titleLabel.preservesSuperviewLayoutMargins = true
        addSubview(titleLabel)

        filterButton = ExpandedFilterButton(frame: .zero, inactiveColor: .systemGray, activeColor: .eateryBlue)
        filterButton.preservesSuperviewLayoutMargins = true
        addSubview(filterButton)

        filterLabel = UILabel()
        filterLabel.textColor = .eateryBlue
        filterLabel.font = .boldSystemFont(ofSize: 11)
        filterLabel.text = ""
        filterLabel.preservesSuperviewLayoutMargins = true
        addSubview(filterLabel)

        separatorView = SeparatorView(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        separatorView.tintColor = .clear
        separatorView.isHidden = true
        addSubview(separatorView)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(tabBarPadding)
            make.centerY.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        filterButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.height.equalTo(titleLabel.snp.height).multipliedBy(0.3)
            make.trailing.equalToSuperview().offset(-tabBarPadding)
            make.width.equalTo(filterButton.snp.height).multipliedBy(1.7)
        }

        filterLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.trailing.equalTo(filterButton.snp.leading).offset(-6)
        }

        separatorView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Describe why you did this here
    func addFilterButtonTarget(_ target: Any?, action: Selector, forEvent: UIControlEvents) {
        filterButton.addTarget(target, action: action, for: forEvent)
    }

    func filterButtonPressed() {
        filterButton.pressed()
    }

    func getFilterButtonState() -> ExpandedFilterButtonState {
        filterButton.filterState
    }

    func setFilterLabelText(to text: String) {
        filterLabel.text = text
    }

    func setSeparatorViewHidden(to hidden: Bool) {
        separatorView.isHidden = hidden
    }
}
