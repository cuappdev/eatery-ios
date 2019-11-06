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
    
    private var activityIndicator: NVActivityIndicatorView!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 22, height: 22), type: .circleStrokeSpin, color: .white)
        let activityItem = UIBarButtonItem(customView: activityIndicator!)
        navigationItem.setLeftBarButton(activityItem, animated: true)

        accountManager = BRBAccountManager()
        accountManager.delegate = self
        accountManager.queryBRBDataWithSavedLogin()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Meal Plan"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "infoIcon"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(aboutButtonPressed(_:)))
        navigationController?.navigationBar.prefersLargeTitles = true

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
            activityIndicator.startAnimating()
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
            self.accountViewController?.delegate = self
            addChildViewController(accountViewController)
            view.insertSubview(accountViewController.view, at: 0)
            accountViewController.view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            accountViewController.didMove(toParentViewController: self)

            if let credentials = accountManager.getCredentials() {
                navigationItem.title = "Hello, \(credentials.netid)"
            }
            
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
        activityIndicator.stopAnimating()
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
    
    func brbAccountManagerDidQuery(account: BRBAccount) {
        self.loginViewController.isLoading = false
        self.setState(.account(account))
        activityIndicator.stopAnimating()
    }
    
    func brbAccountManagerDidFailToQueryAccount(with error: String) {
        activityIndicator.stopAnimating()
        if loggedIn {
            showErrorAlert(error: error)
        } else {
            loginViewController.errorDescription = error
            loginViewController.setShowErrorMessage(true, animated: true)
            loginViewController.isLoading = false
        }
    }
    
}

extension BRBViewController: BRBAccountViewControllerDelegate {
    func brbAccountViewControllerDidRefresh() {
        accountManager.queryBRBDataWithSavedLogin()
        activityIndicator.startAnimating()
    }
}

extension BRBViewController: AboutTableViewControllerDelegate {

    func aboutTableViewControllerDidLogoutUser(_ stvc: AboutTableViewController) {
        setState(.login)
        navigationItem.title = "Meal Plan"
        accountManager.removeSavedLoginInfo()
        accountManager.resetConnectionHandler()
        loggedIn = false
        activityIndicator.stopAnimating()
        navigationController?.popToViewController(self, animated: true)
    }
    
    func aboutTableViewControllerDidTapBackButton(_ stvc: AboutTableViewController) {
        if let credentials = accountManager.getCredentials() {
            navigationItem.title = "Hello, \(credentials.netid)"
        } else {
            navigationItem.title = "Meal Plan"
        }
    }
    
}
