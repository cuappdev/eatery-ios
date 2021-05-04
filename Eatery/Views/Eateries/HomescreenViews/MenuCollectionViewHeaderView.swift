//
//  MenuCollectionViewHeaderView.swift
//  Eatery
//
//  Created by Noah Pikielny on 4/19/21.
//  Copyright © 2021 Cornell AppDev. All rights reserved.
//

import UIKit

class MenuCollectionViewHeaderView: UICollectionReusableView {

    let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(EateriesViewController.collectionViewMargin)
            make.top.equalToSuperview().inset(14)
            make.bottom.equalToSuperview().inset(8)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

}
