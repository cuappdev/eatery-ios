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

    static let olinLibrary = CLLocation(latitude: 42.448078, longitude: -76.484291)

    func distance(from other: CLLocation) -> Measurement<UnitLength> {
        Measurement(value: distance(from: other), unit: UnitLength.meters)
    }

}

extension CLLocationCoordinate2D {

    static func midpoint(between p1: CLLocationCoordinate2D, and p2: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let cLon = p1.longitude * .pi / 180
        let cLat = p1.latitude * .pi / 180
        let eLon = p2.longitude * .pi / 180
        let eLat = p2.latitude * .pi / 180

        let dLon = eLon - cLon

        let x = cos(eLat) * cos(dLon)
        let y = cos(eLat) * sin(dLon)
        let centerLatitude = atan2(sin(cLat) + sin(eLat), sqrt((cos(cLat) + x) * (cos(cLat) + x) + y * y))
        let centerLongitude = cLon + atan2(y, cos(cLat) + x)

        var midpointCoordinates = CLLocationCoordinate2D()
        midpointCoordinates.latitude = centerLatitude * 180 / .pi
        midpointCoordinates.longitude = centerLongitude * 180 / .pi

        return midpointCoordinates
    }

    static func deltaLatLon(
        between p1: CLLocationCoordinate2D,
        and p2: CLLocationCoordinate2D
    ) -> (lat: Double, lon: Double) {
        (lat: abs(p1.latitude - p2.latitude), lon: abs(p1.longitude - p2.longitude))
    }

}
