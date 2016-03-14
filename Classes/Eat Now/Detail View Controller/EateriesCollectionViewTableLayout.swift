//
//  EateruesCollectionViewTableLayout.swift
//  Eatery
//
//  Created by Eric Appel on 12/2/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

class EateriesCollectionViewTableLayout: UICollectionViewFlowLayout {
    
    override func prepareLayout() {
        super.prepareLayout()
        
        guard let collectionView = collectionView else {return}
        let width = collectionView.bounds.width - kCollectionViewGutterWidth * 1.8
        itemSize = CGSize(width: width, height: width * 0.4)
        minimumLineSpacing = kCollectionViewGutterWidth / 1.2
        minimumInteritemSpacing = kCollectionViewGutterWidth / 1.8
        sectionInset = UIEdgeInsets(top: 2, left: 0, bottom: 20, right: 0)
        headerReferenceSize = CGSizeMake(width, 40)
    }
    
    override func collectionViewContentSize() -> CGSize {
        var size = super.collectionViewContentSize()
        if (size.height < collectionView!.frame.height + 44) {
            size.height = collectionView!.frame.height + 44
        }
        return size
    }
}
