//
//  NavigationtitleView.swift
//  Eatery
//
//  Created by Kevin Greer on 4/24/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import SnapKit
import UIKit

class NavigationTitleView: UIView {
    
    let eateryNameLabel = UILabel()

    private var nameLabelHeightConstraint: NSLayoutConstraint
    var nameLabelHeight: CGFloat? {
        get {
            if nameLabelHeightConstraint.isActive {
                return nameLabelHeightConstraint.constant
            } else {
                return nil
            }
        }
        set {
            if let constant = newValue {
                nameLabelHeightConstraint.isActive = true
                nameLabelHeightConstraint.constant = constant
            } else {
                nameLabelHeightConstraint.isActive = false
            }
        }
    }

    let dateLabel = UILabel()

    private var dateLabelWidthConstraint: NSLayoutConstraint
    var dateLabelWidth: CGFloat? {
        get {
            if dateLabelWidthConstraint.isActive {
                return dateLabelWidthConstraint.constant
            } else {
                return nil
            }
        }
        set {
            if let constant = newValue {
                dateLabelWidthConstraint.isActive = true
                dateLabelWidthConstraint.constant = constant
            } else {
                dateLabelWidthConstraint.isActive = false
            }
        }
    }

    override init(frame: CGRect) {
        nameLabelHeightConstraint = eateryNameLabel.heightAnchor.constraint(equalToConstant: 0)
        nameLabelHeightConstraint.isActive = true
        dateLabelWidthConstraint = dateLabel.widthAnchor.constraint(equalToConstant: 0)
        dateLabelWidthConstraint.isActive = false

        super.init(frame: frame)

        backgroundColor = .clear

        eateryNameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        eateryNameLabel.minimumScaleFactor = 0.5
        eateryNameLabel.adjustsFontSizeToFitWidth = true
        eateryNameLabel.textColor = .white
        addSubview(eateryNameLabel)
        eateryNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.leading.trailing.equalToSuperview()
        }

        dateLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        dateLabel.minimumScaleFactor = 0.1
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.textColor = .white
        dateLabel.textAlignment = .center
        addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(eateryNameLabel.snp.bottom)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(4)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

}
