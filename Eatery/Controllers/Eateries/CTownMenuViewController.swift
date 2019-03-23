//
//  CTownMenuViewController.swift
//  Eatery
//
//  Created by Gonzalo Gonzalez on 3/3/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit
import MapKit

class CTownMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var eatery: Eatery!
    var delegate: MenuButtonsDelegate?
    var userLocation: CLLocation?
    
    // Tableview
    var ctownMenuTableView: UITableView!
    var ctownMenuHeaderView: CTownMenuHeaderView!
    var cTownInformativeReuseIdentifier = "CTownInformative"
    
    //placeholders
    var cellLabels = ["Get Directions", "Call (607) 319-4176", "Visit www.chattycathycafe.com"]
    let rating = 4.63
    let cost = "$$"
    
    init(eatery: Eatery, delegate: MenuButtonsDelegate?, userLocation: CLLocation? = nil){
        self.eatery = eatery
        self.delegate = delegate //to add favorite functionality later
        self.userLocation = userLocation
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ctownMenuHeaderView = CTownMenuHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 258))
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

//        let attributedString = NSMutableAttributedString(string: "Coffee & Tea, Juice Bars & Smoothies, Acai Bowls")
//        attributedString.addAttribute(NSAttributedStringKey.kern, value: 0.01, range: NSMakeRange(0, attributedString.length))
//        ctownMenuHeaderView.cuisineLabel.attributedText = attributedString
        
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
        //ctownMenuHeaderView.clipsToBounds = true
        
        ctownMenuTableView = UITableView()
        ctownMenuTableView.backgroundColor = .wash
        ctownMenuTableView.tableHeaderView = ctownMenuHeaderView
        ctownMenuTableView.delegate = self
        ctownMenuTableView.dataSource = self
        ctownMenuTableView.register(CTownInformativeTableViewCell.self, forCellReuseIdentifier: cTownInformativeReuseIdentifier)
        view.addSubview(ctownMenuTableView)        
        
        setupConstraints()
    }
    
    func setupConstraints(){
        
        ctownMenuTableView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // Tableview Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return ctownMenuHeaderView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 187 //the magic constant
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 306
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 39
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cTownInformativeReuseIdentifier, for: indexPath) as! CTownInformativeTableViewCell
        cell.informativeTextLabel.text = cellLabels[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case IndexPath(index: 0):
        break //get directions
        case IndexPath(index: 1):
        break //call number
        case IndexPath(index: 2):
        break //bring up website
        default:
            break
    }
}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
