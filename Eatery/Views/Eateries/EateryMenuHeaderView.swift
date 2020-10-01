//
//  EateryMenuHeaderView.swift
//  Eatery
//
//  Created by William Ma on 10/26/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import Hero
import UIKit

protocol EateryMenuHeaderViewDelegate: AnyObject {

    func favoriteButtonPressed(on sender: EateryMenuHeaderView)

}

class EateryMenuHeaderView: UIView {

    let exceptionsView = EateryExceptionsView()
    var exceptionsHero: HeroExtension<EateryExceptionsView> { exceptionsView.hero }

    private let titleLabel = UILabel()
    var titleHero: HeroExtension<UILabel> { titleLabel.hero }

    private let favoriteButton = UIButton()
    var favoriteHero: HeroExtension<UIButton> { favoriteButton.hero }

    private let paymentView = PaymentMethodsView()
    var paymentHero: HeroExtension<PaymentMethodsView> { paymentView.hero }

    weak var delegate: EateryMenuHeaderViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.isOpaque = false
        titleLabel.font = .boldSystemFont(ofSize: 34)
        titleLabel.textColor = .white
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.25
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(16)
        }

        exceptionsView.isOpaque = false
        addSubview(exceptionsView)
        exceptionsView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.bottom.equalTo(titleLabel.snp.top).offset(-4)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
        }

        favoriteButton.setImage(UIImage(named: "whiteStar"), for: .normal)
        favoriteButton.imageEdgeInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
        favoriteButton.tintColor = .favoriteYellow
        favoriteButton.addTarget(self, action: #selector(favoriteButtonPressed(_:)), for: .touchUpInside)
        addSubview(favoriteButton)
        favoriteButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.leading.equalTo(titleLabel.snp.trailing).offset(16)
            make.width.height.equalTo(28)
        }

        addSubview(paymentView)
        paymentView.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(favoriteButton.snp.trailing)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure(
        title: String,
        status: EateryStatus,
        isFavorite: Bool,
        paymentMethods: [PaymentMethod],
        exceptions: [String]
    ) {
        titleLabel.text = title
        switch status {
        case .open, .closingSoon: titleLabel.textColor = .white
        case .closed, .openingSoon: titleLabel.textColor = .lightGray
        }

        favoriteButton.setImage(
            UIImage(named: isFavorite ? "goldStar" : "whiteStar"),
            for: .normal
        )

        paymentView.paymentMethods = paymentMethods

        if let exception = exceptions.first {
            exceptionsView.isHidden = false

            switch exception {
            case "Cash Only After 3PM":
                exceptionsView.configure(
                    color: UIColor(hex: 0xFEC50E),
                    exception: exception,
                    image: UIImage(named: "warning")
                )

            case "Mobile Order Only":
                exceptionsView.configure(
                    color: UIColor(hex: 0x4A90E2),
                    exception: exception,
                    image: UIImage(named: "phone")
                )

            default:
                exceptionsView.configure(
                    color: UIColor(hex: 0xFEC50E),
                    exception: exception,
                    image: UIImage(named: "warning")
                )
            }

        } else {
            exceptionsView.isHidden = true
        }
    }

    func configure(eatery: Eatery) {
        configure(
            title: eatery.displayName,
            status: eatery.currentStatus(),
            isFavorite: eatery.isFavorite,
            paymentMethods: eatery.paymentMethods,
            exceptions: eatery.exceptions
        )
    }

    @objc private func favoriteButtonPressed(_ sender: UIButton) {
        delegate?.favoriteButtonPressed(on: self)
    }

}
