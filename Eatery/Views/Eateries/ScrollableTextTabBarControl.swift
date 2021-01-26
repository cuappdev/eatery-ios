//
//  ScrollableTextTabBarController.swift
//  Eatery
//
//  Created by Sergio Diaz on 11/11/20.
//  Copyright © 2020 Cornell AppDev. All rights reserved.
//

import UIKit
import SnapKit

class ScrollableTextTabBarControl: TabBar {

    let padding: CGFloat!
    let underlineOffset: CGFloat = 6

    init(sections: [String], padding: CGFloat = 0) {
        self.padding = padding
        super.init(sections: sections)

        for section in sections {
            let tabButton = UIButton()
            tabButton.setTitle(section, for: .normal)
            tabButton.setTitleColor(.gray, for: .normal)
            tabButton.titleLabel?.font = UIFont.systemFont(ofSize: 20.0, weight: .semibold)
            tabButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            tabButton.addTarget(self, action: #selector(tabButtonPressed(_:)), for: .touchUpInside)
            tabButton.frame.size.height = frame.height
            tabButton.clipsToBounds = true
            tabButton.sizeToFit()
            tabButtons.append(tabButton)
        }

        scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView = UIStackView(arrangedSubviews: tabButtons)
        stackView.spacing = 0
        stackView.axis = .horizontal
        stackView.backgroundColor = .white
        scrollView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(padding)
            make.top.bottom.trailing.equalToSuperview()
        }

        underlineView = UIView()
        underlineView.backgroundColor = .eateryBlue
        scrollView.addSubview(underlineView)

        select(at: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func select(at index: Int) {
        // Base case to protect against accidental backend errors
        if tabButtons.count == 0 {
            return
        }

        selectedSegmentIndex = index
        let button = tabButtons[selectedSegmentIndex]
        let buttonPos = button.center.x - (button.frame.width / 2)
        let maxScroll = self.scrollView.contentSize.width + self.padding - self.scrollView.frame.width

        UIView.animate(withDuration: 0.4) {
            self.underlineView.center.x = button.center.x + self.padding // Must account for padding of StackView
            if buttonPos < maxScroll {
                self.scrollView.contentOffset.x = button.center.x - (button.frame.width / 2)
            } else if self.scrollView.contentOffset.x < maxScroll {
                self.scrollView.contentOffset.x = maxScroll
            }
        }

        self.underlineView.snp.remakeConstraints { make in
            make.centerX.equalTo(button)
            make.width.equalTo(button)
            make.bottom.equalTo(button).offset(self.underlineOffset)
            make.height.equalTo(2)
        }

        for tab in tabButtons {
            tab.isSelected = false
            tab.isUserInteractionEnabled = true
            tab.setTitleColor(.gray, for: .normal)
        }

        tabButtons[index].setTitleColor(.eateryBlue, for: .normal)
        tabButtons[index].isSelected = true
        tabButtons[index].isUserInteractionEnabled = false
    }

}
