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
    var eateryAnnotations : [MKPointAnnotation] = []
    let mapView: MKMapView
    var locationManager: CLLocationManager!
    
    let recenterButton = UIButton()
    
    let defaultLocation = CLLocation(latitude: 42.448078,longitude: -76.484291) // olin library
    let defaultCoordinate = CLLocation(latitude: 42.448078,longitude: -76.484291).coordinate
    
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
        
        title = "Map"
        
        view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height - (navigationController?.navigationBar.frame.maxY ?? 0.0) - (tabBarController?.tabBar.frame.height ?? 0.0))
        mapView.frame = view.bounds
        view.addSubview(mapView)
        
        createMapButtons()
        
        mapView.setCenter(locationManager.location?.coordinate ?? defaultCoordinate, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func mapEateries(_ eateries: [Eatery]) {
        self.eateries = eateries
        
        for eatery in eateries {
            let annotationTitle = eatery.nickname
            let eateryAnnotation = MKPointAnnotation()
            eateryAnnotation.coordinate = eatery.location.coordinate
            eateryAnnotation.title = annotationTitle
            eateryAnnotation.subtitle = eatery.isOpenNow() ? "open" : "closed"
            mapView.addAnnotation(eateryAnnotation)
            eateryAnnotations.append(eateryAnnotation)
        }
        
        let region = MKCoordinateRegion(center: locationManager.location?.coordinate ?? defaultCoordinate,
                                        span: MKCoordinateSpanMake(0.006, 0.015))
        mapView.setRegion(region, animated: false)
    }
    
    // MARK: - Button Methods
    
    func createMapButtons()
    {
        // Create bottom left re-center button
        recenterButton.frame = CGRect(x: 20, y: view.frame.size.height - 65, width: 120, height: 40)
        recenterButton.layer.cornerRadius = 6
        recenterButton.setImage(UIImage(named: "locationArrowIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        recenterButton.tintColor = UIColor.colorFromCode(0x3d90e2)
        recenterButton.imageEdgeInsets = UIEdgeInsetsMake(0, -6, 0, 0)
        recenterButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0)
        recenterButton.backgroundColor = .white
        recenterButton.setTitle("Re-center", for: .normal)
        recenterButton.setTitleColor(.black, for: .normal)
        recenterButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        recenterButton.addTarget(self, action: #selector(recenterButtonPressed), for: .touchUpInside)
        mapView.addSubview(recenterButton)
    }
    
    func recenterButtonPressed(_ sender: UIButton)
    {
        if mapView.selectedAnnotations.count > 0 {
            mapView.deselectAnnotation(mapView.selectedAnnotations.first!, animated: true)
        }
        
        let userLoc = locationManager.location ?? defaultLocation
        
        mapView.setCenter(userLoc.coordinate, animated: true)
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
