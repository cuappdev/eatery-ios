//
//  OnboardingModel.swift
//  Eatery
//
//  Created by Reade Plunkett on 11/11/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class OnboardingModel {
    var title: String
    var subtitle: String
    var image: UIImage?

    init(title: String, subtitle: String, image: UIImage?) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }
}
