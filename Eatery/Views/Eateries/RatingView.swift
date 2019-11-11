//
//  RatingView.swift
//  Eatery
//
//  Created by Gonzalo Gonzalez on 3/23/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class RatingView: UIView {

    /// Stars arranged from left to right. That is, ratingImageView[0] is on the
    /// leading edge and ratingImageView[4] is on the trailing edge
    private let ratingImageViews: [UIImageView] = (0...4).map { _ in UIImageView() }

    var rating: Double? = nil {
        didSet {
            guard let rating = rating else {
                for imageView in ratingImageViews {
                    imageView.image = UIImage(named: "unselected")
                }

                return
            }

            var accumulatedRating = 0.0
            for imageView in ratingImageViews {
                if accumulatedRating + 1 <= rating {
                    imageView.image = UIImage(named: "selected")
                    accumulatedRating += 1
                } else if accumulatedRating < rating {
                    imageView.image = UIImage(named: "halfSelected")
                    accumulatedRating += 1
                } else {
                    imageView.image = UIImage(named: "unselected")
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        for imageView in ratingImageViews {
            addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.height.width.equalTo(22)
            }
        }

        ratingImageViews[0].snp.makeConstraints { make in
            make.leading.equalToSuperview()
        }

        for i in 1...4 {
            ratingImageViews[i].snp.makeConstraints { make in
                make.leading.equalTo(ratingImageViews[i - 1].snp.trailing).offset(2)
            }
        }

        ratingImageViews[4].snp.makeConstraints { make in
            make.trailing.equalToSuperview()
        }

        for imageView in ratingImageViews {
            imageView.image = UIImage(named: "unselected")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
