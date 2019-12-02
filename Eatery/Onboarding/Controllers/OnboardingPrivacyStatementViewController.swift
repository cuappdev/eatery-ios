//
//  OnboardingPrivacyStatementViewController.swift
//  Eatery
//
//  Created by Reade Plunkett on 11/26/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import SnapKit
import UIKit

class OnboardingPrivacyStatementViewController: BRBPrivacyStatementViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpCloseButton()
    }

    private func setUpCloseButton() {
        let closeButton = UIButton()
        closeButton.setImage(UIImage(named: "closeIcon.png"), for: .normal)
        closeButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        view.addSubview(closeButton)

        closeButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.topMargin.equalToSuperview().offset(10)
            make.rightMargin.equalToSuperview().offset(-10)
        }
    }

    @objc private func dismissSelf(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
