//
//  BRBLoginErrorView.swift
//  Eatery
//
//  Created by William Ma on 9/2/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import SnapKit
import UIKit

class BRBLoginErrorView: UIView {
    
    private var containerView: UIView!
    var errorLabel: UILabel!
    
    private var collapsedConstraint: Constraint!
    var isCollapsed: Bool {
        get { return collapsedConstraint.isActive }
        set { collapsedConstraint.isActive = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.shadowOpacity = 0.33
        layer.shadowOffset = .zero
        layer.cornerRadius = 8
        backgroundColor = .eateryRed

        containerView = UIView(frame: .zero)
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.center.width.equalToSuperview()
            make.height.equalToSuperview().priority(999)
        }
        
        errorLabel = UILabel(frame: .zero)
        errorLabel.numberOfLines = 0
        errorLabel.textColor = .white
        errorLabel.textAlignment = .center
        containerView.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        snp.prepareConstraints { make in
            collapsedConstraint = make.height.equalTo(0).constraint
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
