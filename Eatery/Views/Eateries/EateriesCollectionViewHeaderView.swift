import UIKit

class EateriesCollectionViewHeaderView: UICollectionReusableView {

    private let titleLabel: UILabel
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    var titleColor: UIColor? {
        get { return titleLabel.textColor }
        set { titleLabel.textColor = newValue }
    }

    override init(frame: CGRect) {
        titleLabel = UILabel()

        super.init(frame: frame)

        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Avoid using nibs in Eatery")
    }

}
