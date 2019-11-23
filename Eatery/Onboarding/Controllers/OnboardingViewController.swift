//
//  OnboardingViewController.swift
//  Eatery
//
//  Created by Reade Plunkett on 11/11/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

protocol OnboardingViewControllerDelegate {
    func onboardingViewControllerDidTapNext(_ viewController: OnboardingViewController)
}

class OnboardingViewController: UIViewController {

    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let onboardingTitle: String
    private let onboardingSubtitle: String

    let contentView = UIView()

    var delegate: OnboardingViewControllerDelegate?

    init(title: String, subtitle: String) {
        self.onboardingTitle = title
        self.onboardingSubtitle = subtitle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .eateryBlue

        setUpStackView()
        setUpTitleLabel()
        setUpSubtitleLabel()
        setUpContentView()
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 40
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().inset(30)
        }
    }

    private func setUpTitleLabel() {
        titleLabel.text = onboardingTitle
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 36, weight: .bold)
        stackView.addArrangedSubview(titleLabel)
    }

    private func setUpSubtitleLabel() {
        subtitleLabel.text = onboardingSubtitle
        subtitleLabel.textColor = .white
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = .systemFont(ofSize: 24, weight: .medium)
        stackView.addArrangedSubview(subtitleLabel)
    }

    private func setUpContentView() {
        stackView.addArrangedSubview(contentView)
    }

}
