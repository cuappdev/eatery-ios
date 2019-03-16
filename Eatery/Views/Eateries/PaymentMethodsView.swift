//
//  PaymentMethodsView.swift
//  Eatery
//
//  Created by William Ma on 1/27/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class PaymentMethodsView: UIView {

    private let imageViews = [
        UIImageView(),
        UIImageView(),
        UIImageView()
    ]

    var paymentMethods: [PaymentMethod] = [] {
        didSet {
            var images: [UIImage] = []

            if paymentMethods.contains(.cash) || paymentMethods.contains(.creditCard),
                let icon = UIImage(named: "cashIcon") {
                images.append(icon)
            }

            if paymentMethods.contains(.brb),
                let icon = UIImage(named: "brbIcon") {
                images.append(icon)
            }

            if paymentMethods.contains(.swipes),
                let icon = UIImage(named: "swipeIcon") {
                images.append(icon)
            }

            for (image, imageView) in zip(images, imageViews) {
                imageView.image = image
                imageView.isHidden = false
            }

            for imageView in imageViews[images.count...] {
                imageView.isHidden = true
            }
        }
    }

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(imageViews[2])
        imageViews[2].snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.height.equalTo(20)
        }

        addSubview(imageViews[1])
        imageViews[1].snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(imageViews[2].snp.trailing).offset(5)
            make.width.height.equalTo(20)
        }

        addSubview(imageViews[0])
        imageViews[0].snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
            make.leading.equalTo(imageViews[1].snp.trailing).offset(5)
            make.width.height.equalTo(20)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

}
