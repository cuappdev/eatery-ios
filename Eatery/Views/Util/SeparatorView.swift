//
//  SeparatorView.swift
//  Eatery
//
//  Created by William Ma on 10/15/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class SeparatorView: UIView {

    private let separator = UIView()

    init(insets: UIEdgeInsets) {
        super.init(frame: .zero)

        separator.backgroundColor = .inactive

        addSubview(separator)
        separator.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(insets)
            make.height.equalTo(1)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
