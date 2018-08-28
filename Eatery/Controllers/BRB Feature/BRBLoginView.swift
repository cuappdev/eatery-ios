import UIKit
import NVActivityIndicatorView

protocol BRBLoginViewDelegate {
    func brbLoginViewClickedLogin(brbLoginView: BRBLoginView, netid: String, password: String)
}

class BRBLoginView: UIView, UITextFieldDelegate {
    
    var delegate: BRBLoginViewDelegate?

    let headerLabel = UILabel()
    let netidPrompt = UILabel()
    let netidTextField = UITextField()
    let passwordPrompt = UILabel()
    let passwordTextField = UITextField()
    let perpetualLoginButton = UIButton()
    let loginButton = UIButton()
    let privacyStatementButton = UIButton()
    let privacyStatementTextView = UITextView()
    
    var activityIndicator: NVActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        privacyStatementTextView.isEditable = false
        privacyStatementTextView.text = "\n\nPrivacy Statement\n\n\nWhen you log in using our system, we will use your credentials solely to fetch your account information on your behalf. Your credentials will be stored safely on this device in a manner similar to how a web browser might cache your login information.\n\nYour netid and password will never leave your device, and will never be stored on our servers or viewed by anyone on our team.\n\nYou may log out of your account at any time to erase all of your account information from this device.\n\n\nTap Anywhere To Dismiss"
        privacyStatementTextView.textAlignment = .center
        privacyStatementTextView.font = UIFont.systemFont(ofSize: 14)
        privacyStatementTextView.textContainerInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        headerLabel.text = "Log in with your Cornell NetID to see your account balance and history"
        headerLabel.textColor = .darkGray
        headerLabel.numberOfLines = 2
        headerLabel.textAlignment = .center
        headerLabel.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        addSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52.0)
        }

        privacyStatementButton.setTitle("Privacy Statement", for: .normal)
        privacyStatementButton.setTitleColor(.eateryBlue, for: .normal)
        privacyStatementButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        privacyStatementButton.setTitleColor(.black, for: .highlighted)
        privacyStatementButton.addTarget(self, action: #selector(privacyStatementButtonPressed), for: .touchUpInside)
        addSubview(privacyStatementButton)
        privacyStatementButton.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom)
            make.centerX.equalToSuperview()
        }

        netidPrompt.text = "NetID"
        netidPrompt.textColor = .darkGray
        netidPrompt.font = UIFont.boldSystemFont(ofSize: 14)
        addSubview(netidPrompt)
        netidPrompt.snp.makeConstraints { make in
            make.top.equalTo(privacyStatementButton.snp.bottom).offset(15)
            make.leading.equalTo(headerLabel)
            make.trailing.equalTo(headerLabel)
        }

        netidTextField.textColor = .darkGray
        netidTextField.placeholder = "type your netid (e.g. abc123)"
        netidTextField.font = UIFont.systemFont(ofSize: 14)
        netidTextField.autocapitalizationType = .none
        netidTextField.tintColor = .darkGray
        netidTextField.delegate = self
        netidTextField.autocorrectionType = .no

        let netidLine = UIView()
        netidLine.backgroundColor = .gray
        netidTextField.addSubview(netidLine)
        netidLine.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }

        addSubview(netidTextField)
        netidTextField.snp.makeConstraints { make in
            make.top.equalTo(netidPrompt.snp.bottom)
            make.leading.equalTo(headerLabel)
            make.trailing.equalTo(headerLabel)
            make.height.equalTo(44)
        }

        passwordPrompt.text = "Password"
        passwordPrompt.textColor = .darkGray
        passwordPrompt.font = UIFont.boldSystemFont(ofSize: 14)
        addSubview(passwordPrompt)
        passwordPrompt.snp.makeConstraints { make in
            make.top.equalTo(netidTextField.snp.bottom).offset(20)
            make.leading.equalTo(headerLabel)
            make.trailing.equalTo(headerLabel)
        }

        passwordTextField.textColor = .darkGray
        passwordTextField.placeholder = "type your password"
        passwordTextField.font = UIFont.systemFont(ofSize: 15)
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        passwordTextField.tintColor = .darkGray
        passwordTextField.delegate = self

        let bottomLine = UIView()
        bottomLine.backgroundColor = .darkGray
        passwordTextField.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }

        addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(passwordPrompt.snp.bottom)
            make.leading.equalTo(headerLabel)
            make.trailing.equalTo(headerLabel)
            make.height.equalTo(44)
        }

        // iphone 5s.height = 568
        perpetualLoginButton.setTitle("☐   Save my login info", for: .normal)
        /// NOTE: this checkbox solution is rather hacky, should be replaced with images in the future
        perpetualLoginButton.setTitle("☑ Save my login info", for: .selected)
        perpetualLoginButton.setTitleColor(.darkGray, for: .normal)
        perpetualLoginButton.setTitleColor(.black, for: .highlighted)
        perpetualLoginButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        perpetualLoginButton.titleLabel?.textAlignment = .left
        perpetualLoginButton.addTarget(self, action: #selector(BRBLoginView.keepMeSignedIn), for: .touchUpInside)
        perpetualLoginButton.sendActions(for: .touchUpInside)
        addSubview(perpetualLoginButton)
        perpetualLoginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.leading.trailing.equalTo(headerLabel)
            make.height.equalTo(20)
        }

        loginButton.setTitle("Login", for: .normal)
        loginButton.layer.cornerRadius = 8.0
        loginButton.layer.masksToBounds = true
        loginButton.setBackgroundImage(UIImage.image(withColor: .eateryBlue), for: .normal)
        loginButton.setBackgroundImage(UIImage.image(withColor: .transparentEateryBlue), for: .highlighted)
        loginButton.titleLabel?.textAlignment = .center
        loginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(perpetualLoginButton.snp.bottom).offset(20)
            make.leading.equalTo(headerLabel)
            make.trailing.equalTo(headerLabel)
            make.bottom.equalToSuperview().inset(20)
            make.height.equalTo(55)
        }
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 22.0, height: 22.0), type: .circleStrokeSpin, color: .white, padding: nil)
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(loginButton)
        }
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func privacyStatementButtonPressed() {
        addSubview(privacyStatementTextView)
        privacyStatementTextView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        let hideButton = UIButton()
        hideButton.addTarget(self, action: #selector(dismissPrivacyStatement(sender:)), for: .touchUpInside)
        addSubview(hideButton)
        hideButton.snp.makeConstraints { make in
            make.edges.equalTo(privacyStatementTextView)
        }
    }
    
    @objc func dismissPrivacyStatement(sender: UIButton) {
        sender.removeFromSuperview()
        privacyStatementTextView.snp.removeConstraints()
        privacyStatementTextView.removeFromSuperview()
    }
    
    @objc func keepMeSignedIn() { // toggle
        perpetualLoginButton.isSelected = !perpetualLoginButton.isSelected
        
        if !perpetualLoginButton.isSelected {
            UserDefaults.standard.removeObject(forKey: BRBAccountSettings.SAVE_LOGIN_INFO)
        }
    }
    
    @objc func login() {
        
        let netid = (netidTextField.text ?? "").lowercased()
        let password = passwordTextField.text ?? ""
        
        if netid.count > 0 && password.count > 0 {

            headerLabel.text = "Logging in... this may take a minute."
            headerLabel.textColor = .gray
            activityIndicator.startAnimating()
            loginButton.setTitle(nil, for: .normal)
            
            delegate?.brbLoginViewClickedLogin(brbLoginView: self, netid: netid, password: password)
            isUserInteractionEnabled = false
            alpha = 0.5
            
            UserDefaults.standard.set(perpetualLoginButton.isSelected, forKey: BRBAccountSettings.SAVE_LOGIN_INFO)
        } else {
            if netid.count == 0 {
                netidTextField.becomeFirstResponder()
            } else {
                passwordTextField.becomeFirstResponder()
            }
        }
    }
    
    func loginFailedWithError(error: String) {
        headerLabel.textColor = .red
        headerLabel.text = error
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordTextField {
            
            netidTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
            
            login()
        }
        return true
    }
    
}
