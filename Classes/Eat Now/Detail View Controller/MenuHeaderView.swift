//
//  MenuHeaderView.swift
//  Eatery
//
//  Created by Eric Appel on 11/18/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import DiningStack

protocol EateryFavoriteDelegate {
    func favoriteButtonPressed()
}

class MenuHeaderView: UIView {
    
    var eatery: Eatery!
    var delegate: EateryFavoriteDelegate?

    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var paymentView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var buttonOneOutlet: UIButton!
    
    override func awakeFromNib() {
        buttonOneOutlet.setImage(UIImage(named: "whiteStar"), forState: .Normal)
        
        statusView.layer.cornerRadius = statusView.frame.width / 2
    }
    
    func setUp(eatery: Eatery) {
        self.eatery = eatery

        // Status View
        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        switch eateryStatus {
        case .Open(_):
            statusView.backgroundColor = .openGreen()
        case .Closed(_):
            statusView.backgroundColor = .redColor()
        }
        
        // Payment View
        var paymentTypeViews: [UIImageView] = []
        
        if (eatery.paymentMethods.contains(.Cash) || eatery.paymentMethods.contains(.CreditCard)) {
            let cashIcon = UIImageView(image: UIImage(named: "cashIcon"))
            paymentTypeViews.append(cashIcon)
        }
        
        if (eatery.paymentMethods.contains(.BRB)) {
            let brbIcon = UIImageView(image: UIImage(named: "brbIcon"))
            paymentTypeViews.append(brbIcon)
        }
        
        if (eatery.paymentMethods.contains(.Swipes)) {
            let swipeIcon = UIImageView(image: UIImage(named: "swipeIcon"))
            paymentTypeViews.append(swipeIcon)
        }
        
        let payTypeView = UIView()
        let payViewSize: CGFloat = 25.0
        let payViewPadding: CGFloat = 10.0
        var payViewFrame = CGRectMake(0, 0, payViewSize, payViewSize)
        
        for payView in paymentTypeViews {
            payView.frame = CGRectMake(payViewFrame.origin.x, 0, payViewSize, payViewSize)
            payTypeView.addSubview(payView)
            payViewFrame.origin.x += payViewSize + payViewPadding
        }
        
        payTypeView.frame = CGRectMake(paymentView.frame.size.width - (payViewFrame.origin.x - 10), 0, payViewFrame.origin.x - 10, payViewFrame.height)
        paymentView.addSubview(payTypeView)
        
        // Title Label
        titleLabel.text = eatery.nameShort
        
        // Hours
        var hoursText = eatery.activeEventsForDate(NSDate())
        if hoursText != "Closed" {
            hoursText = "Open \(hoursText)"
        }
        hoursLabel.text = hoursText
        
        // Background
        backgroundImageView.image = eatery.photo
        
        // Action Buttons
        if eatery.favorite {
            buttonOneOutlet.setImage(UIImage(named: "goldStar"), forState: .Normal)
        } else {
            buttonOneOutlet.setImage(UIImage(named: "whiteStar"), forState: .Normal)
        }
    }
    
    @IBAction func buttonOnePressed(sender: AnyObject) {
        print("Favorite button pressed")
        if eatery.favorite {
            eatery.favorite = false
            buttonOneOutlet.setImage(UIImage(named: "whiteStar"), forState: .Normal)
        } else {
            eatery.favorite = true
            buttonOneOutlet.setImage(UIImage(named: "goldStar"), forState: .Normal)
        }
        
        delegate?.favoriteButtonPressed()
    }

}
