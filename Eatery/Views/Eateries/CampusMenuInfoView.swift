//
//  MenuInfoView.swift
//  Eatery
//
//  Created by William Ma on 10/15/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import CoreLocation
import Hero
import UIKit

class CampusMenuInfoView: UIView, MenuInfoView {

    private let statusLabel = UILabel()
    private let hoursLabel = UILabel()
    private let locationLabel = UILabel()
    private let distanceLabel = UILabel()

    var statusHero: HeroExtension<UILabel> {
        return statusLabel.hero
    }

    var hoursHero: HeroExtension<UILabel> {
        return hoursLabel.hero
    }

    var locationHero: HeroExtension<UILabel> {
        return locationLabel.hero
    }

    var distanceHero: HeroExtension<UILabel> {
        return distanceLabel.hero
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        statusLabel.isOpaque = false
        statusLabel.textColor = .eateryBlue
        statusLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(16)
        }

        hoursLabel.isOpaque = false
        hoursLabel.textColor = .gray
        hoursLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        addSubview(hoursLabel)
        hoursLabel.snp.makeConstraints { make in
            make.centerY.equalTo(statusLabel)
            make.leading.equalTo(statusLabel.snp.trailing).offset(2)
        }

        locationLabel.isOpaque = false
        locationLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        locationLabel.textColor = .gray
        addSubview(locationLabel)
        locationLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalTo(statusLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().inset(16)
        }

        distanceLabel.isOpaque = false
        distanceLabel.textColor = .gray
        distanceLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        addSubview(distanceLabel)
        distanceLabel.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(hoursLabel.snp.trailing)
            make.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(eatery: Eatery, userLocation: CLLocation?) {
        guard let eatery = eatery as? CampusEatery else {
            return
        }

        let presentation = eatery.currentPresentation()
        statusLabel.text = presentation.statusText
        statusLabel.textColor = presentation.statusColor
        hoursLabel.text = presentation.nextEventText

        locationLabel.text = eatery.address

        if let userLocation = userLocation {
            let miles = userLocation.distance(from: eatery.location, in: .miles)
            distanceLabel.text = "\(Double(round(10 * miles) / 10)) mi"
        } else {
            distanceLabel.text = "-- mi"
        }
    }

}
