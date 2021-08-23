//
//  BRBLoginTableViewCell.swift
//  Eatery
//
//  Created by Noah Pikielny on 8/23/21.
//  Copyright © 2021 Cornell AppDev. All rights reserved.
//

import NVActivityIndicatorView
import UIKit

class BRBLoginTableViewCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    func configure(stackView: UIStackView) {
        stackView.removeFromSuperview()
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
