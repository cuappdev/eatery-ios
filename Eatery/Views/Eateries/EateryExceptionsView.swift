//
//  EateryExceptionsView.swift
//  Eatery
//
//  Created by William Ma on 9/25/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import UIKit

class EateryExceptionsView: UIView {

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

    private let imageView = UIImageView()

    private let label = UILabel()

    init() {
        super.init(frame: .zero)

        blurView.alpha = 0.5
        blurView.clipsToBounds = true
        addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        insertSubview(imageView, aboveSubview: blurView)
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.top.bottom.equalToSuperview().inset(4)
            make.width.height.equalTo(16)
        }

        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        insertSubview(label, aboveSubview: blurView)
        label.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(4)
            make.top.bottom.equalToSuperview().inset(4)
            make.trailing.equalToSuperview().inset(8)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        blurView.layer.cornerRadius = frame.height / 2
    }

    func configure(color: UIColor, exception: String, image: UIImage?) {
        blurView.backgroundColor = color
        imageView.image = image
        label.text = exception
    }

}
