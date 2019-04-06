//
//  HoursTableViewCell.swift
//  Eatery
//
//  Created by Gonzalo Gonzalez on 4/5/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class HoursTableViewCell: UITableViewCell {

    var dayLabel: UILabel!
    var hourLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        dayLabel = UILabel()
        dayLabel.font = .systemFont(ofSize: 14, weight: .medium)
        //dayLabel.sizeToFit()
        dayLabel.text = "Wed:"
        contentView.addSubview(dayLabel)
        
        hourLabel = UILabel()
        hourLabel.font = .systemFont(ofSize: 14, weight: .medium)
        hourLabel.textColor = .gray
        //hourLabel.sizeToFit()
        hourLabel.text = "7:30AM - 2:00AM"
        contentView.addSubview(hourLabel)
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - CONSTRAINTS
    func setupConstraints() {
        
        dayLabel.snp.updateConstraints {make in
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(16)
            make.width.equalTo(42)
        }
        
        hourLabel.snp.updateConstraints {make in
            make.top.height.equalTo(dayLabel)
            make.leading.equalTo(dayLabel.snp.trailing).offset(19)
            make.trailing.lessThanOrEqualToSuperview()
        }
        
    }
}
