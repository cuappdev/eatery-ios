import UIKit
import MapKit
import SnapKit
import CoreLocation
import DiningStack

let olinLibraryLocation = CLLocation(latitude: 42.448078,longitude: -76.484291)

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var eateries: [Eatery]
    var eateryAnnotations : [MKPointAnnotation] = []
    let mapView: MKMapView
    var locationManager: CLLocationManager!
    
    let recenterButton = UIButton()
    
    var defaultCoordinate: CLLocationCoordinate2D {
        return locationManager.location?.coordinate ?? olinLibraryLocation.coordinate
    }
    
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

        mapView.showsBuildings = true
        mapView.showsUserLocation = true
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        createMapButtons()
        
        mapView.setCenter(defaultCoordinate, animated: true)
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
        
        mapView.setRegion(MKCoordinateRegionMake(defaultCoordinate, MKCoordinateSpanMake(0.01, 0.01)), animated: false)
    }
    
    // MARK: - Button Methods
    
    func createMapButtons()
    {
        // Create bottom left re-center button
        recenterButton.layer.cornerRadius = 6
        recenterButton.setImage(UIImage(named: "locationArrowIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        recenterButton.tintColor = UIColor.colorFromCode(0x3d90e2)
        recenterButton.imageEdgeInsets.left = -6
        recenterButton.titleEdgeInsets.left = 8
        recenterButton.backgroundColor = .white
        recenterButton.setTitle("Re-center", for: .normal)
        recenterButton.setTitleColor(.black, for: .normal)
        recenterButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        recenterButton.addTarget(self, action: #selector(recenterButtonPressed), for: .touchUpInside)
        mapView.addSubview(recenterButton)
        recenterButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
            make.height.equalTo(40)
            make.width.equalTo(120)
        }
    }
    
    @objc func recenterButtonPressed(_ sender: UIButton)
    {
        if eateryAnnotations.count == 1 {
            mapView.selectAnnotation(eateryAnnotations.first!, animated: true)
        } else if mapView.selectedAnnotations.count > 0 {
            mapView.deselectAnnotation(mapView.selectedAnnotations.first!, animated: true)
        }
        
        if eateryAnnotations.count == 1 {
            let annotationPoint = MKMapPointForCoordinate(defaultCoordinate)
            var zoomRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
            for annotation in mapView.annotations {
                let annotationPoint = MKMapPointForCoordinate(annotation.coordinate)
                let pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1)
                zoomRect = MKMapRectUnion(zoomRect, pointRect)
            }
            let inset = min(-2250.0, -zoomRect.size.width)
            mapView.setVisibleMapRect(MKMapRectInset(zoomRect, inset, inset), animated: true)
            
            let myMapView = mapView
            let request = MKDirectionsRequest()
            request.source = MKMapItem.forCurrentLocation()
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: eateryAnnotations.first!.coordinate, addressDictionary: nil))
            request.transportType = .walking;
            let directions = MKDirections(request: request)
            directions.calculate { (response, error) in
                if let response = response, error == nil {
                    for route in response.routes {
                        myMapView.add(route.polyline, level: .aboveRoads)
                    }
                }
            }
        } else {
            mapView.setCenter(defaultCoordinate, animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate Methods
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let lineRendered = MKPolylineRenderer(polyline: mapView.overlays.first! as! MKPolyline)
        lineRendered.strokeColor = .eateryBlue
        lineRendered.lineWidth = 3
        return lineRendered
    }
    
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
        recenterButtonPressed(recenterButton)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Location Manager Error: \(error)")
    }
    
}
