//
//  CTownMenuViewController.swift
//  Eatery
//
//  Created by Gonzalo Gonzalez on 3/3/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import Crashlytics
import MapKit
import UIKit

class CTownMenuViewController: UIViewController, UIScrollViewDelegate {

    var eatery: Eatery!
    var delegate: MenuButtonsDelegate?
    var userLocation: CLLocation?
    
    var outerScrollView: UIScrollView!
    var scrollContentView: UIView!
    var ctownMenuHeaderView: CTownMenuHeaderView!
    var informativeViews: [UIView]!
    var informativeLabelText = ["Get Directions", "Call (607) 319-4176", "Visit www.chattycathycafe.com"]
    
    //placeholders
    var cellLabels = ["Get Directions", "Call (607) 319-4176", "Visit www.chattycathycafe.com"]
    let rating = 4.43
    let cost = "$$"
    
    init(eatery: Eatery, delegate: MenuButtonsDelegate?, userLocation: CLLocation? = nil){
        self.eatery = eatery
        self.delegate = delegate //to add favorite functionality later
        self.userLocation = userLocation
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.isTranslucent = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outerScrollView = UIScrollView()
        outerScrollView.backgroundColor = .wash
        outerScrollView.delegate = self
        outerScrollView.showsVerticalScrollIndicator = false
        outerScrollView.showsHorizontalScrollIndicator = false
        outerScrollView.alwaysBounceVertical = true
        outerScrollView.delaysContentTouches = false
        outerScrollView.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height*2)
        view.addSubview(outerScrollView)
        
        ctownMenuHeaderView = CTownMenuHeaderView()
        outerScrollView.addSubview(ctownMenuHeaderView)
        
        ctownMenuHeaderView.titleLabel.text = eatery.nickname
        if let url = URL(string: eateryImagesBaseURL + eatery.slug + ".jpg") {
            let placeholder = UIImage.image(withColor: UIColor(white: 0.97, alpha: 1.0))
            ctownMenuHeaderView.backgroundImageView.kf.setImage(with: url, placeholder: placeholder)
        }
        ctownMenuHeaderView.paymentView.paymentMethods = eatery.paymentMethods
        
        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        ctownMenuHeaderView.statusLabel.text = eateryStatus.statusText
        ctownMenuHeaderView.statusLabel.textColor = eateryStatus.statusColor
        ctownMenuHeaderView.hourLabel.text = eateryStatus.message
        
        ctownMenuHeaderView.cuisineLabel.text = "Coffee & Tea, Juice Bars & Smoothies, Acai Bowls"
        
        ctownMenuHeaderView.locationLabel.text = eatery.address
        
        let star1 = ctownMenuHeaderView.ratingView.ratingImageView[0]
        let star2 = ctownMenuHeaderView.ratingView.ratingImageView[1]
        let star3 = ctownMenuHeaderView.ratingView.ratingImageView[2]
        let star4 = ctownMenuHeaderView.ratingView.ratingImageView[3]
        let star5 = ctownMenuHeaderView.ratingView.ratingImageView[4]
        switch rating{
        case 4.75...5.0:
            star1.image = UIImage(named: "selected")
            star2.image = UIImage(named: "selected")
            star3.image = UIImage(named: "selected")
            star4.image = UIImage(named: "selected")
            star5.image = UIImage(named: "selected")
            break
        case 4.25..<4.75:
            star1.image = UIImage(named: "selected")
            star2.image = UIImage(named: "selected")
            star3.image = UIImage(named: "selected")
            star4.image = UIImage(named: "selected")
            star5.image = UIImage(named: "halfSelected")
            break
        case 3.75..<4.25:
            star1.image = UIImage(named: "selected")
            star2.image = UIImage(named: "selected")
            star3.image = UIImage(named: "selected")
            star4.image = UIImage(named: "selected")
            star5.image = UIImage(named: "unselected")
            break
        case 3.25..<3.75:
            star1.image = UIImage(named: "selected")
            star2.image = UIImage(named: "selected")
            star3.image = UIImage(named: "selected")
            star4.image = UIImage(named: "halfSelected")
            star5.image = UIImage(named: "unselected")
            break
        case 2.75..<3.25:
            star1.image = UIImage(named: "selected")
            star2.image = UIImage(named: "selected")
            star3.image = UIImage(named: "selected")
            star4.image = UIImage(named: "unselected")
            star5.image = UIImage(named: "unselected")
            break
        case 2.25..<2.75:
            star1.image = UIImage(named: "selected")
            star2.image = UIImage(named: "selected")
            star3.image = UIImage(named: "halfSelected")
            star4.image = UIImage(named: "unselected")
            star5.image = UIImage(named: "unselected")
            break
        case 1.75..<2.25:
            star1.image = UIImage(named: "selected")
            star2.image = UIImage(named: "selected")
            star3.image = UIImage(named: "unselected")
            star4.image = UIImage(named: "unselected")
            star5.image = UIImage(named: "unselected")
            break
        case 1.25..<1.75:
            star1.image = UIImage(named: "selected")
            star2.image = UIImage(named: "halfSelected")
            star3.image = UIImage(named: "unselected")
            star4.image = UIImage(named: "unselected")
            star5.image = UIImage(named: "unselected")
            break
        case 0.75..<1.25:
            star1.image = UIImage(named: "selected")
            star2.image = UIImage(named: "unselected")
            star3.image = UIImage(named: "unselected")
            star4.image = UIImage(named: "unselected")
            star5.image = UIImage(named: "unselected")
            break
        case 0.25..<0.75:
            star1.image = UIImage(named: "halfSelected")
            star2.image = UIImage(named: "unselected")
            star3.image = UIImage(named: "unselected")
            star4.image = UIImage(named: "unselected")
            star5.image = UIImage(named: "unselected")
            break
        case 0.0..<0.25:
            star1.image = UIImage(named: "unselected")
            star2.image = UIImage(named: "unselected")
            star3.image = UIImage(named: "unselected")
            star4.image = UIImage(named: "unselected")
            star5.image = UIImage(named: "unselected")
            break
        default:
            star1.image = UIImage(named: "halfSelected")
            star2.image = UIImage(named: "halfSelected")
            star3.image = UIImage(named: "halfSelected")
            star4.image = UIImage(named: "halfSelected")
            star5.image = UIImage(named: "halfSelected")
            break
        }
        
        let attributedString = NSMutableAttributedString(string:"$$$")
        switch cost{
        case "$":
            attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black , range: NSRange(location: 0, length: 1))
            ctownMenuHeaderView.priceLabel.attributedText = attributedString
            break
        case "$$":
            attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black , range: NSRange(location: 0, length: 2))
            ctownMenuHeaderView.priceLabel.attributedText = attributedString
            break
        case "$$$":
            ctownMenuHeaderView.priceLabel.textColor = .black
            break
        default:
            break
        }
        
        if let userLocation = userLocation {
            let distance = userLocation.distance(from: eatery.location, in: .miles)
            ctownMenuHeaderView.distanceLabel.text = "\(Double(round(10 * distance) / 10)) mi"
        } else {
            ctownMenuHeaderView.distanceLabel.text = "-- mi"
        }
        
        informativeViews = [UIView]()
        
        for i in 0...2{
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
            informativeLabel.text = informativeLabelText[i]
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
        
        setupConstraints()
    }
    
    func setupConstraints(){
        
        outerScrollView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-UIApplication.shared.statusBarFrame.height)
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        
        ctownMenuHeaderView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalTo(view)
            make.height.equalTo(363)
        }
        
        informativeViews[0].snp.makeConstraints { make in
            make.top.equalTo(ctownMenuHeaderView.informationView.snp.bottom).offset(13)
            make.leading.trailing.equalTo(ctownMenuHeaderView)
            make.height.equalTo(40)
        }
        
        informativeViews[1].snp.makeConstraints { make in
            make.top.equalTo(informativeViews[0].snp.bottom).offset(1)
            make.leading.trailing.equalTo(ctownMenuHeaderView)
            make.height.equalTo(39)
        }
        
        informativeViews[2].snp.makeConstraints { make in
            make.top.equalTo(informativeViews[1].snp.bottom).offset(1)
            make.leading.trailing.equalTo(ctownMenuHeaderView)
            make.height.equalTo(39)
        }
        
    }
    
    // Scrollview Methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch scrollView.contentOffset.y {
        case -CGFloat.greatestFiniteMagnitude..<0.0:
            ctownMenuHeaderView.backgroundImageView.transform = CGAffineTransform.identity
            ctownMenuHeaderView.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(scrollView.contentOffset.y)
                make.height.equalTo(363).offset(-scrollView.contentOffset.y)
            }
            ctownMenuHeaderView.backgroundImageView.snp.updateConstraints { make in
                make.top.equalToSuperview()
                make.height.equalTo(258).offset(-scrollView.contentOffset.y+258)
            }
        default:
            ctownMenuHeaderView.backgroundImageView.transform = CGAffineTransform(translationX: 0.0, y: scrollView.contentOffset.y / 4)
            ctownMenuHeaderView.snp.updateConstraints { make in
                make.top.equalToSuperview()
                make.height.equalTo(363)
            }
        }
    }
    
    @objc func getDirections(){
        Answers.logDirectionsAsked(eateryId: eatery.slug)
        
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
    
    @objc func callNumber(){
        if let url = URL(string: "tel://3059755855"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @objc func visitWebsite(){
        if let url = URL(string: "https://chattycathycafe.com/"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func openAppleMapsDirections() {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: eatery.location.coordinate, addressDictionary: nil))
        mapItem.name = eatery.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
