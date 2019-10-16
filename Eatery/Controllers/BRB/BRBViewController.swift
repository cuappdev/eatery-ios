//
//  BRBViewController.swift
//  Eatery
//
//  Created by William Ma on 9/1/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import Crashlytics
import UIKit

class BRBViewController: UIViewController {
    
    private enum State {
        case login
        case account(BRBAccount)
    }
    
    private var connectionHandler: BRBConnectionHandler!
    private var requestStart: Date?
    
    private lazy var loginViewController = BRBLoginViewController()
    private var accountViewController: BRBAccountViewController?
    
    private var state: State = .login

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Meal Plan"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "infoIcon"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(aboutButtonPressed(_:)))
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        connectionHandler = BRBConnectionHandler()
        connectionHandler.delegate = self

        loginViewController.delegate = self
        addChildViewController(loginViewController)
        view.addSubview(loginViewController.view)
        loginViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        loginViewController.didMove(toParentViewController: self)
    }
    
    @objc private func aboutButtonPressed(_ sender: UIBarButtonItem) {
        let aboutVC = AboutTableViewController()
        aboutVC.delegate = self
        
        if case .finished = connectionHandler.stage {
            aboutVC.logoutEnabled = true
        } else {
            aboutVC.logoutEnabled = false
        }
        
        navigationController?.pushViewController(aboutVC, animated: true)
    }
    
    private func setState(_ newState: State) {
        switch (state, newState) {
        case (.login, .account(let account)):
            let accountViewController = BRBAccountViewController(account: account)
            self.accountViewController = accountViewController
            
            addChildViewController(accountViewController)
            view.insertSubview(accountViewController.view, at: 0)
            accountViewController.view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            accountViewController.didMove(toParentViewController: self)
            
            loginViewController.view.isHidden = true
            
        case (.account, .login):
            if let accountViewController = accountViewController {
                accountViewController.willMove(toParentViewController: nil)
                accountViewController.view.removeFromSuperview()
                accountViewController.removeFromParentViewController()
                
                self.accountViewController = nil
            }
            
            loginViewController.view.isHidden = false
            
        case (.account, .account), (.login, .login):
            break
            
        }
        
        state = newState
    }

}

extension BRBViewController: BRBLoginViewControllerDelegate {
    
    func loginViewController(_ loginViewController: BRBLoginViewController,
                             didRequestLoginWithNetid netid: String,
                             password: String) {
        connectionHandler.netid = netid
        connectionHandler.password = password
        connectionHandler.handleLogin()
        
        loginViewController.isLoading = true
        
        requestStart = Date()
    }
    
}

extension BRBViewController: BRBConnectionDelegate {
    
    func retrievedSessionId(id: String) {
        loginViewController.setShowErrorMessage(false, animated: true)
        
        NetworkManager.shared.getBRBAccountInfo(sessionId: id) { [weak self] (account, error) in
            guard let self = self else {
                return
            }
            
            if let account = account {
                self.loginViewController.isLoading = false
                self.setState(.account(account))
                
                if let requestStart = self.requestStart {
                    Answers.login(succeeded: true, timeLapsed: Date().timeIntervalSince(requestStart))
                }
                
            } else {
                self.loginFailed(with: error?.message ?? "")
            }
        }
    }
    
    func loginFailed(with error: String) {
        loginViewController.errorDescription = error
        loginViewController.setShowErrorMessage(true, animated: true)
        loginViewController.isLoading = false
    }
    
}

extension BRBViewController: AboutTableViewControllerDelegate {
    
    func aboutTableViewControllerDidLogoutUser(_ stvc: AboutTableViewController) {
        setState(.login)
        
        connectionHandler = BRBConnectionHandler()
        connectionHandler.delegate = self
        
        navigationController?.popToViewController(self, animated: true)
    }
    
}
