//
//  GradientView.swift
//  Eatery
//
//  Created by William Ma on 5/4/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class GradientView: UIView {

    let gradientLayer: CAGradientLayer

    override init(frame: CGRect) {
        gradientLayer = CAGradientLayer()

        super.init(frame: frame)

        isOpaque = false

        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.6).cgColor]
        layer.addSublayer(gradientLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = bounds
        CATransaction.commit()
    }

}
