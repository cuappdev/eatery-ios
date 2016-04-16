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
    
    var eatery: Eatery!
    var mapView: MKMapView!
    var removalButton: UIButton?

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
        mapView = MKMapView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height))
        let annotation = MKPointAnnotation()
        annotation.coordinate = eatery.location.coordinate
        annotation.title = annotationTitle
        mapView!.addAnnotation(annotation)
        mapView!.selectAnnotation(annotation, animated: true)
        mapView!.setRegion(MKCoordinateRegionMake(eatery.location.coordinate, coordinateSpan), animated: false)
        mapView!.alpha = 0.0
        self.view.addSubview(mapView!)
        UIView.animateWithDuration(0.2) {
            self.mapView?.alpha = 1.0
        }
        createRemovalButton()
    }
    
    func createRemovalButton() {
        removalButton = UIButton()
        removalButton!.frame = CGRectMake(15, 25, 30, 30)
        removalButton!.setImage(UIImage(named: "closeIcon"), forState: .Normal)
        removalButton!.addTarget(self, action: #selector(MapViewController.removalButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
        mapView?.addSubview(removalButton!)
    }
    
    func removalButtonPressed(sender: UIButton) {
        removalButton?.removeFromSuperview()
        UIView.animateWithDuration(0.2, animations: { self.mapView?.alpha = 0.0 })
        { (value: Bool) in
            self.mapView?.removeFromSuperview()
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
