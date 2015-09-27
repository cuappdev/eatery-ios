//
//  SegmentedHeader.swift
//  Eatery
//
//  Created by Joseph Antonakakis on 5/2/15.
//  Copyright (c) 2015 CUAppDev. All rights reserved.
//

import UIKit

class SegmentedHeader: UITableViewHeaderFooterView {
    
    var segmentedView: UISegmentedControl!
    
    init(frame: CGRect, meals: [String]) {
        segmentedView = UISegmentedControl(items: meals)
        super.init(reuseIdentifier: nil)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
