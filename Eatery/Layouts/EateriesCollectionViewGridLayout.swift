import UIKit

class EateriesCollectionViewGridLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }

        let width = collectionView.bounds.width
        let cellWidth: CGFloat
        
        if collectionView.traitCollection.horizontalSizeClass == .regular
            || collectionView.traitCollection.verticalSizeClass == .compact {
            cellWidth = (width / 2) - collectionViewMargin * 1.5
        } else {
            cellWidth = width - collectionViewMargin * 2
        }

        itemSize = CGSize(width: cellWidth, height: cellWidth * 0.4)
        minimumLineSpacing = collectionViewMargin
        minimumInteritemSpacing = collectionViewMargin
        sectionInset = UIEdgeInsets(top: collectionViewMargin, left: collectionViewMargin, bottom: 0.0, right: collectionViewMargin)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
