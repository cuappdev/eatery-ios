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
    
    let eatery: Eatery
    let mapView: MKMapView
    var locationManager: CLLocationManager!
    var userLocation: CLLocationCoordinate2D!
    var eateryAnnotation: MKPointAnnotation!
    let removalButton = UIButton()
    let arrowButton = UIButton()
    let pinButton = UIButton()
    
    init(eatery: Eatery) {
        self.eatery = eatery
        let bounds = UIScreen.mainScreen().bounds
        self.mapView = MKMapView(frame: CGRectMake(0, 0, bounds.width, bounds.height))
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up location manager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.locationServicesEnabled() {
            switch (CLLocationManager.authorizationStatus()) {
            case .AuthorizedWhenInUse:
                locationManager.startUpdatingLocation()
                mapView.showsUserLocation = true
            case .NotDetermined:
                if locationManager.respondsToSelector(#selector(CLLocationManager.requestWhenInUseAuthorization)) {
                    locationManager.requestWhenInUseAuthorization()
                }
            default: break
            }
        }
        
        // Set up map view
        mapView.delegate = self
        mapEatery()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func mapEatery() {
        let annotationTitle = eatery.address
        eateryAnnotation = MKPointAnnotation()
        eateryAnnotation.coordinate = eatery.location.coordinate
        eateryAnnotation.title = annotationTitle
        mapView.addAnnotation(eateryAnnotation)
        mapView.selectAnnotation(eateryAnnotation, animated: true)
        mapView.setRegion(MKCoordinateRegionMake(eatery.location.coordinate, MKCoordinateSpanMake(0.01, 0.01)), animated: false)
        mapView.alpha = 0.0
        view.addSubview(mapView)
        UIView.animateWithDuration(0.2) {
            self.mapView.alpha = 1.0
        }
        
        createMapButtons()
    }
    
    // MARK: - Button Methods
    
    func createMapButtons() {
        // Create top left removal button
        removalButton.frame = CGRectMake(15, 25, 30, 30)
        removalButton.setImage(UIImage(named: "closeIcon"), forState: .Normal)
        removalButton.addTarget(self, action: #selector(MapViewController.removalButtonPressed), forControlEvents: .TouchUpInside)
        mapView.addSubview(removalButton)
        
        // Create bottom left arrow button
        arrowButton.frame = CGRectMake(15, view.frame.size.height - 55, 30, 30)
        arrowButton.setImage(UIImage(named: "locationArrowIcon"), forState: .Normal)
        arrowButton.addTarget(self, action: #selector(MapViewController.arrowButtonPressed), forControlEvents: .TouchUpInside)
        mapView.addSubview(arrowButton)
        
        // Create bottom right arrow
        pinButton.frame = CGRectMake(view.frame.size.width - 40, view.frame.size.height - 60, 25, 35)
        pinButton.setImage(UIImage(named: "blackEateryPin"), forState: .Normal)
        pinButton.addTarget(self, action: #selector(MapViewController.pinButtonPressed), forControlEvents: .TouchUpInside)
        mapView.addSubview(pinButton)
    }
    
    func removalButtonPressed(sender: UIButton) {
        removalButton.removeFromSuperview()
        arrowButton.removeFromSuperview()
        pinButton.removeFromSuperview()
        dismissVCWithFadeOutAnimation(0.3)
    }
    
    func arrowButtonPressed(sender: UIButton) {
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpanMake(0.01, 0.01))
        mapView.setRegion(region, animated: true)
    }
    
    func pinButtonPressed(sender: UIButton) {
        let region = MKCoordinateRegion(center: eateryAnnotation.coordinate, span: MKCoordinateSpanMake(0.01, 0.01))
        mapView.selectAnnotation(eateryAnnotation, animated: true)
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - MKMapViewDelegate Methods
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("eateryPin")
        
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location Manager Error: \(error)")
    }
    
}
