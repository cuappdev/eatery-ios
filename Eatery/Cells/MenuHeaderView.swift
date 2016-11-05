//
//  MenuHeaderView.swift
//  Eatery
//
//  Created by Eric Appel on 11/18/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import DiningStack
import CoreLocation

@objc protocol MenuButtonsDelegate {
    func favoriteButtonPressed()
    @objc optional func shareButtonPressed()
}

class MenuHeaderView: UIView {
    
    var eatery: Eatery!
    var delegate: MenuButtonsDelegate?
    var displayedDate: Date!
    
    var mapButtonPressed: (Void) -> Void = {}

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet var paymentImageViews: [UIImageView]!
    
    func update(userLocation: CLLocation?) {
        if let distance = userLocation?.distance(from: eatery.location) {
            distanceLabel.text = "\(Double(round(10*distance/metersInMile)/10)) mi"
        } else {
            distanceLabel.text = "-- mi"
        }
    }
    
    func setUp(_ eatery: Eatery, date: Date) {
        self.eatery = eatery
        self.displayedDate = date

        // Status View
        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        switch eateryStatus {
        case .open(_):
            break
        case .closed(_):
            break
        }
        
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
        
        // Title Label
        titleLabel.text = eatery.nickname
        if eatery.slug == "RPCC-Marketplace" { titleLabel.text = "Robert Purcell Marketplace Eatery" }
        
        // Hours
        var hoursText = eatery.activeEventsForDate(date: displayedDate)
        if hoursText != "Closed" {
            hoursText = "Open \(hoursText)"
        }
        hoursLabel.text = hoursText
        
        // Background
        backgroundImageView.image = eatery.photo
        
    }
    
    @IBAction func favoriteButtonPressed(_ sender: AnyObject) {
        eatery.favorite = !eatery.favorite
        
        delegate?.favoriteButtonPressed()
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        delegate?.shareButtonPressed?()
    }
    
    @IBAction func mapButtonPressed(_ sender: UIButton) {
        mapButtonPressed()
    }
    
}
