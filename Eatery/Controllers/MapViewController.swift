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

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate
{
    var eateries: [Eatery]
    var queueCursor : Int = -1 // for close-by feature
    var eateryAnnotations : [MKPointAnnotation] = []
    let mapView: MKMapView
    var locationManager: CLLocationManager!
    
    let arrowButton = UIButton()
    let pinButton = UIButton()
    
    init(eateries allEateries: [Eatery]) {
        self.eateries = allEateries
        self.mapView = MKMapView()
        super.init(nibName: nil, bundle: nil)
        
        mapView.delegate = self
        
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nearby"
        
        view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height - (navigationController?.navigationBar.frame.maxY ?? 0.0) - (tabBarController?.tabBar.frame.height ?? 0.0))
        mapView.frame = view.bounds
        view.addSubview(mapView)
        
        createMapButtons()
        
        let tiltedCamera = mapView.camera
        tiltedCamera.altitude = 415
        tiltedCamera.heading = 180
        tiltedCamera.pitch = 60
        tiltedCamera.centerCoordinate = locationManager.location?.coordinate ?? CLLocation(latitude: 42.448078,longitude: -76.484291).coordinate
        mapView.setCamera(tiltedCamera, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func mapEateries(_ eateries: [Eatery])
    {
        self.eateries = eateries
        
        for eatery in eateries
        {
            let annotationTitle = eatery.nickname
            let eateryAnnotation = MKPointAnnotation()
            eateryAnnotation.coordinate = eatery.location.coordinate
            eateryAnnotation.title = annotationTitle
            eateryAnnotation.subtitle = eatery.isOpenNow() ? "open" : "closed"
            mapView.addAnnotation(eateryAnnotation)
            eateryAnnotations.append(eateryAnnotation)
        }
        
        let userLoc = locationManager.location?.coordinate ?? CLLocation(latitude: 42.448078,longitude: -76.484291).coordinate
        
        let region = MKCoordinateRegion(center: userLoc,
                                        span: MKCoordinateSpanMake(0.006, 0.015))
        mapView.setRegion(region, animated: false)
    }
    
    // MARK: - Button Methods
    
    func createMapButtons()
    {
        // Create bottom left arrow button
        arrowButton.frame = CGRect(x: 15, y: view.frame.size.height - 55, width: 30, height: 30)
        arrowButton.setImage(#imageLiteral(resourceName: "locationArrowIcon"), for: UIControlState())
        arrowButton.addTarget(self, action: #selector(MapViewController.arrowButtonPressed), for: .touchUpInside)
        mapView.addSubview(arrowButton)
        
        // Create bottom right arrow
        pinButton.frame = CGRect(x: view.frame.size.width - 55, y: view.frame.size.height - 60, width: 35, height: 35)
        pinButton.setImage(#imageLiteral(resourceName: "nearbyIcon"), for: UIControlState())
        pinButton.addTarget(self, action: #selector(MapViewController.pinButtonPressed), for: .touchUpInside)
        mapView.addSubview(pinButton)
    }
    
    func arrowButtonPressed(_ sender: UIButton)
    {
        if mapView.selectedAnnotations.count > 0 {
            mapView.deselectAnnotation(mapView.selectedAnnotations.first!, animated: true)
        }
        
        queueCursor = -1
        eateryAnnotations =
            eateryAnnotations.filter({ (annot) -> Bool in
                return annot.subtitle == "open"
            }).sorted(by: { (a, b) -> Bool in
                let distA = mapView.userLocation.location?.distance(from: CLLocation(latitude: a.coordinate.latitude,
                                                                                     longitude: a.coordinate.longitude)) ?? 0
                let distB = mapView.userLocation.location?.distance(from: CLLocation(latitude: b.coordinate.latitude,
                                                                                     longitude: b.coordinate.longitude)) ?? 0
                return distA < distB
            })
        eateries =
            eateries.filter({ (eatery) -> Bool in
                return eatery.isOpenNow()
            }).sorted(by: { (a, b) -> Bool in
                let distA = mapView.userLocation.location?.distance(from: a.location) ?? 0
                let distB = mapView.userLocation.location?.distance(from: b.location) ?? 0
                return distA < distB
            })
        
        let newCamera = mapView.camera
        newCamera.altitude = 415
        newCamera.heading = 180
        newCamera.pitch = 60
        newCamera.centerCoordinate = locationManager.location?.coordinate ?? CLLocation(latitude: 42.448078,longitude: -76.484291).coordinate
        
        mapView.setCamera(newCamera, animated: true)
    }
    
    func pinButtonPressed(_ sender: UIButton)
    {
        if mapView.selectedAnnotations.count > 0 {
            mapView.deselectAnnotation(mapView.selectedAnnotations.first!, animated: true)
        }
        
        queueCursor += 1
        if queueCursor >= eateryAnnotations.count {
            queueCursor = 0
        }
        
        mapView.setCenter(eateryAnnotations[queueCursor].coordinate, animated: true)
        mapView.selectAnnotation(eateryAnnotations[queueCursor], animated: true)
    }
    
    // MARK: - MKMapViewDelegate Methods
    
    func mapView(_ mapView: MKMapView,
                 annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl)
    {
        let menuVC = MenuViewController(eatery: eateries[eateryAnnotations.index(of: view.annotation as! MKPointAnnotation) ?? 0], delegate: nil)
        self.navigationController?.pushViewController(menuVC, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "eateryPin")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "eateryPin")
            annotationView!.canShowCallout = true
            annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            annotationView!.annotation = annotation
        }
        
        annotationView!.image = annotation.subtitle! == "open" ? #imageLiteral(resourceName: "eateryPin") : #imageLiteral(resourceName: "blackEateryPin")
        
        return annotationView
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        guard let currentCoordinates = locations.last?.coordinate else { return }
        let region = MKCoordinateRegionMake(currentCoordinates, MKCoordinateSpanMake(0.01, 0.01))
        mapView.setRegion(region, animated: true)
        mapView.showsBuildings = true
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Location Manager Error: \(error)")
    }
    
}
