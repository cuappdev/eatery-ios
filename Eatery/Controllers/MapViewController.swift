//
//  MapViewController.swift
//  Eatery
//
//  Created by Jesse Chen on 4/13/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import DiningStack

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var eateries: [Eatery]
    let mapView: MKMapView
    var locationManager: CLLocationManager!
    
    let removalButton = UIButton()
    let arrowButton = UIButton()
    let pinButton = UIButton()
    
    init(eateries allEateries: [Eatery]) {
        self.eateries = allEateries
        self.mapView = MKMapView()
        super.init(nibName: nil, bundle: nil)
        
        mapView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.view.backgroundColor = .white

        view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height - (navigationController?.navigationBar.frame.maxY ?? 0.0) - (tabBarController?.tabBar.frame.height ?? 0.0))
        mapView.frame = view.bounds
        
        // Set up location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.locationServicesEnabled() {
            switch (CLLocationManager.authorizationStatus()) {
            case .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
                mapView.showsUserLocation = true
            case .notDetermined:
                if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
                    locationManager.requestWhenInUseAuthorization()
                }
            default: break
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func mapEateries(_ eateries: [Eatery]) {
        if self.eateries.count == 0 {
            self.eateries = eateries
        }
        
        for eatery in eateries
        {
            let annotationTitle = eatery.address
            let eateryAnnotation = MKPointAnnotation()
            eateryAnnotation.coordinate = eatery.location.coordinate
            eateryAnnotation.title = annotationTitle
            mapView.addAnnotation(eateryAnnotation)
            mapView.selectAnnotation(eateryAnnotation, animated: true)
        }

        mapView.alpha = 0.0
        view.addSubview(mapView)
        UIView.animate(withDuration: 0.2, animations: {
            self.mapView.alpha = 1.0
        })

        createMapButtons()
        
        if let coordinate = locationManager.location?.coordinate {
            mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: false)
        }
    }
    
    // MARK: - Button Methods
    
    func createMapButtons() {
        // Create top left removal button
        removalButton.frame = CGRect(x: 15, y: 25, width: 30, height: 30)
        removalButton.setImage(UIImage(named: "closeIcon"), for: UIControlState())
        removalButton.addTarget(self, action: #selector(MapViewController.removalButtonPressed), for: .touchUpInside)
        mapView.addSubview(removalButton)
        
        // Create bottom left arrow button
        arrowButton.frame = CGRect(x: 15, y: view.frame.size.height - 55, width: 30, height: 30)
        arrowButton.setImage(UIImage(named: "locationArrowIcon"), for: UIControlState())
        arrowButton.addTarget(self, action: #selector(MapViewController.arrowButtonPressed), for: .touchUpInside)
        mapView.addSubview(arrowButton)
        
        // Create bottom right arrow
        pinButton.frame = CGRect(x: view.frame.size.width - 40, y: view.frame.size.height - 60, width: 25, height: 35)
        pinButton.setImage(UIImage(named: "blackEateryPin"), for: UIControlState())
        pinButton.addTarget(self, action: #selector(MapViewController.pinButtonPressed), for: .touchUpInside)
        mapView.addSubview(pinButton)
    }
    
    func removalButtonPressed(_ sender: UIButton) {
        removalButton.removeFromSuperview()
        arrowButton.removeFromSuperview()
        pinButton.removeFromSuperview()
        dismissVCWithFadeOutAnimation(0.3)
    }

    func arrowButtonPressed(_ sender: UIButton) {
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpanMake(0.01, 0.01))
        mapView.setRegion(region, animated: true)
    }
    
    func pinButtonPressed(_ sender: UIButton) {
        let region = MKCoordinateRegion(center: mapView.annotations.first!.coordinate, span: MKCoordinateSpanMake(0.01, 0.01))
        mapView.selectAnnotation(mapView.annotations.first!, animated: true)
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - MKMapViewDelegate Methods
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "eateryPin")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "eateryPin")
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        annotationView!.image = UIImage(named: "eateryPin")
        
        return annotationView
    }

    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error: \(error)")
    }
    
}
