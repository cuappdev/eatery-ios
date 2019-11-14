//
//  OnboardingLoginViewController.swift
//  Eatery
//
//  Created by Reade Plunkett on 11/12/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import NVActivityIndicatorView
import UIKit

class OnboardingLoginViewController: OnboardingViewController {

    private var loginStackView: UIStackView!

    private let netidPromptLabel = UILabel()
    private let netidTextField = UITextField()

    private let passwordPromptLabel = UILabel()
    private let passwordTextField = UITextField()

    private let loginButton = UIButton()
    private let skipButton = UIButton()
    private let privacyStatementButton = UIButton(type: .system)

    private let activityIndicator = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin, color: .white)
    
    private let errorView = BRBLoginErrorView()

    private let accountManager = BRBAccountManager()

    private var isLoading: Bool = false {
        didSet {
            if isLoading {
                activityIndicator.startAnimating()
                loginButton.setTitle(nil, for: .normal)
            } else {
                activityIndicator.stopAnimating()
                loginButton.setTitle("LOG IN", for: .normal)
            }

            stackView.isUserInteractionEnabled = !isLoading
            loginButton.isEnabled = !isLoading
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        accountManager.delegate = self
        accountManager.removeSavedLoginInfo()

        setUpStackView()
        setUpPrivacyStatementButton()
        setUpErrorView()
        setUpNetidViews()
        setUpPasswordViews()
        setUpSkipButton()
    }

    private func setUpStackView() {
        loginStackView = UIStackView()
        loginStackView.axis = .vertical
        loginStackView.distribution = .fill
        loginStackView.spacing = 10
        stackView.insertArrangedSubview(loginStackView, at: 2)
        stackView.setCustomSpacing(20, after: subtitleLabel)
        stackView.setCustomSpacing(40, after: loginStackView)

        loginStackView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
    }

    private func setUpPrivacyStatementButton() {
        privacyStatementButton.setTitle("Privacy Statement", for: .normal)
        privacyStatementButton.setTitleColor(.white, for: .normal)
        privacyStatementButton.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
        privacyStatementButton.setTitleColor(.black, for: .highlighted)
        privacyStatementButton.addTarget(self,
                                         action: #selector(didTapPrivacyButton),
                                         for: .touchUpInside)
        loginStackView.addArrangedSubview(privacyStatementButton)
    }

    @objc private func didTapPrivacyButton(_ sender: UIButton) {
        let privacyStatementViewController = BRBPrivacyStatementViewController()
        self.present(privacyStatementViewController, animated: true, completion: nil)
    }

    private func setUpErrorView() {
        errorView.isCollapsed = true
        loginStackView.addArrangedSubview(errorView)
    }

    private func setUpNetidViews() {
        netidPromptLabel.text = "NetID"
        netidPromptLabel.textColor = .white
        netidPromptLabel.font = .preferredFont(forTextStyle: .headline)
        loginStackView.addArrangedSubview(netidPromptLabel)

        netidTextField.textColor = .textFieldColor
        netidTextField.attributedPlaceholder = NSAttributedString(string: "Type your NetID (e.g. abc123)",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldColor])
        netidTextField.font = .preferredFont(forTextStyle: .body)
        netidTextField.autocapitalizationType = .none
        netidTextField.tintColor = .textFieldColor
        netidTextField.autocorrectionType = .no
        loginStackView.addArrangedSubview(netidTextField)

        let netidSeparator = UIView()
        netidSeparator.backgroundColor = .textFieldColor
        loginStackView.addArrangedSubview(netidSeparator)

        netidSeparator.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }

    private func setUpPasswordViews() {
        passwordPromptLabel.text = "Password"
        passwordPromptLabel.textColor = .white
        passwordPromptLabel.font = .preferredFont(forTextStyle: .headline)
        loginStackView.addArrangedSubview(passwordPromptLabel)

        passwordTextField.textColor = .textFieldColor
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Type your password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.textFieldColor])
        passwordTextField.font = .preferredFont(forTextStyle: .body)
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        passwordTextField.tintColor = .textFieldColor
        loginStackView.addArrangedSubview(passwordTextField)

        let passwordSeparator = UIView()
        passwordSeparator.backgroundColor = .textFieldColor
        loginStackView.addArrangedSubview(passwordSeparator)
        
        passwordSeparator.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }

    override func setUpButton() {
        loginButton.layer.borderWidth = 2
        loginButton.layer.borderColor = UIColor.white.cgColor
        loginButton.layer.cornerRadius = 30
        loginButton.setTitle("LOG IN", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .heavy)
        loginButton.titleLabel?.textColor = .white
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        stackView.addArrangedSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.width.equalTo(240)
            make.height.equalTo(60)
        }

        loginButton.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }
    }

    @objc func didTapLoginButton() {
        requestLoginIfPossible()
    }

    private func setUpSkipButton() {
        skipButton.setTitle("SKIP", for: .normal)
        skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        skipButton.titleLabel?.textColor = .white
        skipButton.addTarget(self, action: #selector(didTapSkipButton), for: .touchUpInside)
        view.addSubview(skipButton)

        skipButton.snp.makeConstraints { make in
            make.topMargin.equalToSuperview().offset(32)
            make.rightMargin.equalToSuperview().offset(-32)
        }
    }

    @objc func didTapSkipButton() {
        UserDefaults.standard.set(true, forKey: "hasOnboarded")
        delegate?.onboardingViewControllerDidTapNext(self)
    }

    private func requestLoginIfPossible() {
        let netid = netidTextField.text?.lowercased() ?? ""
        let password = passwordTextField.text ?? ""

        guard !netid.isEmpty else {
            netidTextField.becomeFirstResponder()
            return
        }

        guard !password.isEmpty else {
            passwordTextField.becomeFirstResponder()
            return
        }

        netidTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()

        //accountManager.saveLoginInfo(loginInfo: LoginInfo(netid: netid, password: password))
        accountManager.queryBRBData(netid: netid, password: password)
        isLoading = true
    }

    func setShowErrorMessage(_ newValue: Bool, animated: Bool) {
        let actions: () -> Void = {
            self.errorView.isCollapsed = !newValue
            self.view.layoutIfNeeded()
        }

        if animated {
            UIViewPropertyAnimator(duration: 0.35, dampingRatio: 1, animations: actions).startAnimation()
        } else {
            actions()
        }
    }

}

extension OnboardingLoginViewController: BRBAccountManagerDelegate {

    func brbAccountManager(didFailWith error: String) {
        errorView.errorLabel.text = error
        setShowErrorMessage(true, animated: true)
        isLoading = false
    }

    func brbAccountManager(didQuery account: BRBAccount) {
        UserDefaults.standard.set(true, forKey: "hasOnboarded")
        delegate?.onboardingViewControllerDidTapNext(self)
    }

}
