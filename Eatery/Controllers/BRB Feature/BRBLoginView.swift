import UIKit

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
    
    var activityIndicator = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(white: 0.93, alpha: 1)

        privacyStatementTextView.isEditable = false
        privacyStatementTextView.text = "\n\nPrivacy Statement\n\n\nWhen you log in using our system, we will use your credentials solely to fetch your account information on your behalf. Your credentials will be stored safely on this device in a manner similar to how a web browser might cache your login information.\n\nYour netid and password will never leave your device, and will never be stored on our servers or viewed by anyone on our team.\n\nYou may log out of your account at any time to erase all of your account information from this device.\n\n\nTap Anywhere To Dismiss"
        privacyStatementTextView.textAlignment = .center
        privacyStatementTextView.font = UIFont.systemFont(ofSize: 14)
        privacyStatementTextView.backgroundColor = UIColor(white: 0.93, alpha: 1)
        privacyStatementTextView.textContainerInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        headerLabel.center = CGPoint(x: frame.width / 2.0, y: headerLabel.center.y)
        headerLabel.text = "Log in with your Cornell NetID to see your account balance and history"
        headerLabel.numberOfLines = 2
        headerLabel.textAlignment = .center
        headerLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
        }

        privacyStatementButton.setTitle("Privacy Statement", for: .normal)
        privacyStatementButton.setTitleColor(.eateryBlue, for: .normal)
        privacyStatementButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        privacyStatementButton.setTitleColor(.black, for: .highlighted)
        privacyStatementButton.addTarget(self, action: #selector(privacyStatementButtonPressed), for: .touchUpInside)
        addSubview(privacyStatementButton)
        privacyStatementButton.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom)
            make.leading.equalTo(headerLabel)
            make.trailing.equalTo(headerLabel)
        }

        netidPrompt.text = "NET ID"
        netidPrompt.textColor = .darkGray
        netidPrompt.font = UIFont.systemFont(ofSize: 12)
        addSubview(netidPrompt)
        netidPrompt.snp.makeConstraints { make in
            make.top.equalTo(privacyStatementButton.snp.bottom).offset(15)
            make.leading.equalTo(headerLabel)
            make.trailing.equalTo(headerLabel)
        }

        netidTextField.textColor = .darkGray
        netidTextField.placeholder = "type your netid (e.g. abc123)"
        netidTextField.font = UIFont.systemFont(ofSize: 15)
        netidTextField.autocapitalizationType = .none
        netidTextField.tintColor = .darkGray
        netidTextField.delegate = self
        netidTextField.autocorrectionType = .no

        let netidLine = UIView()
        netidLine.backgroundColor = .darkGray
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

        passwordPrompt.text = "PASSWORD"
        passwordPrompt.textColor = .darkGray
        passwordPrompt.font = UIFont.systemFont(ofSize: 12)
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
        perpetualLoginButton.setTitle("☐   Automatically log me in every time", for: .normal)
        /// NOTE: this checkbox solution is rather hacky, should be replaced with images in the future
        perpetualLoginButton.setTitle("☑ Automatically log me in every time", for: .selected)
        perpetualLoginButton.setTitleColor(.darkGray, for: .normal)
        perpetualLoginButton.setTitleColor(.black, for: .highlighted)
        perpetualLoginButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        perpetualLoginButton.titleLabel?.textAlignment = .left
        perpetualLoginButton.addTarget(self, action: #selector(BRBLoginView.keepMeSignedIn), for: .touchUpInside)
        perpetualLoginButton.sendActions(for: .touchUpInside)
        addSubview(perpetualLoginButton)
        perpetualLoginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.leading.equalTo(headerLabel)
            make.trailing.equalTo(headerLabel)
            make.height.equalTo(20)
        }

        loginButton.setTitle("Log in", for: .normal)
        loginButton.backgroundColor = .eateryBlue
        loginButton.setBackgroundImage(UIImage.image(withColor: .black), for: .highlighted)
        loginButton.titleLabel?.textAlignment = .center
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        addSubview(loginButton)
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(perpetualLoginButton.snp.bottom).offset(20)
            make.leading.equalTo(headerLabel)
            make.trailing.equalTo(headerLabel)
            make.height.equalTo(55)
        }
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = .black
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.centerX.equalToSuperview()
        }
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func privacyStatementButtonPressed() {
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
    
    func dismissPrivacyStatement(sender: UIButton) {
        sender.removeFromSuperview()
        privacyStatementTextView.snp.removeConstraints()
        privacyStatementTextView.removeFromSuperview()
    }
    
    func keepMeSignedIn() { // toggle
        perpetualLoginButton.isSelected = !perpetualLoginButton.isSelected
    }
    
    func login() {
        
        let netid = (netidTextField.text ?? "").lowercased()
        let password = passwordTextField.text ?? ""
        
        if netid.characters.count > 0 && password.characters.count > 0 {

            headerLabel.text = ""
            privacyStatementButton.setTitle("Logging in, this may take a minute", for: .normal)
            activityIndicator.startAnimating()
            
            delegate?.brbLoginViewClickedLogin(brbLoginView: self, netid: netid, password: password)
            isUserInteractionEnabled = false
            
            UserDefaults.standard.set(perpetualLoginButton.isSelected, forKey: BRBAccountSettings.LOGIN_ON_STARTUP_KEY)
            UserDefaults.standard.synchronize()
            
        } else {
            if netid.characters.count == 0 {
                netidTextField.becomeFirstResponder()
            } else {
                passwordTextField.becomeFirstResponder()
            }
        }
    }
    
    func loginFailedWithError(error: String) {
        headerLabel.textColor = .red
        headerLabel.text = error
        privacyStatementButton.setTitle("Privacy Statement", for: .normal)
        activityIndicator.stopAnimating()
        
        isUserInteractionEnabled = true
        
        netidTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        UserDefaults.standard.removeObject(forKey: BRBAccountSettings.LOGIN_ON_STARTUP_KEY)
        UserDefaults.standard.synchronize()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordTextField {
            
            netidTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
            
            login()
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        netidTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
}
