//
//  CLLocation+Distance.swift
//  Eatery
//
//  Created by William Ma on 1/25/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import CoreLocation
import Foundation

extension CLLocation {

    static let olinLibrary = CLLocation(latitude: 42.448078,longitude: -76.484291)

    func distance(from other: CLLocation, in unit: UnitLength) -> CLLocationDistance {
        return Measurement(value: distance(from: other), unit: UnitLength.meters).converted(to: unit).value
    }

}
