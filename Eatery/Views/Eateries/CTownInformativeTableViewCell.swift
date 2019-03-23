//
//  CTownInformativeTableViewCell.swift
//  Eatery
//
//  Created by Gonzalo Gonzalez on 3/16/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class CTownInformativeTableViewCell: UITableViewCell {

    var informativeTextLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        informativeTextLabel = UILabel()
        informativeTextLabel.font = .systemFont(ofSize: 14, weight: .medium)
        informativeTextLabel.textColor = .eateryBlue
        contentView.addSubview(informativeTextLabel)
        
        setupConstraints()

    }
    
    func setupConstraints(){
        informativeTextLabel.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
