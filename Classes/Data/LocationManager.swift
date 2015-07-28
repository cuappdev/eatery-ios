//
//  LocationManager.swift
//  Eatery
//
//  Created by Lucas Derraugh on 12/8/14.
//  Copyright (c) 2014 CUAppDev. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private var locationManager: CLLocationManager
    private var currentLocation: CLLocation?
    
    class var sharedInstance : LocationManager {
        struct Static {
            static let instance : LocationManager = LocationManager()
        }
        return Static.instance
    }
    
    private override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0 {
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        println(__FUNCTION__)
    }
    
}
