//
//  AppIconTableViewCell.swift
//  Eatery
//
//  Created by William Ma on 4/15/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import UIKit

class AppIconTableViewCell: UITableViewCell {

    private let appImageView = UIImageView()
    private let titleLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        appImageView.clipsToBounds = true
        appImageView.layer.cornerRadius = 11 // eyeballed
        appImageView.layer.borderWidth = 0.5
        appImageView.layer.borderColor = UIColor.separator.cgColor
        if #available(iOS 13.0, *) {
            appImageView.layer.cornerCurve = .continuous
        }

        contentView.addSubview(appImageView)
        appImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.bottom.equalToSuperview().inset(8)
            make.width.height.equalTo(44)
        }

        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(appImageView.snp.trailing).offset(8)
            make.top.bottom.equalToSuperview().inset(8)
            make.trailing.equalToSuperview().inset(20)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(icon: UIImage?, title: String) {
        appImageView.image = icon
        titleLabel.text = title
    }

}
