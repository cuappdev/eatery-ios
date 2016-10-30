//
//  EateriesCollectionViewHeaderView.swift
//  Eatery
//
//  Created by Eric Appel on 12/1/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

class EateriesCollectionViewHeaderView: UICollectionReusableView {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.collectionViewBackground
    }
}
