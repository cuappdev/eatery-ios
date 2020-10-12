//
//  BRBBalanceTableViewCell.swift
//  Eatery
//
//  Created by William Ma on 9/2/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class BRBBalanceTableViewCell: UITableViewCell {

    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel = UILabel(frame: .zero)
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(20)
        }

        subtitleLabel = UILabel(frame: .zero)
        subtitleLabel.font = .preferredFont(forTextStyle: .body)
        subtitleLabel.textColor = .gray
        subtitleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        contentView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(20)
            make.leading.equalTo(titleLabel.snp.trailing)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

}
