//
//  SwitchTableViewCell.swift
//  Eatery
//
//  Created by William Ma on 3/2/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {

    let switchControl = UISwitch()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(switchControl)
        switchControl.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.top.greaterThanOrEqualToSuperview().inset(8)
            make.bottom.lessThanOrEqualToSuperview().inset(8)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

}
