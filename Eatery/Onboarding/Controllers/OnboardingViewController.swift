//
//  OnboardingViewController.swift
//  Eatery
//
//  Created by Reade Plunkett on 11/11/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

protocol OnboardingViewControllerDelegate {
    func onboardingViewControllerDidTapNextButton(viewController: OnboardingViewController)
}

class OnboardingViewController: UIViewController {

    internal var stackView: UIStackView!

    internal var titleLabel: UILabel!
    internal var subtitleLabel: UILabel!
    internal var imageView: UIImageView!
    internal var nextButton: UIButton!

    var delegate: OnboardingViewControllerDelegate?

    let model: OnboardingModel!

    init(model: OnboardingModel,
         nibName nibNameOrNil: String?,
         bundle nibBundleOrNil: Bundle?) {
      self.model = model
      super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .eateryBlue

        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 40
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(127)
            make.width.equalToSuperview()
        }

        setUpTitleLabel()
        setUpSubtitleLabel()
        setUpImageView()
        setUpButton()
    }

    private func setUpTitleLabel() {
        titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.text = model.title
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        stackView.addArrangedSubview(titleLabel)
    }

    private func setUpSubtitleLabel() {
        subtitleLabel = UILabel(frame: CGRect.zero)
        subtitleLabel.text = model.subtitle
        subtitleLabel.textColor = .white
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        stackView.addArrangedSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(30)
        }
    }

    private func setUpImageView() {
        imageView = UIImageView(image: model.image)
        imageView.contentMode = .scaleAspectFit
        stackView.addArrangedSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.equalTo(124)
        }
    }

    internal func setUpButton() {
        nextButton = UIButton()
        nextButton.layer.borderWidth = 2
        nextButton.layer.borderColor = UIColor.white.cgColor
        nextButton.layer.cornerRadius = 30
        nextButton.setTitle("NEXT", for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .heavy)
        nextButton.titleLabel?.textColor = .white
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        stackView.addArrangedSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.width.equalTo(240)
            make.height.equalTo(60)
        }
    }

    @objc func didTapNextButton(sender: UIButton!) {
        delegate?.onboardingViewControllerDidTapNextButton(viewController: self)
    }

}
