//
//  BRBViewController.swift
//  Eatery
//
//  Created by William Ma on 9/1/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class BRBViewController: UIViewController {
    
    private enum State {
        case login
        case account(BRBAccount)
    }
    
    var accountManager: BRBAccountManager!
    private var requestStart: Date?
    private var account: BRBAccount?
    private var loggedIn = false
    
    private lazy var loginViewController = BRBLoginViewController()
    var accountViewController: BRBAccountViewController?
    
    private var state: State = .login
    
    private var activityIndicator: NVActivityIndicatorView?
    var isLoading: Bool? {
        didSet {
            if isLoading! && activityIndicator != nil {
                activityIndicator!.startAnimating()
            } else if !isLoading! && activityIndicator != nil{
                activityIndicator!.stopAnimating()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Meal Plan"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "infoIcon"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(aboutButtonPressed(_:)))
        navigationController?.navigationBar.prefersLargeTitles = true
        
        accountManager = BRBAccountManager()
        accountManager.delegate = self
        
        loginViewController.delegate = self
        addChildViewController(loginViewController)
        view.addSubview(loginViewController.view)
        loginViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        loginViewController.didMove(toParentViewController: self)
        
        if let account = accountManager.getCachedAccount() {
            self.setState(.account(account))
            loggedIn = true
            if isLoading == nil {
                isLoading = true
            }
        }
    }
    
    @objc private func aboutButtonPressed(_ sender: UIBarButtonItem) {
        let aboutVC = AboutTableViewController()
        aboutVC.delegate = self

        if case .finished = accountManager.stage {
            aboutVC.logoutEnabled = true
        } else if loggedIn {
            aboutVC.logoutEnabled = true
        } else {
            aboutVC.logoutEnabled = false
        }
        
        navigationController?.pushViewController(aboutVC, animated: true)
        navigationItem.title = "Back"
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
            
            activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 22, height: 22), type: .circleStrokeSpin, color: .white)
            let activityItem = UIBarButtonItem(customView: activityIndicator!)
            navigationItem.setLeftBarButton(activityItem, animated: true)
            
            let refreshControl = UIRefreshControl(frame: .zero)
            refreshControl.tintColor = .white
            refreshControl.addTarget(self, action: #selector(refreshBRBAccount), for: .valueChanged)
            self.accountViewController?.tableView.refreshControl = refreshControl
            navigationItem.title = "Hello, \(accountManager.getCredentials()!.netid)"
            
            loginViewController.view.isHidden = true
            
        case (.account, .login):
            if let accountViewController = accountViewController {
                accountViewController.willMove(toParentViewController: nil)
                accountViewController.view.removeFromSuperview()
                accountViewController.removeFromParentViewController()
                navigationItem.title = "Menu Plan"
                self.accountViewController = nil
            }
            
            loginViewController.view.isHidden = false
            
        case (.account, .account), (.login, .login):
            break
            
        }
        
        state = newState
    }
    
    func showErrorAlert(error: String) {
        let errorAlert = UIAlertController(title: error, message: "Unable to fetch new BRB account data. Please check your connection and try again.", preferredStyle: UIAlertControllerStyle.alert)
        errorAlert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.destructive, handler: nil))
        self.present(errorAlert, animated: true, completion: nil)
        isLoading = false
    }
    
    @objc private func refreshBRBAccount(_ sender: Any) {
        accountManager.queryBRBDataWithSavedLogin()
        accountViewController?.tableView.refreshControl?.endRefreshing()
        isLoading = true
    }

}

extension BRBViewController: BRBLoginViewControllerDelegate {
    
    func loginViewController(_ loginViewController: BRBLoginViewController,
                             didRequestLoginWithNetid netid: String,
                             password: String) {
        accountManager.saveLoginInfo(loginInfo: LoginInfo(netid: netid, password: password))
        accountManager.queryBRBData(netid: netid, password: password)
        
        loginViewController.isLoading = true
        
        requestStart = Date()
    }
    
}

extension BRBViewController: BRBAccountManagerDelegate {
    
    func BRBAccountManagerDidQueryAccount(account: BRBAccount) {
        self.loginViewController.isLoading = false
        self.setState(.account(account))
        isLoading = false
    func retrievedSessionId(id: String) {
        loginViewController.setShowErrorMessage(false, animated: true)
        
        NetworkManager.shared.getBRBAccountInfo(sessionId: id) { [weak self] (account, error) in
            guard let self = self else {
                return
            }
            
            if let account = account {
                self.loginViewController.isLoading = false
                self.setState(.account(account))
            } else {
                self.loginFailed(with: error?.message ?? "")
            }
        }
    }
    
    func BRBAccountManagerDidFailToQueryAccount(with error: String) {
        isLoading = false
        if loggedIn {
            showErrorAlert(error: error)
        } else {
            loginViewController.errorDescription = error
            loginViewController.setShowErrorMessage(true, animated: true)
            loginViewController.isLoading = false
        }
    }
    
}

extension BRBViewController: AboutTableViewControllerDelegate {

    func aboutTableViewControllerDidLogoutUser(_ stvc: AboutTableViewController) {
        setState(.login)
        navigationItem.title = "Meal Plan"
        accountManager.removeSavedLoginInfo()
        accountManager.resetConnectionHandler()
        loggedIn = false
        isLoading = false
        navigationController?.popToViewController(self, animated: true)
    }
    
    func aboutTaleViewControllerDidTapBackButton(_ stvc: AboutTableViewController) {
        if let credentials = accountManager.getCredentials() {
            navigationItem.title = "Hello, \(credentials.netid)"
        } else {
            navigationItem.title = "Meal Plan"
        }
    }
    
}
