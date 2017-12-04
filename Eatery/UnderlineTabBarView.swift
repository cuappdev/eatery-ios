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

private let kUnderlineHeight: CGFloat = 2

class UnderlineTabBarView: UIView, TabbedPageViewControllerDelegate {
    
    weak var delegate: TabBarDelegate?

    var stackView: UIStackView!
    var tabButtons: [UIButton] = []
    var underlineView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
    }
    
    func setUp(_ sections: [String]) {
        tabButtons = sections.map { section -> UIButton in
            let tabButton = UIButton()
            tabButton.setTitle(section.uppercased(), for: UIControlState())
            tabButton.setTitleColor(.offBlack, for: UIControlState())
            tabButton.setTitleColor(.eateryBlue, for: .selected)
            tabButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
            tabButton.addTarget(self, action: #selector(UnderlineTabBarView.tabButtonPressed(_:)), for: .touchUpInside)
            tabButton.sizeToFit()
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
        underlineView.backgroundColor = UIColor.eateryBlue
        addSubview(underlineView)
        
        tabButtons.first?.isSelected = true
        underline(at: 0)
    }
    
    func underline(at index: Int) {
        let button = tabButtons[index]

        underlineView.snp.remakeConstraints { make in
            make.bottom.equalToSuperview().inset(kUnderlineHeight)
            make.width.equalTo(button)
            make.centerX.equalTo(button)
            make.height.equalTo(kUnderlineHeight)
        }
    }
    
    func updateSelectedTabAppearance(_ newIndex: Int) {
        underline(at: newIndex)

        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
            for tab in self.tabButtons {
                tab.isSelected = false
            }
            self.tabButtons[newIndex].isSelected = true
        }
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
