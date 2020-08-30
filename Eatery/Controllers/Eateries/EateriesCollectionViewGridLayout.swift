import UIKit

/**
    This class works closely with `EateriesViewController` to layout the items
    in its collection view.
 
    The `itemSize`, `sectionInset`, and `headerReferenceSize` properties are
    stored here and the eateries collection view has custom logic in
    its `UICollectionViewDelegateFlowLayout` conformance to decide
    whether to return the values set here or its own values.
 
    The grid layout will arrange two eateries per row in horizontally regular
    and vertically compact layouts, and one eatery per row otherwise.
*/
class EateriesCollectionViewGridLayout: UICollectionViewFlowLayout {

    override func prepare() {
        guard let collectionView = collectionView else {
            return
        }

        let margin = EateriesViewController.collectionViewMargin

        let cellWidth: CGFloat
        if collectionView.traitCollection.horizontalSizeClass == .regular
            || collectionView.traitCollection.verticalSizeClass == .compact {
            cellWidth = (collectionView.bounds.width / 2) - margin * 1.5
        } else {
            cellWidth = collectionView.bounds.width - margin * 2
        }
        itemSize = CGSize(width: cellWidth, height: cellWidth * 0.4)

        minimumLineSpacing = margin
        minimumInteritemSpacing = margin
        sectionInset = UIEdgeInsets(top: 0.0, left: margin, bottom: 0.0, right: margin)

        headerReferenceSize = CGSize(width: collectionView.bounds.width, height: 56)
    }

}
