//
//  GivingDayViewController.swift
//  Eatery
//
//  Created by Gonzalo Gonzalez on 3/11/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class GivingDayViewController: UIViewController {

    var blurEffectView: UIVisualEffectView!
    var givingDayPopupView: GivingDayView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        // blur effect setup
        if !UIAccessibility.isReduceTransparencyEnabled {
            view.isOpaque = false
            let blurEffect = UIBlurEffect(style: .dark)
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(blurEffectView)
        }
        
        givingDayPopupView = GivingDayView()
        givingDayPopupView.closePopupButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        givingDayPopupView.donateButton.addTarget(self, action: #selector(openDonateSite), for: .touchUpInside)
        givingDayPopupView.layer.cornerRadius = 10
        givingDayPopupView.clipsToBounds = true
        view.addSubview(givingDayPopupView)
        
        setupConstraints()
    }
    
    func setupConstraints(){
        blurEffectView.snp.makeConstraints { make in
            make.top.trailing.leading.bottom.equalToSuperview()
        }
        
        givingDayPopupView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.equalTo(431)
            make.width.equalTo(288)
        }
    }
    
    @objc func dismissPopup(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func openDonateSite(){
        guard let url = URL(string: "https://givingday.cornell.edu/campaigns/cu-app-development") else { return }
        UIApplication.shared.open(url)
    }

}
