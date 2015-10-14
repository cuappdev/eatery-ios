//
//  EatNowTableViewCell.swift
//  Eatery
//
//  Created by Eric Appel on 11/3/14.
//  Copyright (c) 2014 CUAppDev. All rights reserved.
//

import UIKit

private let kNameTopSpaceConstraintConstant: CGFloat = 8
private let kHoursTopSpaceConstraintConstant: CGFloat = 8

class EatNowTableViewCell: UITableViewCell {

    @IBOutlet weak var eateryImage: UIImageView!
    @IBOutlet weak var eateryName: UILabel!
    @IBOutlet weak var eateryHours: UILabel!
    
    @IBOutlet weak var nameTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var hoursBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    var favoriteClickAction: ((sender: EatNowTableViewCell) -> ())?
    
    @IBAction func favoriteButtonPressed(sender: UIButton?) {
        favoriteClickAction?(sender: self)
    }

    func loadItem(image image: UIImage, name: String, paymentMethods: [String], hours: String) {
        eateryImage.image = image
        eateryName.text = name
        eateryHours.text = hours
        
//        if eateryImage.frame.origin.y < nameTopSpaceConstraint.constant {
//            nameTopSpaceConstraint.constant += 12 - eateryImage.frame.origin.y
//        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        nameTopSpaceConstraint.constant = kNameTopSpaceConstraintConstant
        hoursBottomSpaceConstraint.constant = kHoursTopSpaceConstraintConstant
        eateryImage.image = nil
        eateryName.text = ""
        eateryHours.text = ""
    }
}
