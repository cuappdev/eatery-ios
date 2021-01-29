//
//  EateriesFailedToLoadView.swift
//  Eatery
//
//  Created by William Ma on 3/14/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

protocol EateriesFailedToLoadViewDelegate: AnyObject {

    func eateriesFailedToLoadViewPressedRetryButton(_ eftlv: EateriesFailedToLoadView)

}

class EateriesFailedToLoadView: UIView {

    private let imageView = UIImageView(image: UIImage(named: "internetError"))

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let retryButton = UIButton(type: .system)

    weak var delegate: EateriesFailedToLoadViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        titleLabel.font = .systemFont(ofSize: 36, weight: .bold)
        titleLabel.text = "Oops! 😔"
        titleLabel.textColor = .black
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
        }

        subtitleLabel.font = .systemFont(ofSize: 20, weight: .medium)
        subtitleLabel.numberOfLines = 3
        subtitleLabel.text = "No Internet connection"
        subtitleLabel.textColor = .secondary
        subtitleLabel.textAlignment = .center
        subtitleLabel.setContentHuggingPriority(.required, for: .vertical)
        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        retryButton.setTitle("Retry", for: .normal)
        retryButton.setContentHuggingPriority(.required, for: .vertical)
        retryButton.setTitleColor(.eateryBlue, for: .normal)
        retryButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)
        retryButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
        retryButton.layer.borderWidth = 4.0
        retryButton.layer.borderColor = UIColor.eateryBlue.cgColor
        retryButton.addTarget(self, action: #selector(retryButtonPressed), for: .touchUpInside)
        addSubview(retryButton)
        retryButton.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(32)
            make.centerX.bottom.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        retryButton.layer.cornerRadius = min(retryButton.frame.width, retryButton.frame.height) / 2
    }

    @objc private func retryButtonPressed(_ sender: UIButton) {
        delegate?.eateriesFailedToLoadViewPressedRetryButton(self)
    }

}
