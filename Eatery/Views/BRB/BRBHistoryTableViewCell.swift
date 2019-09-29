//
//  BRBHistoryTableViewCell.swift
//  Eatery
//
//  Created by William Ma on 9/2/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class BRBHistoryTableViewCell: UITableViewCell {

    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!
    private var priceLabel: UILabel!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(12)
        }
        
        subtitleLabel = UILabel(frame: .zero)
        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .gray
        contentView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(12)
        }
        
        priceLabel = UILabel(frame: .zero)
        priceLabel.textColor = .eateryRed
        priceLabel.font = .preferredFont(forTextStyle: .body)
        priceLabel.setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview().inset(12)
            make.leading.equalTo(titleLabel.snp.trailing)
            make.leading.equalTo(subtitleLabel.snp.trailing)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, subtitle: String, amount: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        priceLabel.text = "-$\(amount)"
    }
    
}
