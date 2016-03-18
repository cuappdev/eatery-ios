//
//  MoreInfoViewController.swift
//  Eatery
//
//  Created by Jesse Chen on 3/16/16.
//  Copyright © 2016 CUAppDev. All rights reserved.
//

import UIKit
import DiningStack
import MapKit

class MoreInfoViewController: UITableViewController {
    
    var eatery: Eatery!
    let rowHeight = CGFloat(50)
    let numberOfSections = 3

    override func viewDidLoad() {
        super.viewDidLoad()
        title = eatery.nameShort
        tableView.backgroundColor = UIColor.lightGray()
        tableView.registerNib(UINib(nibName: "MoreInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "InfoCell")
        mapEatery()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return numberOfSections
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 2) ? 0 : 1
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionTitle: String!
        switch (section) {
        case 0:
            sectionTitle = "Phone"
        case 1:
            sectionTitle = "About"
        case 2:
            sectionTitle = "Location"
        default:
            sectionTitle = ""
        }
        return sectionTitle
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InfoCell", forIndexPath: indexPath) as! MoreInfoTableViewCell
        
        switch (indexPath.section) {
        case 0:
            cell.infoLabel.text = eatery.phone
        case 1:
            cell.infoLabel.adjustsFontSizeToFitWidth = true
            cell.infoLabel.text = eatery.about
            cell.iconView.hidden = true
        default:
            cell.infoLabel.text = ""
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = (indexPath.section == 1) ?  2 * rowHeight : rowHeight
        return height
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section) {
        case 0:
            callEatery()
        default:
            break
        }
    }
    
    func callEatery() {
        let stringArray = eatery.phone.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        let numericalPhoneNumber = stringArray.joinWithSeparator("")
        UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(numericalPhoneNumber)")!)
    }
    
    func mapEatery() {
        let offset = CGFloat(36)
        let yCoord = CGFloat(numberOfSections + 1) * rowHeight + offset
        let coordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let annotationTitle = eatery.address
        let mapView = MKMapView(frame: CGRectMake(0, yCoord, UIScreen.mainScreen().bounds.width,
            UIScreen.mainScreen().bounds.height - yCoord))
        let annotation = MKPointAnnotation()
        annotation.coordinate = eatery.location.coordinate
        annotation.title = annotationTitle
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
        mapView.setRegion(MKCoordinateRegionMake(eatery.location.coordinate, coordinateSpan), animated: true)
        self.view.addSubview(mapView)
    }
}
