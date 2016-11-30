//
//  MealTableViewCell.swift
//  Eatery
//
//  Created by Eric Appel on 5/6/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit

class MealTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var titleLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
}
