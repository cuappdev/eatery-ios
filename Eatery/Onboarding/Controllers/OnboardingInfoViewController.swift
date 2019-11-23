//
//  OnboardingInfoViewController.swift
//  Eatery
//
//  Created by Reade Plunkett on 11/15/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class OnboardingInfoViewController: OnboardingViewController {

    private let stackView = UIStackView()
    private let imageView = UIImageView()
    private let nextButton = UIButton()
    private var onboardingImage = UIImage()

    init(title: String, subtitle: String, image: UIImage!) {
        super.init(title: title, subtitle: subtitle)
        self.onboardingImage = image
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpStackView()
        setUpImageView()
        setUpButton()

        stackView.layoutIfNeeded()
        contentView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(stackView.frame.height)
        }
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 40
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    private func setUpImageView() {
        imageView.image = onboardingImage
        imageView.contentMode = .scaleAspectFit
        stackView.addArrangedSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.height.equalTo(128)
        }
    }

    private func setUpButton() {
        nextButton.layer.borderWidth = 2
        nextButton.layer.borderColor = UIColor.white.cgColor
        nextButton.layer.cornerRadius = 30
        nextButton.setTitle("NEXT", for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .heavy)
        nextButton.titleLabel?.textColor = .white
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        stackView.addArrangedSubview(nextButton)

        nextButton.snp.makeConstraints { make in
            make.width.equalTo(240)
            make.height.equalTo(60)
        }
    }

    @objc private func didTapNextButton(sender: UIButton) {
        delegate?.onboardingViewControllerDidTapNext(self)
    }

}
