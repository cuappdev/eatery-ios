//
//  MenuHeaderView.swift
//  Eatery
//
//  Created by Eric Appel on 11/18/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import DiningStack

protocol MenuButtonsDelegate {
    func favoriteButtonPressed()
    func shareButtonPressed()
}

class MenuHeaderView: UIView {
    
    var eatery: Eatery!
    var delegate: MenuButtonsDelegate?
    var displayedDate: NSDate!

    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var paymentView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    override func awakeFromNib() {
        favoriteButton.setImage(UIImage(named: "whiteStar"), forState: .Normal)
        shareButton.setImage(UIImage(named: "shareIcon"), forState: .Normal)
        statusView.layer.cornerRadius = statusView.frame.width / 2.0
    }
    
    func setUp(eatery: Eatery, date: NSDate) {
        self.eatery = eatery
        self.displayedDate = date

        // Status View
        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        switch eateryStatus {
        case .Open(_):
            statusView.backgroundColor = .openGreen()
        case .Closed(_):
            statusView.backgroundColor = .closedGray()
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
        var hoursText = eatery.activeEventsForDate(displayedDate)
        if hoursText != "Closed" {
            hoursText = "Open \(hoursText)"
        }
        hoursLabel.text = hoursText
        
        // Background
        backgroundImageView.image = eatery.photo
        
        // Action Buttons
        if eatery.favorite {
            favoriteButton.setImage(UIImage(named: "goldStar"), forState: .Normal)
        } else {
            favoriteButton.setImage(UIImage(named: "whiteStar"), forState: .Normal)
        }
    }
    
    @IBAction func favoriteButtonPressed(sender: AnyObject) {
        if eatery.favorite {
            eatery.favorite = false
            favoriteButton.setImage(UIImage(named: "whiteStar"), forState: .Normal)
        } else {
            eatery.favorite = true
            favoriteButton.setImage(UIImage(named: "goldStar"), forState: .Normal)
        }
        
        delegate?.favoriteButtonPressed()
    }
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        delegate?.shareButtonPressed()
    }

}
