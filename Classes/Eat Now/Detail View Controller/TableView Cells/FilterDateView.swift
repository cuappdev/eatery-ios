//
//  FilterDateView.swift
//  Eatery
//
//  Created by Annie Cheng on 11/28/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

@objc protocol FilterDateViewDelegate {
    optional func didFilterDate(sender: UIButton?)
}

class FilterDateView: UIView {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateButton: UIButton!
    
    var filterDateView: UIView!
    var delegate: FilterDateViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        filterDateView = loadViewFromNib()
        filterDateView.frame = bounds
        filterDateView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        
        addSubview(filterDateView)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "FilterDateView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    @IBAction func didFilterDate(sender: UIButton?) {
        delegate?.didFilterDate!(sender)
    }

}