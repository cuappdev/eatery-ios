//
//  LookAheadHeaderView.swift
//  Eatery
//
//  Created by Annie Cheng on 11/28/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

class LookAheadHeaderView: UITableViewHeaderFooterView {

    private let titleLabel = UILabel()
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(5)
            make.leading.trailing.equalToSuperview().inset(10)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
