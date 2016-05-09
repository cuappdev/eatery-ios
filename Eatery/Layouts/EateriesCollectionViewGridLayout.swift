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
        var cellWidth = floor(width / 2 - kCollectionViewGutterWidth * 1.5)
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            cellWidth = floor(width / 3 - kCollectionViewGutterWidth * 1.5)
        }
        itemSize = CGSize(width: cellWidth, height: cellWidth * 0.8)
        minimumLineSpacing = kCollectionViewGutterWidth
        minimumInteritemSpacing = kCollectionViewGutterWidth / 2
        sectionInset = UIEdgeInsets(top: 2, left: kCollectionViewGutterWidth, bottom: 16, right: kCollectionViewGutterWidth)
        headerReferenceSize = CGSizeMake(cellWidth, 40)
    }
    
    override func collectionViewContentSize() -> CGSize {
        var size = super.collectionViewContentSize()
        if (size.height < collectionView!.frame.height + 44) {
            size.height = collectionView!.frame.height + 44
        }
        return size
    }
}
