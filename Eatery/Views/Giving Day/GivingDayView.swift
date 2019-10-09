//
//  GivingDayView.swift
//  Eatery
//
//  Created by Gonzalo Gonzalez on 3/11/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class GivingDayView: UIView {
    
    var topPortionView: UIView!
    var closePopupButton: UIButton!
    var givingDayAppsImageView: UIImageView!
    var supportUsLabel: UILabel!
    
    var bottomPortionView: UIView!
    var supportDescriptionTextView: UITextView!
    var donateButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        topPortionView = UIView()
        topPortionView.backgroundColor = .white
        addSubview(topPortionView)
        
        closePopupButton = UIButton()
        closePopupButton.setImage(UIImage(named: "closeIcon"), for: .normal)
        addSubview(closePopupButton)
        
        givingDayAppsImageView = UIImageView()
        givingDayAppsImageView.image = UIImage(named: "givingDayApps")
        givingDayAppsImageView.contentMode = .scaleAspectFit
        addSubview(givingDayAppsImageView)
        
        supportUsLabel = UILabel()
        supportUsLabel.text = "Support Us On Giving Day 3.14"
        supportUsLabel.numberOfLines = 0
        supportUsLabel.textAlignment = .center
        supportUsLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        addSubview(supportUsLabel)
        
        bottomPortionView = UIView()
        bottomPortionView.backgroundColor = .wash
        addSubview(bottomPortionView)
        
        supportDescriptionTextView = UITextView()
        //line spacing
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 6
        let attributes = [NSAttributedStringKey.paragraphStyle : style]
        supportDescriptionTextView.attributedText = NSAttributedString(string: "Support Eatery by donating to Cornell AppDev! Funding will help us add new features like crowdedness, collegetown eateries, and more!", attributes: attributes)
        supportDescriptionTextView.isSelectable = false
        supportDescriptionTextView.isScrollEnabled = false
        supportDescriptionTextView.textAlignment = .center
        supportDescriptionTextView.backgroundColor = .wash
        supportDescriptionTextView.font = UIFont.systemFont(ofSize: 13)
        addSubview(supportDescriptionTextView)
        
        donateButton = UIButton()
        donateButton.setTitle("Donate", for: .normal)
        donateButton.setTitleColor(.white, for: .normal)
        donateButton.backgroundColor = .eateryBlue
        donateButton.layer.cornerRadius = 5
        addSubview(donateButton)
        
        setupConstraints()
    }
    
    func setupConstraints(){
        topPortionView.snp.makeConstraints { make in
            make.top.leading.trailing.width.equalToSuperview()
            make.height.equalTo(238)
        }

        closePopupButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(topPortionView).inset(12)
            make.width.height.equalTo(32)
        }

        givingDayAppsImageView.snp.makeConstraints { make in
            make.top.equalTo(topPortionView).inset(72)
            make.leading.equalTo(topPortionView).inset(18)
            make.width.equalTo(252)
            make.height.equalTo(76)
        }

        supportUsLabel.snp.makeConstraints { make in
            make.top.equalTo(givingDayAppsImageView).inset(100)
            make.leading.trailing.equalTo(topPortionView).inset(70)
            make.height.equalTo(50)
        }

        bottomPortionView.snp.makeConstraints { make in
            make.bottom.leading.trailing.width.equalToSuperview()
            make.height.equalTo(193)
        }

        supportDescriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(bottomPortionView).inset(24)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }

        donateButton.snp.makeConstraints { make in
            make.bottom.equalTo(bottomPortionView).inset(24)
            make.leading.equalToSuperview().inset(98)
            make.width.equalTo(92)
            make.height.equalTo(40)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
