//
//  MenuHeaderView.swift
//  Eatery
//
//  Created by Eric Appel on 11/18/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import DiningStack
import Kingfisher

@objc protocol MenuButtonsDelegate {
    func favoriteButtonPressed()
    @objc optional func shareButtonPressed()
    @objc optional func directionsButtonPressed()
}

class MenuHeaderView: UIView {
    
    var eatery: Eatery!
    weak var delegate: MenuButtonsDelegate?
    var displayedDate: Date!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var closedView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundContainer: UIView!
    @IBOutlet var paymentImageViews: [UIImageView]!
    @IBOutlet weak var paymentContainer: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var timeImageView: UIImageView!
    @IBOutlet weak var locationImageView: UIImageView!
    
    func set(eatery: Eatery, date: Date) {
        self.eatery = eatery
        self.displayedDate = date
        
        backgroundColor = UIColor.groupTableViewBackground
        
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
        titleLabel.layer.shadowRadius = 12.0
        titleLabel.layer.shadowOpacity = 1.0
        locationLabel.text = eatery.address
        hoursLabel.textColor = UIColor.gray

        if let url = URL(string: eateryImagesBaseURL + eatery.slug + ".jpg") {
            let placeholder = UIImage.image(withColor: UIColor(white: 0.97, alpha: 1.0))
            backgroundImageView.kf.setImage(with: url, placeholder: placeholder)
        }
        
        timeImageView.tintColor = UIColor.gray
        locationImageView.tintColor = UIColor.gray
        
        directionsButton.tintColor = UIColor.eateryBlue
        directionsButton.setBackgroundImage(UIImage.image(withColor: .white), for: .normal)
        favoriteButton.tintColor = UIColor.eateryBlue
        favoriteButton.imageEdgeInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
        shareButton.imageView?.contentMode = .scaleAspectFit
        shareButton.imageEdgeInsets = UIEdgeInsets(top: 4.0, left: 10.0, bottom: 4.0, right: 10.0)
        shareButton.isHidden = true // Temporary before hotfix
        
        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        switch eateryStatus {
        case .open(let message):
            hoursLabel.text = "Open Now (\(message))"
            titleLabel.textColor = .white
            titleLabel.layer.shadowColor = UIColor.black.cgColor
            closedView.backgroundColor = .clear
        case .closed(let message):
            hoursLabel.text = "Closed Now (\(message))"
            titleLabel.textColor = UIColor.darkGray
            titleLabel.layer.shadowColor = UIColor.white.cgColor
            closedView.backgroundColor = UIColor(white: 1.0, alpha: 0.65)
        }

    }
    
    func checkFavorites() {
        favoriteButton.setImage(eatery.favorite ? #imageLiteral(resourceName: "goldStar") : #imageLiteral(resourceName: "whiteStar"), for: .normal)
    }
    
    @IBAction func favoriteButtonPressed(_ sender: AnyObject) {
        eatery.favorite = !eatery.favorite
        
        checkFavorites()
        
        delegate?.favoriteButtonPressed()
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        delegate?.shareButtonPressed?()
    }
    
    @IBAction func directionsButtonPressed(_ sender: UIButton) {
        delegate?.directionsButtonPressed?()
    }
    
}
