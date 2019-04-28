//
//  RatingView.swift
//  Eatery
//
//  Created by Gonzalo Gonzalez on 3/23/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class RatingView: UIView {

    var containerView: UIView!
    var containerImageView: [UIImageView]!
    var ratingImageView: [UIImageView]!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        containerView = UIView()
        addSubview(containerView)
        
        containerImageView = [UIImageView]()
        ratingImageView = [UIImageView]()
        
        for i in 0...5{
            let container = UIImageView()
            let star = UIImageView()
            if i == 0{
                star.image = UIImage(named:"halfselected")
            } else {
                star.image = UIImage(named: "unselected")
            }
            containerImageView.append(container)
            ratingImageView.append(star)
            addSubview(containerImageView[i])
            addSubview(ratingImageView[i])
        }
        
        setupConstraints()
    }
    
    func setupConstraints(){
        
        let containerOffset = 0.5
        let starInset = 1.75
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalTo(104)
        }
        containerImageView[4].snp.makeConstraints { make in
            make.top.bottom.equalTo(containerView)
            make.trailing.equalTo(containerView)
            make.width.equalTo(20)
        }
        
        ratingImageView[4].snp.makeConstraints { make in
            make.edges.equalTo(containerImageView[4]).inset(starInset)
        }
        
        containerImageView[3].snp.makeConstraints { make in
            make.top.bottom.equalTo(containerView)
            make.trailing.equalTo(containerImageView[4].snp.leading).offset(containerOffset)
            make.width.equalTo(20)
        }
        
        ratingImageView[3].snp.makeConstraints { make in
            make.edges.equalTo(containerImageView[3]).inset(starInset)
        }
        
        containerImageView[2].snp.makeConstraints { make in
            make.top.bottom.equalTo(containerView)
            make.trailing.equalTo(containerImageView[3].snp.leading).offset(containerOffset)
            make.width.equalTo(20)
        }
        
        ratingImageView[2].snp.makeConstraints { make in
            make.edges.equalTo(containerImageView[2]).inset(starInset)
        }
        
        containerImageView[1].snp.makeConstraints { make in
            make.top.bottom.equalTo(containerView)
            make.trailing.equalTo(containerImageView[2].snp.leading).offset(containerOffset)
            make.width.equalTo(20)
        }
        
        ratingImageView[1].snp.makeConstraints { make in
            make.edges.equalTo(containerImageView[1]).inset(starInset)
        }
        
        containerImageView[0].snp.makeConstraints { make in
            make.top.bottom.equalTo(containerView)
            make.trailing.equalTo(containerImageView[1].snp.leading).offset(containerOffset)
            make.width.equalTo(20)
        }
        
        ratingImageView[0].snp.makeConstraints { make in
            make.edges.equalTo(containerImageView[0]).inset(starInset)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
