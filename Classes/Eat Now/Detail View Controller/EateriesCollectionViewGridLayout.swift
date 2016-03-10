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
        
        enum UIUserInterfaceIdiom : Int {
            case Unspecified
            case Phone // iPhone and iPod touch style UI
            case Pad // iPad style UI
        }
        
        guard let collectionView = collectionView else {return}
        let width = collectionView.bounds.width
        var cellWidth = floor(width / 2 - kCollectionViewGutterWidth * 1.5)
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            cellWidth = floor(width / 3 - kCollectionViewGutterWidth * 1.5)
        }
        itemSize = CGSize(width: cellWidth, height: cellWidth * 0.8)
        minimumLineSpacing = kCollectionViewGutterWidth
        minimumInteritemSpacing = kCollectionViewGutterWidth / 2
        sectionInset = UIEdgeInsets(top: 10, left: kCollectionViewGutterWidth, bottom: 20, right: kCollectionViewGutterWidth)
    }
}
