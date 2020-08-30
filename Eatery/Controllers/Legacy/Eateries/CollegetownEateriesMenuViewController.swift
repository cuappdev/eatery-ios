//
//  CollegetownMenuViewController.swift
//  Eatery
//
//  Created by Gonzalo Gonzalez on 3/3/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

//swiftlint:disable all

import MapKit
import UIKit

class CollegetownEateriesMenuViewController: UIViewController, UIScrollViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var eatery: CollegetownEatery
    
    var outerScrollView: UIScrollView!
    var backButton: UIButton!
    var ctownMenuHeaderView: CollegetownMenuHeaderView!
    var informativeViews: [UIView]!

    var mapView: MKMapView
    let eateryAnnotation = MKPointAnnotation()
    var locationManager: CLLocationManager!
    var userLocation: CLLocation {
        return locationManager?.location ?? .olinLibrary
    }

    var defaultCoordinate: CLLocationCoordinate2D!
    var midpointCoordinate: CLLocationCoordinate2D!
    var delta: (lat: Double, lon: Double)!
    var maxDelta = (lat: 2/69.172, lon: 2/51.2738554594)

    init(eatery: CollegetownEatery) {
        self.eatery = eatery
        self.mapView = MKMapView()
        super.init(nibName: nil, bundle: nil)
        
        mapView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        defaultCoordinate = eatery.location.coordinate

        midpointCoordinate = CLLocationCoordinate2D.midpoint(between: userLocation.coordinate,
                                                             and: eatery.location.coordinate)

        delta = CLLocationCoordinate2D.deltaLatLon(between: userLocation.coordinate,
                                                   and: eatery.location.coordinate)

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        class CustomScrollView: UIScrollView{
            override func touchesShouldCancel(in view: UIView) -> Bool {
                return !(view is UIButton)
            }
        }
        
        outerScrollView = CustomScrollView()
        outerScrollView.backgroundColor = .wash
        outerScrollView.delegate = self
        outerScrollView.showsVerticalScrollIndicator = false
        outerScrollView.showsHorizontalScrollIndicator = false
        outerScrollView.alwaysBounceVertical = true
        outerScrollView.delaysContentTouches = false
        view.addSubview(outerScrollView)
        
        ctownMenuHeaderView = CollegetownMenuHeaderView()
        ctownMenuHeaderView.set(eatery: eatery, userLocation: userLocation)
        ctownMenuHeaderView.isUserInteractionEnabled = true
        outerScrollView.addSubview(ctownMenuHeaderView)
        
        backButton = UIButton()
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.isUserInteractionEnabled = true
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        outerScrollView.addSubview(backButton)
        
        informativeViews = [UIView]()
        
        for i in 0...2 {
            let informativeView = UIView()
            informativeView.backgroundColor = .white
            informativeView.isUserInteractionEnabled = true
            informativeViews.append(informativeView)
            
            var gesture : UITapGestureRecognizer!
            switch i{
            case 0:
                gesture = UITapGestureRecognizer(target: self, action: #selector(getDirections))
            case 1:
                gesture = UITapGestureRecognizer(target: self, action: #selector(callNumber))
            case 2:
                gesture = UITapGestureRecognizer(target: self, action: #selector(visitWebsite))
            default:
                print("Bad case")
            }

            informativeView.addGestureRecognizer(gesture)
            outerScrollView.addSubview(informativeView)
            
            let informativeLabel = UILabel()
            switch i {
            case 0: informativeLabel.text = "Get Directions"
            case 1: informativeLabel.text = "Call \(eatery.phone)"
            case 2: informativeLabel.text = "Open \(eatery.displayName) on Yelp"
            default: break
            }
            informativeLabel.font = .systemFont(ofSize: 14, weight: .medium)
            informativeLabel.textColor = .eateryBlue
            informativeView.addSubview(informativeLabel)
            
            informativeLabel.snp.makeConstraints { make in
                make.leading.equalTo(16)
                make.height.equalTo(20)
                make.centerY.equalToSuperview()
                make.trailing.lessThanOrEqualToSuperview()
            }
        }
        
        mapView.showsBuildings = true
        mapView.showsUserLocation = true
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        if(delta.lat<maxDelta.lat && delta.lon<maxDelta.lon){
            mapView.setCenter(midpointCoordinate, animated: true)
            mapView.setRegion(MKCoordinateRegionMake(midpointCoordinate, MKCoordinateSpanMake(delta.lat*1.5, delta.lon*1.5)), animated: false)
        } else {
            mapView.setCenter(defaultCoordinate, animated: true)
            mapView.setRegion(MKCoordinateRegionMake(defaultCoordinate, MKCoordinateSpanMake(0.01, 0.01)), animated: false)
        }
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openMapViewController)))
        outerScrollView.addSubview(mapView)
        
        eateryAnnotation.coordinate = eatery.location.coordinate
        eateryAnnotation.title = eatery.displayName
        eateryAnnotation.subtitle = eatery.isOpen(atExactly: Date()) ? "open" : "closed"
        mapView.addAnnotation(eateryAnnotation)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        
        let screenSize = view.bounds.width
        let ctownMenuHeaderViewHeight = 363
        let informativeViewHeight = 39
        let mapViewHeight = 306
        
        outerScrollView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-UIApplication.shared.statusBarFrame.height)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
        outerScrollView.contentSize = CGSize(width: screenSize, height: CGFloat(ctownMenuHeaderViewHeight + informativeViewHeight*3 + mapViewHeight + 47))
        
        ctownMenuHeaderView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalTo(view)
            make.height.equalTo(ctownMenuHeaderViewHeight)
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(55)
            make.leading.equalToSuperview().offset(11)
            make.height.equalTo(20)
            make.width.equalTo(75)
        }
        
        informativeViews[0].snp.makeConstraints { make in
            make.top.equalTo(ctownMenuHeaderView.informationView.snp.bottom).offset(13)
            make.leading.trailing.equalTo(ctownMenuHeaderView)
            make.height.equalTo(informativeViewHeight+1)
        }
        
        informativeViews[1].snp.makeConstraints { make in
            make.top.equalTo(informativeViews[0].snp.bottom).offset(1)
            make.leading.trailing.equalTo(ctownMenuHeaderView)
            make.height.equalTo(informativeViewHeight)
        }
        
        informativeViews[2].snp.makeConstraints { make in
            make.top.equalTo(informativeViews[1].snp.bottom).offset(1)
            make.leading.trailing.equalTo(ctownMenuHeaderView)
            make.height.equalTo(informativeViewHeight)
        }
        
        mapView.snp.makeConstraints { make in
            make.top.equalTo(informativeViews[2].snp.bottom).offset(11)
            make.leading.trailing.equalTo(ctownMenuHeaderView)
            make.height.equalTo(mapViewHeight)
        }
        
    }
    
    // Scrollview Methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let statusBarOffset = UIApplication.shared.statusBarFrame.height
        let statusBarInset = -statusBarOffset
        let scrollOffset = scrollView.contentOffset.y
        let scrollInset = -scrollOffset
        switch scrollOffset {
        case -CGFloat.greatestFiniteMagnitude ..< statusBarInset:
            ctownMenuHeaderView.backgroundImageView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: statusBarOffset/2)
            ctownMenuHeaderView.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(scrollOffset)
                make.height.equalTo(363).offset(363+scrollInset)
            }
            ctownMenuHeaderView.backgroundImageView.snp.updateConstraints { make in
                make.top.equalToSuperview()
                make.height.equalTo(258).offset(258+scrollInset)
            }
            backButton.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(55+scrollOffset+statusBarOffset)
            }
        default:
            ctownMenuHeaderView.backgroundImageView.transform = CGAffineTransform(translationX: 0.0, y: (scrollOffset + statusBarOffset) / 4)
            ctownMenuHeaderView.snp.updateConstraints { make in
                make.top.equalToSuperview()
                make.height.equalTo(363)
            }
            ctownMenuHeaderView.backgroundImageView.snp.updateConstraints { make in
                make.height.equalTo(258)
            }
            backButton.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(55)
            }
        }
    }
    
    
    
    // MKMapViewDelegate Methods
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let annotationView: MKAnnotationView
        
        if let dequeued = mapView.dequeueReusableAnnotationView(withIdentifier: "eateryPin") {
            annotationView = dequeued
            annotationView.annotation = annotation
        } else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "eateryPin")
            annotationView.canShowCallout = true
        }
        
        annotationView.image = annotation.subtitle == "open" ? UIImage(named: "eateryPin") : UIImage(named: "blackEateryPin")
        
        return annotationView
    }
    
    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func getDirections() {
        // TODO: Answers.logDirectionsAsked(eateryId: eatery.slug)
        
        let coordinate = eatery.location.coordinate
        
        if (UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)) {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Open in Apple Maps", style: .default) { Void in
                self.openAppleMapsDirections()
            })
            alertController.addAction(UIAlertAction(title: "Open in Google Maps", style: .default) { Void in
                UIApplication.shared.open(URL(string: "comgooglemaps://?saddr=&daddr=\(coordinate.latitude),\(coordinate.longitude)&directionsmode=walking")!, options: [:], completionHandler: nil)
            })
            if let presenter = alertController.popoverPresentationController {
                presenter.sourceView = informativeViews[0]
                presenter.sourceRect = informativeViews[0].bounds
            } else {
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            }
            present(alertController, animated: true, completion: nil)
        } else {
            openAppleMapsDirections()
        }
    }
    
    @objc private func callNumber() {
        if let url = URL(string: "tel://\(eatery.phone)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func visitWebsite() {
        if let url = eatery.url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func openMapViewController() {
        let eateries = [eatery]
        //eateries.append(eatery)
        
        let mapViewController = MapViewController(eateries: eateries)
        navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    private func openAppleMapsDirections() {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: eatery.location.coordinate, addressDictionary: nil))
        mapItem.name = eatery.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
