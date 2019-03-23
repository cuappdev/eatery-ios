//
//  RatingView.swift
//  Eatery
//
//  Created by Gonzalo Gonzalez on 3/23/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class RatingView: UIView {

    var ratingImageView = [UIImageView]()
    var starOffset = 1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        ratingImageView = [UIImageView]()
        for i in 0...5{
            let star = UIImageView()
            ratingImageView.append(star)
            addSubview(ratingImageView[i])
        }
        
        setupConstraints()
    }
    
    func setupConstraints(){
        
        ratingImageView[0].snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().inset(86)
            make.width.equalTo(20)
        }
        
        ratingImageView[1].snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(ratingImageView[0].snp.trailing).offset(starOffset)
            make.width.equalTo(20)
        }
        
        ratingImageView[2].snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(ratingImageView[1].snp.trailing).offset(starOffset)
            make.width.equalTo(20)
        }
        
        ratingImageView[3].snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(ratingImageView[2].snp.trailing).offset(starOffset)
            make.width.equalTo(20)
        }
        
        ratingImageView[4].snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(ratingImageView[3].snp.trailing).offset(starOffset)
            make.width.equalTo(20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
