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
    
    var netidTextField: UITextField!
    var passwordTextField: UITextField!
    var loginButton: UIButton!
    var infoLabel: UILabel!
    var errorLabel: UILabel!
    var activityIndicator: UIActivityIndicatorView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(white: 0.93, alpha: 1)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.alpha = 0.0
        
        netidTextField = UITextField(frame: CGRect(x: 0, y: frame.height * 0.25, width: frame.width * 0.8, height: 40))
        passwordTextField = UITextField(frame: CGRect(x: 0, y: netidTextField.frame.origin.y + netidTextField.frame.height + 30, width: frame.width * 0.8, height: 40))
        loginButton = UIButton(frame: CGRect(x: 0, y: passwordTextField.frame.origin.y + passwordTextField.frame.height + 40, width: 100, height: 50))
        infoLabel = UILabel(frame: CGRect(x: 0, y: netidTextField.frame.origin.y - 100, width: frame.width, height: 50))
        errorLabel = UILabel(frame: CGRect(x: 0, y: infoLabel.frame.origin.y + infoLabel.frame.height + 10, width: frame.width, height: 30))
        
        
        netidTextField.center = CGPoint(x: center.x, y: netidTextField.center.y)
        passwordTextField.center = CGPoint(x: center.x, y: passwordTextField.center.y)
        loginButton.center = CGPoint(x: center.x, y: loginButton.center.y)
        infoLabel.center = CGPoint(x: center.x, y: infoLabel.center.y)
        activityIndicator.center = loginButton.center
        
        netidTextField.layer.cornerRadius = 10
        passwordTextField.layer.cornerRadius = 10
        loginButton.layer.cornerRadius = 10
        
        netidTextField.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        passwordTextField.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        loginButton.backgroundColor = .black
        
        infoLabel.text = "BRB Login"
        infoLabel.font = UIFont.systemFont(ofSize: 40)
        infoLabel.textAlignment = NSTextAlignment.center
        
        errorLabel.text = ""
        errorLabel.font = UIFont.systemFont(ofSize: 15)
        errorLabel.textAlignment = NSTextAlignment.center
        errorLabel.textColor = UIColor.orange
        
        netidTextField.placeholder = "netid"
        netidTextField.isSecureTextEntry = false
        netidTextField.autocapitalizationType = .none
        netidTextField.textAlignment = .center
        passwordTextField.placeholder = "password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none
        passwordTextField.textAlignment = .center
        passwordTextField.delegate = self
        
        
        loginButton.setTitle("Login", for: UIControlState())
        loginButton.showsTouchWhenHighlighted = true
        loginButton.addTarget(self, action: #selector(BRBLoginView.login), for: UIControlEvents.touchDown)
        
        addSubview(netidTextField)
        addSubview(passwordTextField)
        addSubview(loginButton)
        addSubview(infoLabel)
        addSubview(errorLabel)
        addSubview(activityIndicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func login() {
        let netid = (netidTextField.text ?? "").lowercased()
        let password = passwordTextField.text ?? ""
        errorLabel.text = ""
        
        UIView.animate(withDuration: 0.5, animations: {
            self.loginButton.alpha = 0.0
            self.activityIndicator.alpha = 1.0
        }) 
        
        activityIndicator.startAnimating()
        delegate?.brbLoginViewClickedLogin(brbLoginView: self, netid: netid, password: password)
        isUserInteractionEnabled = false
    }
    
    func loginFailedWithError(error: String) {
        errorLabel.text = error
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.loginButton.alpha = 1.0
            self.activityIndicator.alpha = 0.0
        }, completion: { (complete: Bool) -> Void in
            self.activityIndicator.stopAnimating()
        }) 
        isUserInteractionEnabled = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordTextField {
            login()
        }
        return true
    }
}
