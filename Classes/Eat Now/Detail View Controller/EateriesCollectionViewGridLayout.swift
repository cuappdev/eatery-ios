//
//  EateriesCollectionViewGridLayout.swift
//  Eatery
//
//  Created by Eric Appel on 12/2/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

class EateriesCollectionViewGridLayout: UICollectionViewFlowLayout {
    
    override func prepareLayout() {
        super.prepareLayout()
        
        guard let collectionView = collectionView else {return}
        let width = collectionView.bounds.width
        let cellWidth = floor(width / 2 - kCollectionViewGutterWidth * 1.5)
        itemSize = CGSize(width: cellWidth, height: cellWidth * 0.8)
        minimumLineSpacing = kCollectionViewGutterWidth
        minimumInteritemSpacing = kCollectionViewGutterWidth / 2
        sectionInset = UIEdgeInsets(top: 10, left: kCollectionViewGutterWidth, bottom: 20, right: kCollectionViewGutterWidth)
    }
}
