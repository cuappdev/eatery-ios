//
//  PillViewController.swift
//  Eatery
//
//  Created by Ethan Fine on 12/1/18.
//  Copyright © 2018 CUAppDev. All rights reserved.
//

import UIKit
import SnapKit

// TODO: move this inside pill vc, then to Eateries shared vc once PillVC becomes generic
enum Location: String {

    case campus = "Campus"
    case collegetown = "Collegetown"

}

protocol PillViewControllerDelegate: AnyObject {

    func pillViewController(_ pvc: PillViewController, didUpdateLocation newLocation: Location)

}

// TODO: make this a (generic) parent view controller. 
class PillViewController: UIViewController {
    
    var selectedLocation = Location.campus
    
    weak var delegate: PillViewControllerDelegate?
    
    var campusStackView: UIStackView!
    var separatorView: UIView!
    var collegetownStackView: UIStackView!
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 1
        
        let fontSize = getSelectionSizeAttributes().fontSize
        
        let campusIconImage = UIImage(named: "campusIcon")?.withRenderingMode(.alwaysTemplate)
        let campusImageView = UIImageView(image: campusIconImage)
        campusImageView.tintColor = UIColor.eateryBlue
        
        let campusLabel = UILabel(frame: CGRect.zero)
        campusLabel.text = Location.campus.rawValue
        campusLabel.textColor = UIColor.eateryBlue
        campusLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        
        campusStackView = UIStackView(arrangedSubviews: [campusImageView, campusLabel])
        setupLocationStackView(stackView: campusStackView)
        
        separatorView = UIView(frame: CGRect.zero)
        separatorView.backgroundColor = UIColor.inactive
        view.addSubview(separatorView)
        
        let collegetownIconImage = UIImage(named: "collegetownIcon")?.withRenderingMode(.alwaysTemplate)
        let collegetownImageView = UIImageView(image: collegetownIconImage)
        collegetownImageView.tintColor = UIColor.inactive
        
        let collegetownLabel = UILabel(frame: CGRect.zero)
        collegetownLabel.text = Location.collegetown.rawValue
        collegetownLabel.textColor = UIColor.secondary
        collegetownLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        
        collegetownStackView = UIStackView(arrangedSubviews: [collegetownImageView, collegetownLabel])
        setupLocationStackView(stackView: collegetownStackView)
    }
    
    override func viewDidLayoutSubviews() {
        let iconSideLength = getSelectionSizeAttributes().iconSideLength
        campusStackView.subviews[0].snp.makeConstraints { (make) in
            make.width.equalTo(iconSideLength)
            make.height.equalTo(iconSideLength)
        }
        campusStackView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().dividedBy(2)
        }
        separatorView.snp.makeConstraints { (make) in
            make.width.equalTo(2)
            make.height.equalToSuperview()
            make.centerX.centerY.equalToSuperview()
        }
        collegetownStackView.subviews[0].snp.makeConstraints { (make) in
            make.width.equalTo(iconSideLength)
            make.height.equalTo(iconSideLength)
        }
        collegetownStackView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().multipliedBy(1.5)
        }
    }
    
    func getSelectionSizeAttributes() -> (iconSideLength: Int, fontSize: CGFloat) {
        return UIScreen.main.nativeBounds.height <= 1136 ? (14, 12) : (16, 14)
    }
    
    func setupLocationStackView(stackView: UIStackView) {
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
    }
    
    func swapSelectedLocation() {
        selectedLocation = selectedLocation == .collegetown ? .campus : .collegetown
        campusStackView.subviews[0].tintColor = selectedLocation == .collegetown ?
            UIColor.inactive : UIColor.eateryBlue
        let campusLabel = campusStackView.subviews[1] as! UILabel
        campusLabel.textColor = selectedLocation == .collegetown ?
            UIColor.secondary : UIColor.eateryBlue
        collegetownStackView.subviews[0].tintColor = selectedLocation == .campus ?
            UIColor.inactive : UIColor.eateryBlue
        let collegetownLabel = collegetownStackView.subviews[1] as! UILabel
        collegetownLabel.textColor = selectedLocation == .campus ?
            UIColor.secondary : UIColor.eateryBlue
        
        delegate?.pillViewController(self, didUpdateLocation: selectedLocation)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
            if location.x > (view.frame.width / 2) && selectedLocation == .campus {
                swapSelectedLocation()
            }
            if location.x < (view.frame.width / 2) && selectedLocation == .collegetown {
                swapSelectedLocation()
            }
        }
    }
    
}
