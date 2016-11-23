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
    
    var activityIndicator = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(white: 0.93, alpha: 1)
        
        headerLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: 90)
        headerLabel.text = "Login to see your balance."
        headerLabel.numberOfLines = 0
        headerLabel.textAlignment = .center
        headerLabel.font = UIFont.systemFont(ofSize: 15)
        addSubview(headerLabel)
        
        netidPrompt.frame = CGRect(x: 25, y: headerLabel.frame.maxY, width: frame.width - 50, height: 14)
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
        passwordTextField.placeholder = "your password"
        passwordTextField.font = UIFont.systemFont(ofSize: 15)
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none
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
        
        loginButton.frame = CGRect(x: 20, y: perpetualLoginButton.frame.maxY + 25, width: frame.width - 40, height: 55)
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
            login()
        }
        return true
    }
}
