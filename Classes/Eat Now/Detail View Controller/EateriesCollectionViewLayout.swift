//
//  EateriesCollectionViewLayout.swift
//  Eatery
//
//  Created by Eric Appel on 12/2/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit
import DiningStack

class EateriesCollectionViewLayout: UICollectionViewFlowLayout, UICollectionViewDelegateFlowLayout {

    var eateryData: [String: [Eatery]] = [:]
    var controller: EateriesGridViewController!
    var pushedViewController = false
    let navBarDisplayThreshold = CGFloat(50)
        
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 20)
    }
    
    // MARK: -
    // MARK: UICollectionViewDelegate
    
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        print("did select")
//        
//        var eatery: Eatery!
//        
//        var section = indexPath.section
//        if eateryData["Favorites"]?.count == 0 {
//            section += 1
//        }
//        switch section {
//        case 0:
//            eatery = eateryData["Favorites"]![indexPath.row]
//        case 1:
//            eatery = eateryData["Central"]![indexPath.row]
//        case 2:
//            eatery = eateryData["West"]![indexPath.row]
//        case 3:
//            eatery = eateryData["North"]![indexPath.row]
//        default:
//            print("Invalid section in grid view.")
//        }
//        
//        let detailViewController = MenuViewController()
//        detailViewController.eatery = eatery
//        detailViewController.delegate = controller
//        controller.navigationController?.pushViewController(detailViewController, animated: true)
//        pushedViewController = true
//    }
    
    
//    var indexPathsToAnimate: [NSIndexPath] = []
//    override func prepareForCollectionViewUpdates(updateItems: [UICollectionViewUpdateItem]) {
//        super.prepareForCollectionViewUpdates(updateItems)
//        var indexPaths: [NSIndexPath] = []
//        for updateItem in updateItems {
//            switch updateItem.updateAction {
//            case .Insert:
//                indexPaths.append(updateItem.indexPathAfterUpdate)
//            case .Delete:
//                indexPaths.append(updateItem.indexPathBeforeUpdate)
//            case .Move:
//                indexPaths.append(updateItem.indexPathAfterUpdate)
//                indexPaths.append(updateItem.indexPathBeforeUpdate)
//            default:
//                print("")
//            }
//        }
//        indexPathsToAnimate = indexPaths
//    }
//    
//    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
//        let attributes = layoutAttributesForItemAtIndexPath(itemIndexPath)
//        if indexPathsToAnimate.contains(itemIndexPath) {
//            attributes?.transform = CGAffineTransformMakeScale(0.2, 0.2)
//            attributes?.center = CGPointMake(collectionView!.center.x, collectionView!.frame.height)
//            indexPathsToAnimate.removeAtIndex(indexPathsToAnimate.indexOf(itemIndexPath)!)
//        }
//        return attributes
//    }
    
}
