//
//  PillView.swift
//  Eatery
//
//  Created by William Ma on 4/10/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class PillView: UIControl {

    private let activeColor: UIColor = .eateryBlue
    private let inactiveColor: UIColor = .secondary

    private let leftStackView: UIStackView
    let leftImageView = UIImageView()
    let leftLabel = UILabel()
    private(set) var leftSegmentSelected: Bool = true

    private let separatorView = UIView()

    private let rightStackView: UIStackView
    let rightImageView = UIImageView()
    let rightLabel = UILabel()
    private var rightSegmentSelected: Bool {
        return !leftSegmentSelected
    }

    init() {
        leftStackView = UIStackView(arrangedSubviews: [leftImageView, leftLabel])
        rightStackView = UIStackView(arrangedSubviews: [rightImageView, rightLabel])

        super.init(frame: .zero)

        backgroundColor = .white
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = .zero
        layer.shadowRadius = 1

        let attributeSizes = getAttributeSizes()
        leftImageView.snp.makeConstraints { make in
            make.width.height.equalTo(attributeSizes.iconSideLength)
        }

        leftLabel.font = .systemFont(ofSize: attributeSizes.fontSize, weight: .medium)

        leftStackView.isUserInteractionEnabled = false
        leftStackView.axis = .horizontal
        leftStackView.spacing = 6
        addSubview(leftStackView)
        leftStackView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().dividedBy(2)
        }

        separatorView.backgroundColor = .inactive
        addSubview(separatorView)
        separatorView.snp.makeConstraints { (make) in
            make.width.equalTo(2)
            make.height.equalToSuperview()
            make.centerX.centerY.equalToSuperview()
        }

        rightImageView.snp.makeConstraints { make in
            make.width.height.equalTo(attributeSizes.iconSideLength)
        }

        rightLabel.font = .systemFont(ofSize: attributeSizes.fontSize, weight: .medium)

        rightStackView.isUserInteractionEnabled = false
        rightStackView.axis = .horizontal
        rightStackView.spacing = 6
        addSubview(rightStackView)
        rightStackView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().multipliedBy(1.5)
        }

        selectLeftSegment()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

    func selectLeftSegment() {
        leftSegmentSelected = true

        leftImageView.tintColor = activeColor
        leftLabel.textColor = activeColor

        rightImageView.tintColor = inactiveColor
        rightLabel.textColor = inactiveColor

        sendActions(for: .valueChanged)
    }

    func selectRightSegment() {
        leftSegmentSelected = false

        leftImageView.tintColor = inactiveColor
        leftLabel.textColor = inactiveColor

        rightImageView.tintColor = activeColor
        rightLabel.textColor = activeColor

        sendActions(for: .valueChanged)
    }
    
    private func getAttributeSizes() -> (iconSideLength: Int, fontSize: CGFloat) {
        return UIScreen.main.nativeBounds.height <= 1136 ? (14, 12) : (16, 14)
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)

        if location.x > frame.width / 2, leftSegmentSelected {
            selectRightSegment()
        } else if location.x < frame.width / 2, rightSegmentSelected {
            selectLeftSegment()
        }

        return false
    }

}
