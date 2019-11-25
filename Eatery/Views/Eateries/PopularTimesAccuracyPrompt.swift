//
//  PopularTimesAccuracyPrompt.swift
//  Eatery
//
//  Created by William Ma on 11/24/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

protocol PopularTimesAccuracyPromptDelegate: AnyObject {

    func popularTimesAccuracyPrompt(_ popularTimesAccuracyPrompt: PopularTimesAccuracyPrompt,
                                    didReceiveUserResponse userResponse: PopularTimesAccuracyPrompt.UserResponse)

}

class PopularTimesAccuracyPrompt: UIView {

    enum UserResponse: CaseIterable {

        case lessThanFiveMinutes
        case fiveToTenMinutes
        case moreThanTenMinutes

        fileprivate var title: String {
            switch self {
            case .lessThanFiveMinutes: return "<5m"
            case .fiveToTenMinutes: return "5-10m"
            case .moreThanTenMinutes: return ">10m"
            }
        }

    }

    private let promptLabel = UILabel()

    private let stackView = UIStackView()
    private var userResponseByButton = [UIButton: UserResponse]()

    weak var delegate: PopularTimesAccuracyPromptDelegate?

    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    override init(frame: CGRect) {
        super.init(frame: frame)

        promptLabel.text = "How long did you wait?"
        promptLabel.font = .systemFont(ofSize: 16)
        promptLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        addSubview(promptLabel)
        promptLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 16

        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(promptLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(8)
        }

        for userResponse in UserResponse.allCases {
            let button = UIButton()

            button.backgroundColor = .wash
            button.titleLabel?.font = .systemFont(ofSize: 16)
            button.setTitle(userResponse.title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            button.layer.cornerRadius = 8
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(userResponseButtonPressed), for: .touchUpInside)
            button.setContentCompressionResistancePriority(.required, for: .vertical)

            stackView.addArrangedSubview(button)
            userResponseByButton[button] = userResponse
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func userResponseButtonPressed(_ sender: UIButton) {
        guard let userResponse = userResponseByButton[sender] else {
            return
        }

        isUserInteractionEnabled = false

        feedbackGenerator.impactOccurred()

        UIView.animate(withDuration: 0.25, animations: {
            sender.backgroundColor = .eateryBlue
            sender.setTitleColor(.white, for: .normal)
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.popularTimesAccuracyPrompt(self, didReceiveUserResponse: userResponse)
        })
    }

}
