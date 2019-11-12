//
//  OnboardingPageControl.swift
//  Eatery
//
//  Created by Reade Plunkett on 11/12/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class OnboardingPageControl: UIPageControl {
    override func layoutSubviews() {
        super.layoutSubviews()

        guard !subviews.isEmpty else { return }

        let spacing: CGFloat = 3

        let width: CGFloat = 15

        let height = spacing

        var total: CGFloat = 0

        for view in subviews {
            view.layer.cornerRadius = 40
            view.frame = CGRect(x: total, y: frame.size.height / 2 - height / 2, width: width, height: height)
            total += width + spacing
        }

        total -= spacing

        frame.origin.x = frame.origin.x + frame.size.width / 2 - total / 2
        frame.size.width = total
    }
}
