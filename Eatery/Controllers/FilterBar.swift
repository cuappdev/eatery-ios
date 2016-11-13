//
//  FilterBar.swift
//  Eatery
//
//  Created by Daniel Li on 11/6/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit

fileprivate let filters = [
    "Nearest",
    "North",
    "West",
    "Central",
    "Swipes",
    "Brb",
    "Cash"
]

protocol FilterBarDelegate {
    func updateFilters(filters: [String])
}

class FilterBar: UIView {
    var buttons: [UIButton] = []
    
    var scrollView: UIScrollView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(white: 0.93, alpha: 1)
        
        scrollView = UIScrollView(frame: CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height))
        scrollView.contentInset.left = 10.0
        scrollView.contentInset.right = 10.0
        
        for (index, filter) in filters.enumerated() {
            let button = UIButton()
            button.setTitle(filter, for: .normal)
            button.setTitleColor(UIColor.eateryBlue, for: .normal)
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.eateryBlue.cgColor
            button.layer.cornerRadius = 4.0
            button.clipsToBounds = true
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
            button.sizeToFit()
            button.frame.size.width += 10.0
            button.frame.size.height = frame.height - 20.0
            button.center.y = frame.height / 2
            if index > 0 {
                button.frame.origin.x = buttons[index - 1].frame.maxX + 5.0
            } else {
                button.frame.origin.x = 0.0
            }
            
            button.tag = index
            button.setBackgroundImage(UIImage.image(withColor: UIColor.eateryBlue), for: .selected)
            button.setTitleColor(UIColor.white, for: .selected)
            button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
            
            scrollView.addSubview(button)
            buttons.append(button)
        }
        
        scrollView.contentSize = CGSize(width: buttons.last?.frame.maxX ?? 0.0, height: frame.height)
        addSubview(scrollView)
    }
    
    func buttonPressed(sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
