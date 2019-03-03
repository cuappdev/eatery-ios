//
//  LogoutTableViewCell.swift
//  Eatery
//
//  Created by William Ma on 3/2/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class LogoutTableViewCell: UITableViewCell {

    let logoutLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        logoutLabel.textColor = .eateryBlue
        logoutLabel.text = "Logout"
        logoutLabel.textAlignment = .center
        contentView.addSubview(logoutLabel)
        logoutLabel.snp.makeConstraints { make in
            make.edges.equalTo(contentView.snp.margins).inset(4)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

}
