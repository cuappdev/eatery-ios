import UIKit

class EateriesCollectionViewGridLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }

        let width = collectionView.bounds.width
        var cellWidth = floor(width - kCollectionViewGutterWidth * 2)

        switch collectionView.traitCollection.horizontalSizeClass {
        case .compact:
            break
        case .regular:
            cellWidth = (width / 2) - kCollectionViewGutterWidth * 2
        case .unspecified:
            break
        }

        itemSize = CGSize(width: cellWidth, height: cellWidth * 0.4)
        minimumLineSpacing = kCollectionViewGutterWidth
        minimumInteritemSpacing = kCollectionViewGutterWidth
        sectionInset = UIEdgeInsets(top: 8, left: kCollectionViewGutterWidth, bottom: 16, right: kCollectionViewGutterWidth)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
