//
//  LocationPublisherProxy.swift
//  Eatery Watch App Extension
//
//  Created by William Ma on 1/14/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import Combine
import CoreLocation

final class LocationPublisherProxy: NSObject {

    private lazy var manager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        return manager
    }()

    private let subject = CurrentValueSubject<CLLocation?, Never>(nil)

    private(set) lazy var publisher: AnyPublisher<CLLocation?, Never> = subject.eraseToAnyPublisher()

    private var lastLocationUpdate: Date?
    private var didRequestLocation = false

    func requestLocation() {
        if let lastLocationUpdate = lastLocationUpdate, lastLocationUpdate.addingTimeInterval(60) > Date() {
            return
        }

        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        case .denied, .restricted:
            subject.send(nil)
        case .notDetermined:
            didRequestLocation = true
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }

}

extension LocationPublisherProxy: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if didRequestLocation {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                manager.requestLocation()
            case .denied, .restricted, .notDetermined:
                subject.send(nil)
            @unknown default:
                break
            }

            didRequestLocation = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error, error.localizedDescription)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let last = locations.last {
            print(last)

            subject.send(last)
            lastLocationUpdate = Date()
        }
    }

}
