//
//  CollegetownMenuViewController.swift
//  Eatery
//
//  Created by William Ma on 10/30/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import CoreLocation
import UIKit

class CollegetownMenuViewController: EateriesMenuViewController {

    private let eatery: CollegetownEatery

    init(eatery: CollegetownEatery, userLocation: CLLocation?) {
        self.eatery = eatery
        
        super.init(eatery: eatery , userLocation: userLocation)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addMenuInfoView(CollegetownMenuInfoView.self)
        addBlockSeparator()

        addActionButton("Get Directions", action: #selector(directionsButtonPressed(_:)))
        addSeparatorView()
        addActionButton("Call \(eatery.phone)", action: #selector(callEateryButtonPressed))
        addSeparatorView()
        addActionButton("Open \(eatery.displayName) on Yelp", action: #selector(openInYelpButtonPressed(_:)))
        addBlockSeparator()

        addMapView()
        addBlockSeparator()
    }

    private func addActionButton(_ title: String, action: Selector) {
        let container = UIView()

        let actionButton = UIButton()
        actionButton.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
        actionButton.contentHorizontalAlignment = .leading
        actionButton.setTitle(title, for: .normal)
        actionButton.setTitleColor(.eateryBlue, for: .normal)
        actionButton.addTarget(self, action: action, for: .touchUpInside)
        container.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(4)
        }

        addToStackView(container)
    }

    private func addMapView() {

        
    }

    // MARK: Actions

    @objc private func directionsButtonPressed(_ sender: UIButton) {
        openDirectionsToEatery()
    }

    @objc private func callEateryButtonPressed(_ sender: UIButton) {
        if let url = URL(string: "tel://\(eatery.phone)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    @objc private func openInYelpButtonPressed(_ sender: UIButton) {
        if let url = eatery.url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

}
