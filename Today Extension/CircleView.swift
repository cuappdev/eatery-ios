//
//  CircleView.swift
//  Eatery
//
//  Created by Mark Bryan on 11/1/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

enum State {
    case Open
    case Closed
}

class CircleView: UIView {
    
    var state: State {
        didSet {
            switch state {
            case .Open:
                backgroundColor = .openGreen()
            case .Closed:
                backgroundColor = .closedGray()
            }
        }
    }
    
    override func layoutSublayersOfLayer(layer: CALayer) {
        layer.cornerRadius = layer.frame.size.height/2
        //layer.opacity = 0.4
    }
    
    override init(frame: CGRect) {
        self.state = .Closed
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.state = .Closed
        super.init(coder: aDecoder)
    }
    
}
