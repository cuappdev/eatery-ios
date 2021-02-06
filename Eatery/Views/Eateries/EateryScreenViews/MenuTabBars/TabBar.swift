//
//  TabBar.swift
//  Eatery
//
//  Created by Sergio Diaz on 11/15/20.
//  Copyright © 2020 Cornell AppDev. All rights reserved.
//

import UIKit
import SnapKit

class TabBar: UIControl {

    var scrollView: UIScrollView!
    var tabButtons: [UIButton] = []
    var stackView: UIStackView!
    var underlineView: UIView!

    var selectedSegmentIndex: Int = 0

    init(sections: [String]) {
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func tabButtonPressed(_ sender: UIButton) {
        guard let index = tabButtons.firstIndex(of: sender) else { return }

        select(at: index)
        sendActions(for: .valueChanged)
    }

    func select(at index: Int) {
        selectedSegmentIndex = index
    }

}
