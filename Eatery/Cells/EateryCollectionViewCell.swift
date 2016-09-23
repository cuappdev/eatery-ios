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

class EateryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paymentIcon: UIImageView!
    
    @IBOutlet weak var searchTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setEatery(_ eatery: Eatery) {
        if let photo = eatery.photo {
            backgroundImageView.hnk_setImage(photo, key: eatery.slug)
        } else {
            backgroundImageView.image = nil
        }
        titleLabel.text = eatery.nickname
        statusView.layer.cornerRadius = statusView.frame.size.width / 2.0
        statusView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 1
        contentView.layer.masksToBounds = true
        
        if (eatery.paymentMethods.contains(.Swipes)) {
            paymentIcon.image = UIImage(named: "swipeIcon")
        } else if (eatery.paymentMethods.contains(.BRB)) {
            paymentIcon.image = UIImage(named: "brbIcon")
        } else if (eatery.paymentMethods.contains(.Cash) || eatery.paymentMethods.contains(.CreditCard)) {
            paymentIcon.image = UIImage(named: "cashIcon")
        } else {
            paymentIcon.image = UIImage()
        }
        
        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        switch eateryStatus {
        case .open(let message):
            statusView.backgroundColor = .openGreen
            timeLabel.text = message
        case .closed(let message):
            statusView.backgroundColor = .closedGray
            timeLabel.text = message
        }
    }
}
