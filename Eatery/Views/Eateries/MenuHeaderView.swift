//
//  MenuHeaderView.swift
//  Eatery
//
//  Created by Eric Appel on 11/18/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import SnapKit
import Crashlytics
import Kingfisher

protocol MenuButtonsDelegate: class {

    func favoriteButtonPressed(on menuHeaderView: MenuHeaderView)

}

class MenuHeaderView: UIView {
    
    var eatery: Eatery?
    var displayedDate: Date?

    weak var delegate: MenuButtonsDelegate?

    let backgroundImageView = UIImageView()
    let titleLabel = UILabel()
    let favoriteButton = UIButton()
    let paymentView = PaymentMethodsView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundImageView.contentMode = .scaleAspectFill
        addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.font = .boldSystemFont(ofSize: 34)
        titleLabel.textColor = .white
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.25
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(15)
        }

        favoriteButton.setImage(UIImage(named: "whiteStar"), for: .normal)
        addSubview(favoriteButton)
        favoriteButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.leading.equalTo(titleLabel.snp.trailing).offset(10)
            make.width.height.equalTo(27)
        }

        addSubview(paymentView)
        paymentView.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(favoriteButton.snp.trailing)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }
    
    func set(eatery: Eatery, date: Date) {
        self.eatery = eatery
        self.displayedDate = date
        
        updateFavoriteButtonImage()

        paymentView.paymentMethods = eatery.paymentMethods
        
        titleLabel.text = eatery.nickname

        if let url = URL(string: eateryImagesBaseURL + eatery.slug + ".jpg") {
            let placeholder = UIImage.image(withColor: UIColor(white: 0.97, alpha: 1.0))
            backgroundImageView.kf.setImage(with: url, placeholder: placeholder)
        }

        favoriteButton.imageEdgeInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
        favoriteButton.tintColor = .favoriteYellow

        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        switch eateryStatus {
        case .open, .closing:
            titleLabel.textColor = .white

        case .closed:
            titleLabel.textColor = UIColor.darkGray

            let closedView = UIView()
            closedView.backgroundColor = UIColor(white: 1.0, alpha: 0.65)
            backgroundImageView.addSubview(closedView)
            closedView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    func updateFavoriteButtonImage() {
        guard let eatery = eatery else {
            return
        }

        favoriteButton.setImage(eatery.favorite ? UIImage(named: "goldStar") : UIImage(named: "whiteStar"), for: .normal)
    }
    
    @IBAction func favoriteButtonPressed(_ sender: AnyObject) {
        guard var eatery = eatery else {
            return
        }

        eatery.favorite.toggle()
        
        updateFavoriteButtonImage()
        
        delegate?.favoriteButtonPressed(on: self)
        if eatery.favorite {
            Answers.logEateryFavorited(eateryId: eatery.slug)
        } else {
            Answers.logEateryUnfavorited(eateryId: eatery.slug)
        }

        self.eatery = eatery
    }
    
}
