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
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.alpha = 0.0
        
        netidTextField = UITextField(frame: CGRectMake(0, frame.height * 0.25, frame.width * 0.8, 40))
        passwordTextField = UITextField(frame: CGRectMake(0, netidTextField.frame.origin.y + netidTextField.frame.height + 30, frame.width * 0.8, 40))
        loginButton = UIButton(frame: CGRectMake(0, passwordTextField.frame.origin.y + passwordTextField.frame.height + 40, 100, 75))
        infoLabel = UILabel(frame: CGRectMake(0, netidTextField.frame.origin.y - 100, frame.width, 50))
        errorLabel = UILabel(frame: CGRectMake(0, infoLabel.frame.origin.y + infoLabel.frame.height + 10, frame.width, 30))
        
        
        netidTextField.center = CGPointMake(center.x, netidTextField.center.y)
        passwordTextField.center = CGPointMake(center.x, passwordTextField.center.y)
        loginButton.center = CGPointMake(center.x, loginButton.center.y)
        infoLabel.center = CGPointMake(center.x, infoLabel.center.y)
        activityIndicator.center = loginButton.center
        
        netidTextField.layer.cornerRadius = 10
        passwordTextField.layer.cornerRadius = 10
        loginButton.layer.cornerRadius = 10
        
        netidTextField.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        passwordTextField.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
        loginButton.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.9)
        
        infoLabel.text = "BRB Login"
        infoLabel.font = UIFont.systemFontOfSize(40)
        infoLabel.textAlignment = NSTextAlignment.Center
        
        errorLabel.text = ""
        errorLabel.font = UIFont.systemFontOfSize(15)
        errorLabel.textAlignment = NSTextAlignment.Center
        errorLabel.textColor = UIColor.orangeColor()
        
        netidTextField.placeholder = "netid"
        netidTextField.secureTextEntry = false
        netidTextField.autocapitalizationType = .None
        netidTextField.textAlignment = .Center
        passwordTextField.placeholder = "password"
        passwordTextField.secureTextEntry = true
        passwordTextField.autocapitalizationType = .None
        passwordTextField.textAlignment = .Center
        passwordTextField.delegate = self
        
        
        loginButton.setTitle("Login", forState: UIControlState.Normal)
        loginButton.showsTouchWhenHighlighted = true
        loginButton.addTarget(self, action: #selector(BRBLoginView.login), forControlEvents: UIControlEvents.TouchDown)
        
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
        let netid = (netidTextField.text ?? "").lowercaseString
        let password = passwordTextField.text ?? ""
        errorLabel.text = ""
        
        UIView.animateWithDuration(0.5) {
            self.loginButton.alpha = 0.0
            self.activityIndicator.alpha = 1.0
        }
        
        activityIndicator.startAnimating()
        delegate?.brbLoginViewClickedLogin(self, netid: netid, password: password)
        userInteractionEnabled = false
    }
    
    func loginFailedWithError(error: String) {
        errorLabel.text = error
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.loginButton.alpha = 1.0
            self.activityIndicator.alpha = 0.0
        }) { (complete: Bool) -> Void in
            self.activityIndicator.stopAnimating()
        }
        userInteractionEnabled = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == passwordTextField {
            login()
        }
        return true
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
