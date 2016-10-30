//
//  EateryCollectionViewCell.swift
//  Eatery
//
//  Created by Eric Appel on 11/18/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import DiningStack
import Haneke
import CoreLocation

let metersInMile: Double = 1609.344

class EateryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet var paymentImageViews: [UIImageView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var eatery: Eatery!
    
    func update(userLocation: CLLocation?) {
        if let distance = userLocation?.distance(from: eatery.location) {
            distanceLabel.text = "\(Double(round(10*distance/metersInMile)/10)) mi"
        } else {
            distanceLabel.text = ""
        }
    }
    
    func set(eatery: Eatery, userLocation: CLLocation?) {
        self.eatery = eatery
        
        if let photo = eatery.photo {
            backgroundImageView.hnk_setImage(photo, key: eatery.slug)
        } else {
            backgroundImageView.image = nil
        }
        
        titleLabel.text = eatery.nickname
        
        update(userLocation: userLocation)
        
        contentView.layer.cornerRadius = 1
        contentView.layer.masksToBounds = true
        
        var methods = eatery.paymentMethods.filter {
            switch $0 {
            case .BRB, .Swipes, .Cash:
                return true
            default:
                return false
            }
        }
        
        for imageView in paymentImageViews {
            imageView.clipsToBounds = true
            if let method = methods.popLast() {
                switch method {
                case .Cash:
                    imageView.image = #imageLiteral(resourceName: "cashIcon")
                case .BRB:
                    imageView.image = #imageLiteral(resourceName: "brbIcon")
                case .Swipes:
                    imageView.image = #imageLiteral(resourceName: "swipeIcon")
                default:
                    imageView.isHidden = true
                }
            } else {
                imageView.isHidden = true
            }
        }
        
        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        switch eateryStatus {
        case .open(let message):
            timeLabel.text = message
        case .closed(let message):
            timeLabel.text = message
        }
    }
}
