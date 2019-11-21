//
//  Kingfisher+Eatery.swift
//  Eatery
//
//  Created by William Ma on 11/17/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import Kingfisher

extension Kingfisher where Base == UIImageView {

    func setImage(with eatery: Eatery) {
        let placeholder = UIImage.image(withColor: UIColor(white: 0.97, alpha: 1.0))
        if let url = eatery.imageUrl {
            setImage(with: url, placeholder: placeholder, options: [.transition(.fade(0.35))])
        }
    }

}
