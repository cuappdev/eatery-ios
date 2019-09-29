//
//  BRBPrivacyStatementViewController.swift
//  Eatery
//
//  Created by William Ma on 9/1/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class BRBPrivacyStatementViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        view.backgroundColor = .white
        
        let scrollView = UIScrollView(frame: .zero)
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 32, left: 16, bottom: 32, right: 16)
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
        
        let titleLabel = UILabel(frame: .zero)
        titleLabel.text = "Privacy Statement"
        titleLabel.textAlignment = .center
        titleLabel.font = .preferredFont(forTextStyle: .title3)
        stackView.addArrangedSubview(titleLabel)

        let textView = UITextView(frame: .zero)
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.text = """
        When you log in using our system, we will use your credentials solely to fetch your account information on your behalf. Your credentials will be stored safely on this device in a manner similar to how a web browser might cache your login information.
        
        Your netid and password will never leave your device, and will never be stored on our servers or viewed by anyone on our team.
        
        You may log out of your account at any time to erase all of your account information from this device.
        """
        textView.font = .preferredFont(forTextStyle: .body)
        textView.alwaysBounceVertical = true
        stackView.addArrangedSubview(textView)
    }

}
