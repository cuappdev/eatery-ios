//
//  MealItemTableViewCell.swift
//  Eatery
//
//  Created by William Ma on 10/24/18.
//  Copyright © 2018 CUAppDev. All rights reserved.
//

import UIKit

class MealItemTableViewCell: UITableViewCell {

    var nameLabel: UILabel

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        nameLabel = UILabel(frame: .zero)

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        isUserInteractionEnabled = true

        nameLabel.font = UIFont.systemFont(ofSize: 14)
        nameLabel.textColor = UIColor.darkGray
        addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.snp.makeConstraints { make in
            make.edges.equalTo(self).inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
