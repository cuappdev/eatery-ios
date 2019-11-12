//
//  OnboardingViewController.swift
//  Eatery
//
//  Created by Reade Plunkett on 11/11/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    private var stackView: UIStackView!

    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!
    private var imageView: UIImageView!
    private var nextButton: UIButton!

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
        stackView.alignment = .fill
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
    }

    private func setUpImageView() {
        imageView = UIImageView(image: model.image)
        imageView.contentMode = .scaleAspectFit
        stackView.addArrangedSubview(imageView)
    }

    private func setUpButton() {
        nextButton = UIButton(frame: CGRect(x: 0, y: 0, width: 240, height: 60))
        nextButton.layer.borderWidth = 2
        nextButton.layer.borderColor = UIColor.white.cgColor
        nextButton.layer.cornerRadius = 29
        nextButton.setTitle("NEXT", for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .heavy)
        nextButton.titleLabel?.textColor = .white
        stackView.addArrangedSubview(nextButton)
    }

}
