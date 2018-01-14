import UIKit
import DiningStack
import CoreLocation
import Kingfisher

let metersInMile: Double = 1609.344

class EateryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var menuTextView: UITextView!
    @IBOutlet weak var menuTextViewHeight: NSLayoutConstraint!
    @IBOutlet var paymentImageViews: [UIImageView]!
    @IBOutlet weak var paymentContainer: UIView!

    static let shadowRadius: CGFloat = 16

    var eatery: Eatery!

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = .white
        
        menuTextView.text = nil
        menuTextView.textContainerInset = UIEdgeInsets(top: 10.0, left: 6.0, bottom: 10.0, right: 6.0)
    }
    
    func update(userLocation: CLLocation?) {
        if let distance = userLocation?.distance(from: eatery.location) {
            distanceLabel.text = "\(Double(round(10 * distance / metersInMile) / 10)) mi"
        } else {
            distanceLabel.text = "-- mi"
        }
    }
    
    func set(eatery: Eatery, userLocation: CLLocation?) {
        self.eatery = eatery
        
        titleLabel.text = eatery.nickname

        if let url = URL(string: eateryImagesBaseURL + eatery.slug + ".jpg") {
            let placeholder = UIImage.image(withColor: UIColor(white: 0.97, alpha: 1.0))
            backgroundImageView.kf.setImage(with: url, placeholder: placeholder, options: [.transition(.fade(0.35))])
        }
        
        update(userLocation: userLocation)
        
        var images: [UIImage] = []
        
        if (eatery.paymentMethods.contains(.Cash) || eatery.paymentMethods.contains(.CreditCard)) {
            images.append(#imageLiteral(resourceName: "cashIcon"))
        }
        
        if (eatery.paymentMethods.contains(.BRB)) {
            images.append(#imageLiteral(resourceName: "brbIcon"))
        }
        
        if (eatery.paymentMethods.contains(.Swipes)) {
            images.append(#imageLiteral(resourceName: "swipeIcon"))
        }
        
        for (index, imageView) in paymentImageViews.enumerated() {
            if index < images.count {
                imageView.image = images[index]
                imageView.isHidden = false
            } else {
                imageView.isHidden = true
            }
        }

        backgroundImageView.subviews.last?.removeFromSuperview()
        
        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        switch eateryStatus {
        case .open(let message):
            titleLabel.textColor = .black
            statusLabel.text = "Open"
            statusLabel.textColor = .eateryBlue
            timeLabel.text = message
            timeLabel.textColor = .gray
            distanceLabel.textColor = .darkGray
        case .closed(let message):
            if !eatery.isOpenToday() {
                statusLabel.text = "Closed Today"
                timeLabel.text = ""
            } else {
                statusLabel.text = "Closed"
                timeLabel.text = message
            }

            titleLabel.textColor = .darkGray
            statusLabel.textColor = .gray
            timeLabel.textColor = .gray
            distanceLabel.textColor = .gray

            let closedView = UIView()
            closedView.backgroundColor = UIColor(white: 1.0, alpha: 0.65)
            backgroundImageView.addSubview(closedView)
            closedView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true

        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shadowRadius = EateryCollectionViewCell.shadowRadius
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 4.0, height: 4.0)
        layer.masksToBounds = false
    }
}
