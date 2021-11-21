//
//  ExpandedHeaderContainer.swift
//  Eatery
//
//  Created by Sergio Diaz on 1/27/21.
//  Copyright © 2021 Cornell AppDev. All rights reserved.
//

import UIKit

class ExpandedHeaderContainer: UIView {

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

        separatorView = SeparatorView(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        separatorView.tintColor = .clear
        separatorView.isHidden = true
        addSubview(separatorView)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(tabBarPadding)
            make.centerY.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        separatorView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setSeparatorViewHidden(to hidden: Bool) {
        separatorView.isHidden = hidden
    }
}
