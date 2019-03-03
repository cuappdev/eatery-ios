//
//  DescriptionTableViewCell.swift
//  Eatery
//
//  Created by William Ma on 3/2/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class DescriptionTableViewCell: UITableViewCell {

    let textView = UITextView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = false
        textView.font = .preferredFont(forTextStyle: .body)
        contentView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

}
