//
//  MenuHeaderView.swift
//  Eatery
//
//  Created by Eric Appel on 11/18/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

class MenuHeaderView: UIView {

    var eatery: CampusEatery?
    var displayedDate: Date?

    let container = UIView()

    let titleLabel = UILabel()
    let favoriteButton = UIButton()
    let paymentView = PaymentMethodsView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.isOpaque = false
        titleLabel.font = .boldSystemFont(ofSize: 34)
        titleLabel.textColor = .white
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.25
        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(15)
        }

        favoriteButton.setImage(UIImage(named: "whiteStar"), for: .normal)
        favoriteButton.addTarget(self, action: #selector(favoriteButtonPressed(_:)), for: .touchUpInside)
        container.addSubview(favoriteButton)
        favoriteButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.leading.equalTo(titleLabel.snp.trailing).offset(10)
            make.width.height.equalTo(27)
        }

        container.addSubview(paymentView)
        paymentView.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(favoriteButton.snp.trailing)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

    func set(eatery: CampusEatery, date: Date) {
        self.eatery = eatery
        self.displayedDate = date

        updateFavoriteButtonImage()

        paymentView.paymentMethods = eatery.paymentMethods

        titleLabel.text = eatery.nickname

        favoriteButton.imageEdgeInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
        favoriteButton.tintColor = .favoriteYellow

        let eateryStatus = eatery.currentStatus()
        switch eateryStatus {
        case .open, .closingSoon:
            titleLabel.textColor = .white

        case .closed, .openingSoon:
            titleLabel.textColor = UIColor.lightGray
        }
    }

    func updateFavoriteButtonImage() {
        guard let eatery = eatery else {
            return
        }

        favoriteButton.setImage(
            eatery.isFavorite ? UIImage(named: "goldStar") : UIImage(named: "whiteStar"),
            for: .normal
        )
    }

    @objc private func favoriteButtonPressed(_ sender: AnyObject) {
        guard var eatery = eatery else {
            return
        }

        eatery.isFavorite.toggle()

        updateFavoriteButtonImage()

        self.eatery = eatery
    }

}
