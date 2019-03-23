//
//  CTownMenuHeaderView.swift
//  Eatery
//
//  Created by Gonzalo Gonzalez on 3/3/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class CTownMenuHeaderView: UIView {

    var backgroundImageView: UIImageView!
    var titleLabel: UILabel!
    var paymentView: PaymentMethodsView!
    var informationView: UIView!
    
    //Information View
    var statusLabel: UILabel!
    var hourLabel: UILabel!
    var cuisineLabel: UILabel!
    var locationLabel: UILabel!
    var ratingView: RatingView!
    var priceLabel: UILabel!
    var distanceLabel: UILabel!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundImageView = UIImageView()
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        addSubview(backgroundImageView)
        
        titleLabel = UILabel()
        titleLabel.isOpaque = false
        titleLabel.font = .boldSystemFont(ofSize: 34)
        titleLabel.textColor = .white
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.25
        addSubview(titleLabel)
        
        paymentView = PaymentMethodsView()
        addSubview(paymentView)
        
        informationView = UIView()
        informationView.backgroundColor = .white
        addSubview(informationView)
        
        statusLabel = UILabel()
        statusLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        addSubview(statusLabel)
        
        hourLabel = UILabel()
        hourLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        addSubview(hourLabel)
        
        cuisineLabel = UILabel()
        cuisineLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        cuisineLabel.lineBreakMode = .byWordWrapping
        cuisineLabel.numberOfLines = 0
        addSubview(cuisineLabel)
        
        locationLabel = UILabel()
        locationLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        locationLabel.textColor = .gray
        addSubview(locationLabel)
        
        ratingView = RatingView()
        addSubview(ratingView)
        
        priceLabel = UILabel()
        priceLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        priceLabel.text = "$$$"
        priceLabel.textColor = .gray
        addSubview(priceLabel)
        
        distanceLabel = UILabel()
        distanceLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        distanceLabel.textColor = .gray
        addSubview(distanceLabel)
        
        setupConstraints()
    }
    
    func setupConstraints(){
        backgroundImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(258)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(15)
        }
        
        paymentView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
        
        informationView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(backgroundImageView.snp.bottom)
            make.height.equalTo(105)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(informationView).inset(11)
            make.leading.equalTo(informationView).inset(12)
            make.trailing.lessThanOrEqualTo(informationView)
            make.height.equalTo(19)
        }
        
        hourLabel.snp.makeConstraints { make in
            make.centerY.equalTo(statusLabel)
            make.leading.equalTo(statusLabel.snp.trailing).offset(4.5)
            make.trailing.lessThanOrEqualTo(informationView)
            make.height.equalTo(17)
        }
        
        cuisineLabel.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(2)
            make.leading.equalTo(statusLabel)
            make.height.equalTo(45)
            make.width.equalTo(260)
        }
        
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(cuisineLabel.snp.bottom).offset(6)
            make.leading.equalTo(cuisineLabel)
            make.trailing.lessThanOrEqualTo(informationView)
            make.height.equalTo(17)
        }
        
        ratingView.snp.makeConstraints { make in
            make.centerY.equalTo(statusLabel)
            make.trailing.equalTo(informationView).inset(12)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(ratingView.snp.bottom).offset(13)
            make.trailing.equalToSuperview().inset(12.5)
            make.height.equalTo(19)
            make.width.equalTo(30.5)
        }
        
        distanceLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(13)
            make.trailing.equalToSuperview().inset(12.5)
            make.height.equalTo(17)
            make.width.lessThanOrEqualToSuperview()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
