//
//  BRBLoginView.swift
//  Eatery
//
//  Created by Dennis Fedorko on 4/27/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

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
        
        privacyStatementTextView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        privacyStatementTextView.isEditable = false
        privacyStatementTextView.text = "\n\nWhen you log in using our system, we will use your credentials solely to fetch your account information on your behalf. Your credentials will be stored safely on this device in a manner similar to how a web browser might cache your login information.\n\nYour netid and password will never leave your device, and will never be stored on our servers or viewed by anyone on our team.\n\nYou may log out of your account at any time to erase all of your account information from this device."
        privacyStatementTextView.textAlignment = .justified
        privacyStatementTextView.font = UIFont.systemFont(ofSize: 14)
        privacyStatementTextView.backgroundColor = UIColor(white: 0.93, alpha: 1)
        privacyStatementTextView.textContainerInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        headerLabel.frame = CGRect(x: 0, y: frame.width * 0.08, width: frame.width * 0.8, height: 40)
        headerLabel.center = CGPoint(x: frame.width / 2.0, y: headerLabel.center.y)
        headerLabel.text = "Log in with your Cornell NetID to see your account balance and history"
        headerLabel.numberOfLines = 2
        headerLabel.textAlignment = .center
        headerLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(headerLabel)
        
        privacyStatementButton.frame = CGRect(x: 0, y: headerLabel.frame.maxY + 5, width: frame.width * 0.8, height: 15)
        privacyStatementButton.center = CGPoint(x: frame.width / 2.0, y: privacyStatementButton.center.y)
        privacyStatementButton.setTitle("Privacy Statement", for: .normal)
        privacyStatementButton.setTitleColor(.eateryBlue, for: .normal)
        privacyStatementButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        privacyStatementButton.setTitleColor(.black, for: .highlighted)
        privacyStatementButton.addTarget(self, action: #selector(privacyStatementButtonPressed), for: .touchUpInside)
        addSubview(privacyStatementButton)
        
        netidPrompt.frame = CGRect(x: 25, y: privacyStatementButton.frame.maxY + 15, width: frame.width - 50, height: 14)
        netidPrompt.text = "NET ID"
        netidPrompt.textColor = .darkGray
        netidPrompt.font = UIFont.systemFont(ofSize: 12)
        addSubview(netidPrompt)

        netidTextField.frame = CGRect(x: 25, y: netidPrompt.frame.maxY, width: frame.width - 50, height: 45)
        netidTextField.textColor = .darkGray
        netidTextField.placeholder = "type your netid (e.g. abc123)"
        netidTextField.font = UIFont.systemFont(ofSize: 15)
        netidTextField.autocapitalizationType = .none
        netidTextField.tintColor = .darkGray
        netidTextField.delegate = self
        netidTextField.autocorrectionType = .no
        let netidLine = UIView()
        netidLine.backgroundColor = .darkGray
        netidLine.frame = CGRect(x: 0, y: netidTextField.bounds.maxY - 1, width: netidTextField.bounds.width, height: 1)
        netidTextField.addSubview(netidLine)
        addSubview(netidTextField)

        passwordPrompt.frame = CGRect(x: 25, y: netidTextField.frame.maxY + 25, width: frame.width - 50, height: 14)
        passwordPrompt.text = "PASSWORD"
        passwordPrompt.textColor = .darkGray
        passwordPrompt.font = UIFont.systemFont(ofSize: 12)
        passwordTextField.delegate = self
        addSubview(passwordPrompt)
        
        passwordTextField.frame = CGRect(x: 25, y: passwordPrompt.frame.maxY, width: frame.width - 50, height: 45)
        passwordTextField.textColor = .darkGray
        passwordTextField.placeholder = "type your password"
        passwordTextField.font = UIFont.systemFont(ofSize: 15)
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none
        netidTextField.autocorrectionType = .no
        passwordTextField.tintColor = .darkGray
        let bottomLine = UIView()
        bottomLine.backgroundColor = .darkGray
        bottomLine.frame = CGRect(x: 0, y: passwordTextField.bounds.maxY - 1, width: passwordTextField.bounds.width, height: 1)
        passwordTextField.addSubview(bottomLine)
        addSubview(passwordTextField)

        // iphone 5s.height = 568
        perpetualLoginButton.frame = CGRect(x: 25, y: passwordTextField.frame.maxY + (frame.size.height <= 600 ? 20:38),
                                            width: 220, height: 20)
        perpetualLoginButton.setTitle("☐   Automatically log me in every time", for: .normal)
        /// NOTE: this checkbox solution is rather hacky, should be replaced with images in the future
        perpetualLoginButton.setTitle("☑ Automatically log me in every time", for: .selected)
        perpetualLoginButton.setTitleColor(.darkGray, for: .normal)
        perpetualLoginButton.setTitleColor(.black, for: .highlighted)
        perpetualLoginButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        perpetualLoginButton.titleLabel?.textAlignment = .left
        perpetualLoginButton.addTarget(self, action: #selector(BRBLoginView.keepMeSignedIn), for: .touchUpInside)
        addSubview(perpetualLoginButton)
        
        loginButton.frame = CGRect(x: 20, y: perpetualLoginButton.frame.maxY + 20, width: frame.width - 40, height: 55)
        loginButton.setTitle("Log in", for: .normal)
        loginButton.backgroundColor = .eateryBlue
        loginButton.setBackgroundImage(UIImage.image(withColor: .black), for: .highlighted)
        loginButton.titleLabel?.textAlignment = .center
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        loginButton.addTarget(self, action: #selector(BRBLoginView.login), for: .touchUpInside)
        addSubview(loginButton)
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.color = .black
        activityIndicator.center = headerLabel.center
        addSubview(activityIndicator)
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func privacyStatementButtonPressed() {
        
        let hideButton = UIButton(frame: privacyStatementTextView.frame)
        hideButton.addTarget(self, action: #selector(dismissPrivacyStatement(sender:)), for: .touchUpInside)
        
        addSubview(privacyStatementTextView)
        addSubview(hideButton)
    }
    
    func dismissPrivacyStatement(sender: UIButton) {
        sender.removeFromSuperview()
        privacyStatementTextView.removeFromSuperview()
    }
    
    func keepMeSignedIn() { // toggle
        if perpetualLoginButton.isSelected {
            perpetualLoginButton.isSelected = false
        } else {
            perpetualLoginButton.isSelected = true
        }
    }
    
    func login() {
        let netid = (netidTextField.text ?? "").lowercased()
        let password = passwordTextField.text ?? ""
        
        if netid.characters.count > 0 && password.characters.count > 0 {
            headerLabel.text = ""
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
        activityIndicator.stopAnimating()
        
        isUserInteractionEnabled = true
        
        UserDefaults.standard.removeObject(forKey: BRBAccountSettings.LOGIN_ON_STARTUP_KEY)
        UserDefaults.standard.synchronize()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordTextField {
            
            netidTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
            
            animateToAdjustToKeyboard(keyboardIsDisplaying: true)
            
            login()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateToAdjustToKeyboard(keyboardIsDisplaying: false)
    }
    
    func animateToAdjustToKeyboard(keyboardIsDisplaying: Bool) {
        
        if keyboardIsDisplaying {
            
            if headerLabel.alpha != 0 {
                return
            }
            
            UIView.animate(withDuration: 0.25) {
                self.frame.origin.y += self.privacyStatementButton.frame.minY
                self.headerLabel.alpha = 1.0
                self.privacyStatementButton.alpha = 1.0
                self.privacyStatementButton.isEnabled = true
            }
            
        } else {
            
            if headerLabel.alpha != 1 {
                return
            }
            
            UIView.animate(withDuration: 0.25) {
                self.frame.origin.y -= self.privacyStatementButton.frame.minY
                self.headerLabel.alpha = 0.0
                self.privacyStatementButton.alpha = 0.0
                self.privacyStatementButton.isEnabled = false
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        netidTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        animateToAdjustToKeyboard(keyboardIsDisplaying: true)
    }
    
}
