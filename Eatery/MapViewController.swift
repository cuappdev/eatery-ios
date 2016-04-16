//
//  MapViewController.swift
//  Eatery
//
//  Created by Jesse Chen on 4/13/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit
import MapKit
import DiningStack

class MapViewController: UIViewController {
    
    let eatery: Eatery
    let mapView: MKMapView
    let removalButton = UIButton()
    
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
        mapEatery()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func mapEatery() {
        let coordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let annotationTitle = eatery.address
        let annotation = MKPointAnnotation()
        annotation.coordinate = eatery.location.coordinate
        annotation.title = annotationTitle
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
        mapView.setRegion(MKCoordinateRegionMake(eatery.location.coordinate, coordinateSpan), animated: false)
        mapView.alpha = 0.0
        self.view.addSubview(mapView)
        UIView.animateWithDuration(0.2) {
            self.mapView.alpha = 1.0
        }
        createRemovalButton()
    }
    
    func createRemovalButton() {
        removalButton.frame = CGRectMake(15, 25, 30, 30)
        removalButton.setImage(UIImage(named: "closeIcon"), forState: .Normal)
        removalButton.addTarget(self, action: #selector(MapViewController.removalButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
        mapView.addSubview(removalButton)
    }
    
    func removalButtonPressed(sender: UIButton) {
        removalButton.removeFromSuperview()
        UIView.animateWithDuration(0.2) {
            self.mapView.alpha = 0.0
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
