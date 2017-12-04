import UIKit

class EateriesCollectionViewGridLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }

        let width = collectionView.bounds.width
        let cellWidth: CGFloat
        
        if collectionView.traitCollection.horizontalSizeClass == .regular || UIDevice.current.orientation.isLandscape {
            cellWidth = (width / 2) - kCollectionViewGutterWidth * 2
        } else {
            cellWidth = width - kCollectionViewGutterWidth * 2
        }

        itemSize = CGSize(width: cellWidth, height: cellWidth * 0.4)
        minimumLineSpacing = kCollectionViewGutterWidth
        minimumInteritemSpacing = kCollectionViewGutterWidth
        sectionInset = UIEdgeInsets(top: 0, left: kCollectionViewGutterWidth, bottom: 32, right: kCollectionViewGutterWidth)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
