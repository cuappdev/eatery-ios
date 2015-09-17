//
//  EatNowDetailHeaderView.swift
//  Eatery
//
//  Created by Eric Appel on 7/19/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit

class EatNowDetailHeaderView: UIView {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var foregroundImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    func setEatery(eatery: Eatery) {
        backgroundImageView.image = eatery.image
        foregroundImageView.image = eatery.image
        foregroundImageView.layer.cornerRadius = foregroundImageView.frame.width / 2
        foregroundImageView.layer.borderColor = UIColor.whiteColor().CGColor
        foregroundImageView.layer.borderWidth = 3
        nameLabel.text = eatery.name
    }
}