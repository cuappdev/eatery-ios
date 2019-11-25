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
    private var stackViewBottomConstraint: NSLayoutConstraint?
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

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: .UIKeyboardWillShow,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: .UIKeyboardWillHide,
                                               object: nil)
    }

    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 40
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(32)
            make.centerY.equalToSuperview().priority(.high)
        }

        stackViewBottomConstraint = view.bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        stackViewBottomConstraint?.isActive = false
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

extension OnboardingViewController {

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
                return
        }

        let actions: () -> Void = {
            self.stackViewBottomConstraint?.constant = keyboardFrame.height + 16
            self.stackViewBottomConstraint?.isActive = true
            self.view.layoutIfNeeded()
        }

        if let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: actions)
        } else {
            actions()
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {
                return
        }

        let actions: () -> Void = {
            self.stackViewBottomConstraint?.isActive = false
            self.view.layoutIfNeeded()
        }

        if let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: actions)
        } else {
            actions()
        }
    }

}
