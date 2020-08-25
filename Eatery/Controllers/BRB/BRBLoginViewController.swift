//
//  BRBLoginViewController.swift
//  Eatery
//
//  Created by William Ma on 9/1/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import NVActivityIndicatorView
import UIKit

protocol BRBLoginViewControllerDelegate: AnyObject {

    func loginViewController(
        _ loginViewController: BRBLoginViewController,
        didRequestLoginWithNetid netid: String,
        password: String
    )

}

class BRBLoginViewController: UIViewController {

    weak var delegate: BRBLoginViewControllerDelegate?

    private var stackView: UIStackView!

    private var headerLabel: UILabel!
    private var privacyStatementButton: UIButton!

    private var errorView: BRBLoginErrorView!
    var errorDescription: String? {
        get { errorView.errorLabel.text }
        set { errorView.errorLabel.text = newValue }
    }

    private var netidPrompt: UILabel!
    private var netidTextField: UITextField!

    private var passwordPrompt: UILabel!
    private var passwordTextField: UITextField!

    private var loginButton: UIButton!
    private var activityIndicator: NVActivityIndicatorView!

    var isLoading: Bool = false {
        didSet {
            if isLoading {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }

            stackView.isUserInteractionEnabled = !isLoading
            loginButton.isEnabled = !isLoading
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let scrollView = UIScrollView(frame: .zero)
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.layoutMargins = UIEdgeInsets(top: 40, left: 20, bottom: 0, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.spacing = 16
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }

        setUpHeaderLabel()
        setUpPrivacyStatementButton()
        setUpErrorView()
        setUpNetidViews()
        setUpPasswordViews()
        setUpLoginViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        netidTextField.text = nil
        passwordTextField.text = nil
        netidTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    private func setUpHeaderLabel() {
        headerLabel = UILabel(frame: .zero)
        headerLabel.text = "Log in with your Cornell NetID to see your account balance and history"
        headerLabel.textColor = .darkGray
        headerLabel.numberOfLines = 0
        headerLabel.textAlignment = .center
        headerLabel.font = .preferredFont(forTextStyle: .headline)
        stackView.addArrangedSubview(headerLabel)
    }

    private func setUpPrivacyStatementButton() {
        privacyStatementButton = UIButton(type: .system)
        privacyStatementButton.setTitle("Privacy Statement", for: .normal)
        privacyStatementButton.setTitleColor(.eateryBlue, for: .normal)
        privacyStatementButton.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
        privacyStatementButton.setTitleColor(.black, for: .highlighted)
        privacyStatementButton.addTarget(
            self,
            action: #selector(privacyStatementButtonPressed(_:)),
            for: .touchUpInside
        )
        stackView.addArrangedSubview(privacyStatementButton)
    }

    private func setUpErrorView() {
        errorView = BRBLoginErrorView(frame: .zero)
        errorView.isCollapsed = true
        stackView.addArrangedSubview(errorView)
    }

    private func setUpNetidViews() {
        netidPrompt = UILabel(frame: .zero)
        netidPrompt.text = "NetID"
        netidPrompt.textColor = .darkGray
        netidPrompt.font = .preferredFont(forTextStyle: .headline)
        stackView.addArrangedSubview(netidPrompt)

        netidTextField = UITextField(frame: .zero)
        netidTextField.textColor = .darkGray
        netidTextField.placeholder = "Type your NetID (e.g. abc123)"
        netidTextField.font = .preferredFont(forTextStyle: .body)
        netidTextField.autocapitalizationType = .none
        netidTextField.tintColor = .darkGray
        netidTextField.delegate = self
        netidTextField.autocorrectionType = .no
        stackView.addArrangedSubview(netidTextField)

        let netidSeparator = UIView()
        netidSeparator.backgroundColor = .gray
        stackView.addArrangedSubview(netidSeparator)
        netidSeparator.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }

    private func setUpPasswordViews() {
        passwordPrompt = UILabel(frame: .zero)
        passwordPrompt.text = "Password"
        passwordPrompt.textColor = .darkGray
        passwordPrompt.font = .preferredFont(forTextStyle: .headline)
        stackView.addArrangedSubview(passwordPrompt)

        passwordTextField = UITextField(frame: .zero)
        passwordTextField.textColor = .darkGray
        passwordTextField.placeholder = "Type your password"
        passwordTextField.font = .preferredFont(forTextStyle: .body)
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        passwordTextField.tintColor = .darkGray
        passwordTextField.delegate = self
        stackView.addArrangedSubview(passwordTextField)

        let passwordSeparator = UIView()
        passwordSeparator.backgroundColor = .gray
        stackView.addArrangedSubview(passwordSeparator)
        passwordSeparator.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }

    private func setUpLoginViews() {
        let loginAndActivityContainerView = UIView(frame: .zero)

        loginButton = UIButton(type: .system)
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitle("", for: .disabled)
        loginButton.layer.cornerRadius = 8.0
        loginButton.layer.masksToBounds = true
        loginButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)
        loginButton.backgroundColor = .eateryBlue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        loginButton.addTarget(self, action: #selector(loginButtonPressed(_:)), for: .touchUpInside)
        loginAndActivityContainerView.addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        activityIndicator = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin, color: .white)
        loginAndActivityContainerView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }

        stackView.addArrangedSubview(loginAndActivityContainerView)
    }

    @objc private func privacyStatementButtonPressed(_ sender: UIButton) {
        let privacyStatementViewController = BRBPrivacyStatementViewController()
        navigationController?.pushViewController(privacyStatementViewController, animated: true)
    }

    @objc private func loginButtonPressed(_ sender: UIButton) {
        AppDevAnalytics.shared.logFirebase(BRBLoginPressPayload())
        requestLoginIfPossible()
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

        delegate?.loginViewController(self, didRequestLoginWithNetid: netid, password: password)
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

extension BRBLoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        requestLoginIfPossible()
        return true
    }

}
