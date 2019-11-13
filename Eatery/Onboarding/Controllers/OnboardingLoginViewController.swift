//
//  OnboardingLoginViewController.swift
//  Eatery
//
//  Created by Reade Plunkett on 11/12/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class OnboardingLoginViewController: OnboardingViewController {

    private var loginStackView: UIStackView!

    private var netidPrompt: UILabel!
    private var netidTextField: UITextField!

    private var passwordPrompt: UILabel!
    private var passwordTextField: UITextField!

    private var loginButton: UIButton!
    private var skipButton: UIButton!
    private var privacyStatementButton: UIButton!

    private var activityIndicator: NVActivityIndicatorView!
    
    private var errorView: BRBLoginErrorView!
    var errorDescription: String? {
        get { return errorView.errorLabel.text }
        set { errorView.errorLabel.text = newValue }
    }

    let accountManager = BRBAccountManager()

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

        loginStackView = UIStackView(frame: .zero)
        loginStackView.axis = .vertical
        loginStackView.distribution = .fill
        loginStackView.spacing = 10
        stackView.insertArrangedSubview(loginStackView, at: 2)
        stackView.setCustomSpacing(20, after: subtitleLabel)
        stackView.setCustomSpacing(40, after: loginStackView)
        loginStackView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }

        setUpPrivacyStatementButton()
        setUpErrorView()
        setUpNetidViews()
        setUpPasswordViews()
        setUpSkipButton()
    }

    private func setUpPrivacyStatementButton() {
        privacyStatementButton = UIButton(type: .system)
        privacyStatementButton.setTitle("Privacy Statement", for: .normal)
        privacyStatementButton.setTitleColor(.white, for: .normal)
        privacyStatementButton.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
        privacyStatementButton.setTitleColor(.black, for: .highlighted)
        privacyStatementButton.addTarget(self,
                                         action: #selector(privacyStatementButtonPressed(_:)),
                                         for: .touchUpInside)
        loginStackView.addArrangedSubview(privacyStatementButton)
    }

    @objc private func privacyStatementButtonPressed(_ sender: UIButton) {
        let privacyStatementViewController = BRBPrivacyStatementViewController()
        self.present(privacyStatementViewController, animated: true, completion: nil)
    }

    private func setUpErrorView() {
        errorView = BRBLoginErrorView(frame: .zero)
        errorView.isCollapsed = true
        loginStackView.addArrangedSubview(errorView)
    }

    private func setUpNetidViews() {
        netidPrompt = UILabel(frame: .zero)
        netidPrompt.text = "NetID"
        netidPrompt.textColor = .white
        netidPrompt.font = .preferredFont(forTextStyle: .headline)
        loginStackView.addArrangedSubview(netidPrompt)

        netidTextField = UITextField(frame: .zero)
        netidTextField.textColor = UIColor(white: 225.0 / 255.0, alpha: 1.0)
        netidTextField.attributedPlaceholder = NSAttributedString(string: "Type your NetID (e.g. abc123)",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 225.0 / 255.0, alpha: 1.0)])
        netidTextField.font = .preferredFont(forTextStyle: .body)
        netidTextField.autocapitalizationType = .none
        netidTextField.tintColor = UIColor(white: 225.0 / 255.0, alpha: 1.0)
        netidTextField.autocorrectionType = .no
        loginStackView.addArrangedSubview(netidTextField)

        let netidSeparator = UIView()
        netidSeparator.backgroundColor = UIColor(white: 225.0 / 255.0, alpha: 1.0)
        loginStackView.addArrangedSubview(netidSeparator)
        netidSeparator.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }

    private func setUpPasswordViews() {
        passwordPrompt = UILabel(frame: .zero)
        passwordPrompt.text = "Password"
        passwordPrompt.textColor = .white
        passwordPrompt.font = .preferredFont(forTextStyle: .headline)
        loginStackView.addArrangedSubview(passwordPrompt)

        passwordTextField = UITextField(frame: .zero)
        passwordTextField.textColor = UIColor(white: 225.0 / 255.0, alpha: 1.0)
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Type your password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: 225.0 / 255.0, alpha: 1.0)])
        passwordTextField.font = .preferredFont(forTextStyle: .body)
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        passwordTextField.tintColor = UIColor(white: 225.0 / 255.0, alpha: 1.0)
        loginStackView.addArrangedSubview(passwordTextField)

        let passwordSeparator = UIView()
        passwordSeparator.backgroundColor = UIColor(white: 225.0 / 255.0, alpha: 1.0)
        loginStackView.addArrangedSubview(passwordSeparator)
        passwordSeparator.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }

    override func setUpButton() {
        loginButton = UIButton()
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

        activityIndicator = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin, color: .white)
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
        skipButton = UIButton()
        skipButton.setTitle("SKIP", for: .normal)
        skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        skipButton.titleLabel?.textColor = .white
        skipButton.addTarget(self, action: #selector(didTapSkipButton), for: .touchUpInside)
        self.view.addSubview(skipButton)
        skipButton.snp.makeConstraints { make in
            // Check to see if iPhone has a notch
            let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            if bottom > 10 {
                // Has notch
                make.top.equalToSuperview().offset(55)
                make.right.equalToSuperview().offset(-40)
            } else {
                make.top.equalToSuperview().offset(32)
                make.right.equalToSuperview().offset(-32)
            }

        }
    }

    @objc func didTapSkipButton() {
        UserDefaults.standard.set(true, forKey: "hasOnboarded")
        delegate?.onboardingViewControllerDidTapNextButton(viewController: self)
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

        accountManager.saveLoginInfo(loginInfo: LoginInfo(netid: netid, password: password))
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

        errorDescription = error
        setShowErrorMessage(true, animated: true)
        isLoading = false

    }

    func brbAccountManager(didQuery account: BRBAccount) {
        UserDefaults.standard.set(true, forKey: "hasOnboarded")
        delegate?.onboardingViewControllerDidTapNextButton(viewController: self)
    }

}
