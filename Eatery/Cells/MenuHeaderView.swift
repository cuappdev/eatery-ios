//
//  MenuHeaderView.swift
//  Eatery
//
//  Created by Eric Appel on 11/18/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import DiningStack

@objc protocol MenuButtonsDelegate {
    func favoriteButtonPressed()
    @objc optional func shareButtonPressed()
    @objc optional func directionsButtonPressed()
}

class MenuHeaderView: UIView {
    
    var eatery: Eatery!
    var delegate: MenuButtonsDelegate?
    var displayedDate: Date!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var closedView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet var paymentImageViews: [UIImageView]!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    func setUp(_ eatery: Eatery, date: Date) {
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
        locationLabel.text = eatery.address
        backgroundImageView.image = eatery.photo
        
        directionsButton.setBackgroundImage(UIImage.image(withColor: .white), for: .normal)
        favoriteButton.imageEdgeInsets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)
        shareButton.imageView?.contentMode = .scaleAspectFit
        shareButton.imageEdgeInsets = UIEdgeInsets(top: 4.0, left: 10.0, bottom: 4.0, right: 10.0)
        
        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        switch eateryStatus {
        case .open(let message):
            hoursLabel.text = "Open Now (\(message))"
            hoursLabel.textColor = UIColor.darkGray
            closedView.backgroundColor = UIColor(white: 0.0, alpha: 0.2)
        case .closed(let message):
            hoursLabel.text = "Closed Now (\(message))"
            hoursLabel.textColor = UIColor.gray
            closedView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
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
