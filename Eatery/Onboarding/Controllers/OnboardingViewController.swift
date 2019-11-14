//
//  OnboardingViewController.swift
//  Eatery
//
//  Created by Reade Plunkett on 11/11/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

protocol OnboardingViewControllerDelegate {
    func onboardingViewControllerDidTapNext(_ viewController: OnboardingViewController)
}

class OnboardingViewController: UIViewController {

    var stackView: UIStackView!
    var subtitleLabel: UILabel!
    
    private var titleLabel: UILabel!
    private var imageView: UIImageView!
    private var nextButton: UIButton!

    private var onboardingTitle: String!
    private var onboardingSubtitle: String!
    private var onboardingImage: UIImage?

    var delegate: OnboardingViewControllerDelegate?

    init(title: String, subtitle: String, image: UIImage?) {
      super.init(nibName: nil, bundle: nil)
        self.onboardingTitle = title
        self.onboardingSubtitle = subtitle
        self.onboardingImage = image
    }

    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .eateryBlue

        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 40
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().inset(30)
        }

        setUpTitleLabel()
        setUpSubtitleLabel()
        setUpImageView()
        setUpButton()
    }

    private func setUpTitleLabel() {
        titleLabel = UILabel()
        titleLabel.text = onboardingTitle
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 36, weight: .bold)
        stackView.addArrangedSubview(titleLabel)
    }

    private func setUpSubtitleLabel() {
        subtitleLabel = UILabel()
        subtitleLabel.text = onboardingSubtitle
        subtitleLabel.textColor = .white
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = .systemFont(ofSize: 24, weight: .medium)
        stackView.addArrangedSubview(subtitleLabel)
    }

    private func setUpImageView() {
        if let image = self.onboardingImage {
            imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            stackView.addArrangedSubview(imageView)

            imageView.snp.makeConstraints { make in
                make.height.equalTo(128)
            }
        }
    }

    internal func setUpButton() {
        nextButton = UIButton()
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
