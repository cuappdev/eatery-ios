//
//  TodayExtensionTableViewCell.swift
//  Eatery
//
//  Created by Mark Bryan on 11/1/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

class TodayExtensionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    let circleView: CircleView
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        addSubview(circleView)
    }
    
    override func layoutSubviews() {
        let original = circleView.frame
        circleView.frame = CGRect(x: CGRectGetMinX(original),
            y: CGRectGetMidY(self.bounds) - CGRectGetHeight(original) / 2,
            width: CGRectGetWidth(original), height: CGRectGetHeight(original))
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        circleView = CircleView(frame: CGRect(x: 24, y: 16, width: 16, height: 16))
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        circleView = CircleView(frame: CGRect(x: 24, y: 16, width: 16, height: 16))
        super.init(coder: aDecoder)
    }
}
