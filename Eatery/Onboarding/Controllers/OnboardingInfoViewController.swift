//
//  OnboardingInfoViewController.swift
//  Eatery
//
//  Created by Reade Plunkett on 11/15/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import Lottie
import UIKit

class OnboardingInfoViewController: OnboardingViewController {

    private let stackView = UIStackView()
    private let animationView = AnimationView()
    private let nextButton = UIButton()

    private let animation: String

    init(title: String, subtitle: String, animation: String) {
        self.animation = animation
        super.init(title: title, subtitle: subtitle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpStackView()
        setUpAnimationView()
        setUpButton()

        contentView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(stackView)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.animationView.play()
        }
    }


    private func setUpStackView() {
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 40
        contentView.addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.center.width.equalToSuperview()
        }
    }

    private func setUpAnimationView() {
        animationView.animation = Animation.named(animation)
        animationView.contentMode = .scaleAspectFit
        animationView.transform = CGAffineTransform(scaleX: 2, y: 2)
        stackView.addArrangedSubview(animationView)

        animationView.snp.makeConstraints { make in
            make.height.equalTo(128)
        }
    }

    private func setUpButton() {
        nextButton.layer.borderWidth = 2
        nextButton.layer.borderColor = UIColor.white.cgColor
        nextButton.layer.cornerRadius = 30
        nextButton.setTitle("NEXT", for: .normal)
        nextButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .heavy)
        nextButton.titleLabel?.textColor = .white
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        stackView.addArrangedSubview(nextButton)

        nextButton.snp.makeConstraints { make in
            make.width.equalTo(240)
            make.height.equalTo(60)
        }
    }

    @objc private func didTapNextButton(sender: UIButton) {
        delegate?.onboardingViewControllerDidTapNext(self)
    }

}
