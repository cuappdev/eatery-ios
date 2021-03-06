//
//  LookAheadMenuView.swift
//  Eatery
//
//  Created by William Ma on 2/15/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class LookAheadMenuView: UIView {

    private let textView = UITextView()

    var menu: Menu? = nil {
        didSet {
            if let menu = menu, !menu.data.isEmpty {
                computeMenuText()
            } else {
                computeNoMenuText()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .wash

        textView.backgroundColor = .wash
        textView.isSelectable = true
        textView.isEditable = false
        textView.isScrollEnabled = false
        addSubview(textView)
        textView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.trailing.equalToSuperview().inset(4)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

    private func computeNoMenuText() {
        let centerParagraph = NSMutableParagraphStyle()
        centerParagraph.alignment = .center

        let text = NSMutableAttributedString(string: "No Menu Available", attributes: [
            .paragraphStyle: centerParagraph,
            .font: UIFont.systemFont(ofSize: 18, weight: .bold)
        ])

        textView.attributedText = text
    }

    private func computeMenuText() {
        guard let menu = menu else {
            computeNoMenuText()
            return
        }

        let text = NSMutableAttributedString()
        let newline = NSAttributedString(string: "\n")

        for (offset: i, element: (key: category, value: items)) in menu.data.enumerated() {
            let categoryText = NSAttributedString(string: "\(category)", attributes: [
                .font: UIFont.systemFont(ofSize: 18, weight: .bold)
            ])
            text.append(categoryText)
            text.append(newline)

            for item in items {
                let itemText = NSAttributedString(string: "\(item.name)", attributes: [
                    .font: UIFont.systemFont(ofSize: 14),
                    .foregroundColor: UIColor.secondary
                ])
                text.append(itemText)
                text.append(newline)
            }

            if i < menu.data.count - 1 {
                text.append(newline)
            }
        }

        textView.attributedText = text
    }

}
