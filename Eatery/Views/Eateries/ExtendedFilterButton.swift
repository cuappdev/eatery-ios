//
//  FilterButton.swift
//  Eatery
//
//  Created by Sergio Diaz on 12/24/20.
//  Copyright © 2020 Cornell AppDev. All rights reserved.
//

import UIKit
import SnapKit

enum ExtendedFilterButtonState {
    case inactive, hightolow, lowtohigh
}

class ExtendedFilterButton: UIButton {

    var topRect: UIView!
    var middleRect: UIView!
    var bottomRect: UIView!

    var topSpacingRect: UIView!
    var bottomSpacingRect: UIView!

    let inactiveColor: UIColor
    let activeColor: UIColor
    var filterState: ExtendedFilterButtonState

    init(frame: CGRect, inactiveColor: UIColor, activeColor: UIColor) {
        self.inactiveColor = inactiveColor
        self.activeColor = activeColor
        filterState = .inactive
        super.init(frame: frame)

        topRect = UIView()
        topRect.backgroundColor = .gray
        topRect.layer.cornerRadius = 5
        topRect.isUserInteractionEnabled = false
        addSubview(topRect)

        middleRect = UIView()
        middleRect.backgroundColor = .gray
        middleRect.layer.cornerRadius = 5
        middleRect.isUserInteractionEnabled = false
        addSubview(middleRect)

        bottomRect = UIView()
        bottomRect.backgroundColor = .gray
        bottomRect.layer.cornerRadius = 5
        bottomRect.isUserInteractionEnabled = false
        addSubview(bottomRect)

        topSpacingRect = UIView()
        topSpacingRect.backgroundColor = .clear
        topSpacingRect.isUserInteractionEnabled = false
        addSubview(topSpacingRect)

        bottomSpacingRect = UIView()
        bottomSpacingRect.backgroundColor = .clear
        bottomSpacingRect.isUserInteractionEnabled = false
        addSubview(bottomSpacingRect)

        setInitialConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setInitialConstraints() {
        topRect.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().dividedBy(5)
        }

        topSpacingRect.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(topRect.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalToSuperview().dividedBy(5)
        }

        middleRect.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(topSpacingRect.snp.bottom)
            make.width.equalToSuperview().dividedBy(1.7)
            make.height.equalToSuperview().dividedBy(5)
        }

        bottomSpacingRect.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(middleRect.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalToSuperview().dividedBy(5)
        }

        bottomRect.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(bottomSpacingRect.snp.bottom)
            make.width.equalToSuperview().dividedBy(3.4)
            make.height.equalToSuperview().dividedBy(5)
        }
    }

    func flipButton() {
        topRect.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview().dividedBy(3.4)
            make.height.equalToSuperview().dividedBy(5)
        }

        bottomRect.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(bottomSpacingRect.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalToSuperview().dividedBy(5)

        }
    }

    func normalizeButton() {
        topRect.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().dividedBy(5)
        }

        bottomRect.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(bottomSpacingRect.snp.bottom)
            make.width.equalToSuperview().dividedBy(3.4)
            make.height.equalToSuperview().dividedBy(5)

        }
    }

    func changeToActiveColor() {
        topRect.backgroundColor = activeColor
        middleRect.backgroundColor = activeColor
        bottomRect.backgroundColor = activeColor
    }

    func changeToInactiveColor() {
        topRect.backgroundColor = inactiveColor
        middleRect.backgroundColor = inactiveColor
        bottomRect.backgroundColor = inactiveColor
    }

    func pressed() {
        if filterState == .inactive {
            changeToActiveColor()
            filterState = .hightolow
        } else if filterState == .hightolow {
            flipButton()
            filterState = .lowtohigh
        } else {
            normalizeButton()
            changeToInactiveColor()
            filterState = .inactive
        }
    }

}
