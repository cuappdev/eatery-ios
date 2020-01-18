//
//  LocationPublisherProxy.swift
//  Eatery Watch App Extension
//
//  Created by William Ma on 1/14/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import Combine
import CoreLocation

final class LocationProxy: NSObject {

    enum LocationError: Error {
        case permissionDenied

        var localizedDescription: String {
            switch self {
            case .permissionDenied: return "Permission denied"
            }
        }
    }

    private lazy var manager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        return manager
    }()

    private var lastLocationUpdate: Date?
    private var lastLocation: CLLocation?
    private var didRequestLocation = false

    private var locationFetches: [(Result<CLLocation, Error>) -> Void] = []

    func fetchLocation(_ completion: @escaping (Result<CLLocation, Error>) -> Void) {
        if let lastLocationUpdate = lastLocationUpdate,
            lastLocationUpdate.addingTimeInterval(60) > Date(),
            let location = lastLocation {
            completion(.success(location))
            return
        }

        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
            locationFetches.append(completion)

        case .denied, .restricted:
            completion(.failure(LocationError.permissionDenied))

        case .notDetermined:
            didRequestLocation = true
            manager.requestWhenInUseAuthorization()
            locationFetches.append(completion)

        @unknown default:
            break
        }
    }

    private func notify(_ result: Result<CLLocation, Error>) {
        for completion in locationFetches {
            completion(result)
        }

        locationFetches.removeAll(keepingCapacity: true)
    }

}

extension LocationProxy: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if didRequestLocation {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                manager.requestLocation()
            case .denied, .restricted, .notDetermined:
                notify(.failure(LocationError.permissionDenied))
            @unknown default:
                break
            }

            didRequestLocation = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error, error.localizedDescription)

        notify(.failure(error))
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else {
            return
        }

        notify(.success(last))

        lastLocation = last
        lastLocationUpdate = Date()
    }

}
