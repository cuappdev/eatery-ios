//
//  FilterEateriesTableViewCell.swift
//  Eatery
//
//  Created by Annie Cheng on 11/28/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

@objc protocol FilterEateriesViewDelegate {
    optional func didFilterMeal(sender: UIButton?)
    optional func didFilterDate(sender: UIButton?)
}

class FilterEateriesTableViewCell: UITableViewCell {

    @IBOutlet weak var firstDateView: FilterDateView!
    @IBOutlet weak var secondDateView: FilterDateView!
    @IBOutlet weak var thirdDateView: FilterDateView!
    @IBOutlet weak var fourthDateView: FilterDateView!
    @IBOutlet weak var fifthDateView: FilterDateView!
    @IBOutlet weak var sixthDateView: FilterDateView!
    @IBOutlet weak var seventhDateView: FilterDateView!
    @IBOutlet weak var filterBreakfastButton: UIButton!
    @IBOutlet weak var filterLunchButton: UIButton!
    @IBOutlet weak var filterDinnerButton: UIButton!
    
    private var tapGestureRecognizer: UITapGestureRecognizer?
    var delegate: FilterEateriesViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .None
    }
    
    @IBAction func didFilterMeal(sender: UIButton?) {
        delegate?.didFilterMeal!(sender)
    }
    
    override func didMoveToWindow() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "filterEateriesCellPressed:")
        tapGestureRecognizer?.delegate = self
        tapGestureRecognizer?.cancelsTouchesInView = false
        addGestureRecognizer(tapGestureRecognizer!)
    }
    
    func filterEateriesCellPressed(sender: UITapGestureRecognizer) {
        let tapPoint = sender.locationInView(self)
        let hitView = hitTest(tapPoint, withEvent: nil)
        
        let filterDateButtons = [firstDateView.dateButton, secondDateView.dateButton, thirdDateView.dateButton, fourthDateView.dateButton, fifthDateView.dateButton, sixthDateView.dateButton, seventhDateView.dateButton]
        
        for button in filterDateButtons {
            if hitView == button {
                delegate?.didFilterDate!(button)
                break
            }
        }
        
    }

}
