//
//  BRBTableViewCell.swift
//  Eatery
//
//  Created by Arman Esmaili on 11/15/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

class BRBTableViewCell: UITableViewCell
{
    let bgView = UIView() // matches background color of table view
    let whiteView = UIView() // draws the white background

    let leftLabel = UILabel()
    let rightLabel = UILabel()
    let centerLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: reuseIdentifier == "MoreCell" ? .default : style, reuseIdentifier: reuseIdentifier)
        
        whiteView.backgroundColor = .white
        bgView.backgroundColor = UIColor.init(white: 0.93, alpha: 1)//self.backgroundColor
        bgView.addSubview(whiteView)
        backgroundView = bgView
        contentView.backgroundColor = .clear
        
        // add custom labels
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        centerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        rightLabel.textColor = .gray
        centerLabel.textColor = .eateryBlue
        centerLabel.textAlignment = .center

        contentView.addSubview(leftLabel)
        contentView.addSubview(rightLabel)
        contentView.addSubview(centerLabel)
        
        let viewsDict = [
            "left" : leftLabel,
            "right" : rightLabel,
            "center" : centerLabel,
            "bgView" : bgView,
            "whiteView" : whiteView
            ]
        // TODO: add constraints to avoid updating frames in BRBViewController
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[center]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraint(NSLayoutConstraint(item: centerLabel, attribute: .centerY, relatedBy: .equal, toItem:contentView, attribute: .centerY, multiplier: 1, constant:0))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[left]-[right]-|", options: [], metrics: nil, views: viewsDict))
        contentView.addConstraint(NSLayoutConstraint(item: leftLabel, attribute: .centerY, relatedBy: .equal, toItem: rightLabel, attribute: .centerY, multiplier: 1, constant:0))
        contentView.addConstraint(NSLayoutConstraint(item: rightLabel, attribute: .centerY, relatedBy: .equal, toItem:contentView, attribute: .centerY, multiplier: 1, constant:0))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        leftLabel.text = nil
        rightLabel.text = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
