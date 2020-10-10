//
//  Range+Eatery.swift
//  Eatery
//
//  Created by William Ma on 10/10/20.
//  Copyright © 2020 Cornell AppDev. All rights reserved.
//

import Foundation

extension ClosedRange {

    func clamp(_ value: Bound) -> Bound {
        Swift.min(upperBound, Swift.max(lowerBound, value))
    }

}
