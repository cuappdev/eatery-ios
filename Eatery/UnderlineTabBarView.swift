//
//  UnderlineTabBarView.swift
//  Eatery
//
//  Created by Eric Appel on 11/4/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

protocol TabBarDelegate: class {
    func selectedTabDidChange(_ newIndex: Int)
}

private let kCornerRadius: CGFloat = 12.0

class UnderlineTabBarView: UIView, TabbedPageViewControllerDelegate {
    
    weak var delegate: TabBarDelegate?

    var stackView: UIStackView!
    var tabButtons: [UIButton] = []
    var underlineView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .lightBackgroundGray
        layer.cornerRadius = kCornerRadius
        clipsToBounds = true
    }
    
    func setUp(_ sections: [String]) {
        tabButtons = sections.map { section -> UIButton in
            let tabButton = UIButton()
            tabButton.setTitle(section, for: .normal)
            tabButton.setTitleColor(.eateryBlue, for: .normal)
            tabButton.setTitleColor(.white, for: .selected)
            tabButton.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
            tabButton.addTarget(self, action: #selector(UnderlineTabBarView.tabButtonPressed(_:)), for: .touchUpInside)
            tabButton.sizeToFit()
            tabButton.frame.size.height = frame.height
            return tabButton
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
        
        tabButtons.first?.isSelected = true
        underline(at: 0)
    }
    
    func underline(at index: Int) {
        let button = tabButtons[index]

        underlineView.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(button)
            make.centerX.equalTo(button)
        }
    }
    
    func updateSelectedTabAppearance(_ newIndex: Int) {
        underline(at: newIndex)

        for tab in self.tabButtons {
            tab.isSelected = false
            tab.isUserInteractionEnabled = true
        }
        self.tabButtons[newIndex].isSelected = true
        self.tabButtons[newIndex].isUserInteractionEnabled = false
    }
    
    @objc func tabButtonPressed(_ sender: UIButton) {
        let index = tabButtons.index(of: sender)!
        updateSelectedTabAppearance(index)
        delegate?.selectedTabDidChange(index)
    }
    
    func selectedTabDidChange(_ newIndex: Int) {
        updateSelectedTabAppearance(newIndex)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboards are not welcome here.")
    }

}
