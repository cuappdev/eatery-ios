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

@objc protocol MenuButtonsDelegate {
    @objc optional func favoriteButtonPressed()
}

class MenuHeaderView: UIView {
    
    var eatery: Eatery!
    weak var delegate: MenuButtonsDelegate?
    var displayedDate: Date!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet var paymentImageViews: [UIImageView]!
    @IBOutlet weak var paymentContainer: UIView!
    @IBOutlet weak var favoriteButton: UIButton!

    func set(eatery: Eatery, date: Date) {
        self.eatery = eatery
        self.displayedDate = date
        
        checkFavorites()
        
        var images: [UIImage] = []
        
        if (eatery.paymentMethods.contains(.Cash) || eatery.paymentMethods.contains(.CreditCard)) {
            images.append(#imageLiteral(resourceName: "cashIcon"))
        }
        
        if (eatery.paymentMethods.contains(.BRB)) {
            images.append(#imageLiteral(resourceName: "brbIcon"))
        }
        
        if (eatery.paymentMethods.contains(.Swipes)) {
            images.append(#imageLiteral(resourceName: "swipeIcon"))
        }
        
        for (index, imageView) in paymentImageViews.enumerated() {
            if index < images.count {
                imageView.image = images[index]
                imageView.isHidden = false
            } else {
                imageView.isHidden = true
            }
        }
        
        titleLabel.text = eatery.nickname

        if let url = URL(string: eateryImagesBaseURL + eatery.slug + ".jpg") {
            let placeholder = UIImage.image(withColor: UIColor(white: 0.97, alpha: 1.0))
            backgroundImageView.kf.setImage(with: url, placeholder: placeholder)
        }

        favoriteButton.imageEdgeInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
        favoriteButton.tintColor = .favoriteYellow

        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        switch eateryStatus {
        case .open:
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
    
    func checkFavorites() {
        favoriteButton.setImage(eatery.favorite ? #imageLiteral(resourceName: "goldStar") : #imageLiteral(resourceName: "whiteStar"), for: .normal)
    }
    
    @IBAction func favoriteButtonPressed(_ sender: AnyObject) {
        eatery.favorite = !eatery.favorite
        
        checkFavorites()
        
        delegate?.favoriteButtonPressed?()
    }
    
}
