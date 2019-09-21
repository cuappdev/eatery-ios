//
//  UINavigationBarAppearance+Eatery.swift
//  Eatery
//
//  Created by William Ma on 9/21/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
extension UINavigationBarAppearance {

    static let eateryDefault: UINavigationBarAppearance = {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundColor = .eateryBlue
        return appearance
    }()

}
