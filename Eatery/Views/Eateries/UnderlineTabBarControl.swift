//
//  UnderlineTabBarControl.swift
//  Eatery
//
//  Created by William Ma on 10/2/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

// MARK: -

class UnderlineTabBarControl: UIControl {

    private var stackView: UIStackView!
    private var tabButtons: [UIButton] = []
    private var underlineView: UIView!

    var selectedSegmentIndex = 0

    init(sections: [String]) {
        super.init(frame: .zero)

        backgroundColor = .wash
        layer.cornerRadius = 12
        clipsToBounds = true

        for section in sections {
            let tabButton = UIButton()
            tabButton.setTitle(section, for: .normal)
            tabButton.setTitleColor(.eateryBlue, for: .normal)
            tabButton.setTitleColor(.white, for: .selected)
            tabButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
            tabButton.addTarget(self, action: #selector(tabButtonPressed(_:)), for: .touchUpInside)
            tabButton.sizeToFit()
            tabButton.frame.size.height = frame.height
            tabButtons.append(tabButton)
        }

        stackView = UIStackView(arrangedSubviews: tabButtons)
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Underline
        underlineView = UIView()
        underlineView.backgroundColor = .eateryBlue
        insertSubview(underlineView, belowSubview: stackView)

        underline(at: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func underline(at index: Int) {
        selectedSegmentIndex = index

        let button = tabButtons[index]

        underlineView.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(button)
            make.centerX.equalTo(button)
        }

        for tab in tabButtons {
            tab.isSelected = false
            tab.isUserInteractionEnabled = true
        }
        tabButtons[index].isSelected = true
        tabButtons[index].isUserInteractionEnabled = false
    }

    @objc private func tabButtonPressed(_ sender: UIButton) {
        guard let index = tabButtons.firstIndex(of: sender) else {
            return
        }

        underline(at: index)
        sendActions(for: .valueChanged)
    }

}
