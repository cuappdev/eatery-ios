//
//  EateryCollectionViewCell.swift
//  Eatery
//
//  Created by Eric Appel on 11/18/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import DiningStack

class EateryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setEatery(eatery: Eatery) {
        // photos are enormous so commenting temporarily until we thumbnail them
        backgroundImageView.image = eatery.photo
        titleLabel.text = eatery.nickname()
        
        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        switch eateryStatus {
        case .Open(let message):
            statusLabel.textColor = .openGreen()
            statusLabel.text = "Open"
            timeLabel.text = message
        case .Closed(let message):
            statusLabel.textColor = .closedRed()
            statusLabel.text = "Closed"
            if message == "Closed" {
                timeLabel.text = ""
            } else {
                timeLabel.text = message
            }
        }
    }
}
