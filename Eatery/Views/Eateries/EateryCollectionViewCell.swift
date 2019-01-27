import UIKit
import CoreLocation
import Kingfisher
import SnapKit

class EateryCollectionViewCell: UICollectionViewCell {

    private static let shadowRadius: CGFloat = 12

    let paymentContainer: UIView = UIView()
    let paymentImageViews: [UIImageView] = [
        UIImageView(),
        UIImageView(),
        UIImageView()
    ]

    let backgroundImageView = UIImageView()
    let closedOverlay = UIView()

    let infoContainer = UIView()
    let titleLabel = UILabel()
    let statusLabel = UILabel()
    let timeLabel = UILabel()
    let distanceLabel = UILabel()

    let separator = UIView()

    let menuTextView = UITextView()
    private var menuTextViewHiddenConstraints = [Constraint]()
    private var menuTextViewVisibleConstraints = [Constraint]()

    var isMenuTextViewVisible: Bool = false {
        didSet {
            if isMenuTextViewVisible {
                showMenuTextView()
            } else {
                hideMenuTextView()
            }
        }
    }

    var eatery: Eatery? {
        didSet {
            updateInfoViews()
        }
    }

    var userLocation: CLLocation? {
        didSet {
            updateDistanceLabelText()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true

        layer.shadowRadius = EateryCollectionViewCell.shadowRadius
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 4.0, height: 4.0)
        layer.masksToBounds = false

        contentView.backgroundColor = .white

        setUpBackgroundViews()
        setUpPaymentViews()
        setUpInfoViews()
        setUpSeparator()
        setUpMenuView()

        // activate constraints to hide text view
        hideMenuTextView()
    }

    private func setUpBackgroundViews() {
        backgroundImageView.contentMode = .scaleAspectFill
        contentView.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        closedOverlay.backgroundColor = UIColor(white: 1.0, alpha: 0.65)
        backgroundImageView.addSubview(closedOverlay)
        closedOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setUpPaymentViews() {
        contentView.addSubview(paymentContainer)
        paymentContainer.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(10)
        }

        paymentContainer.addSubview(paymentImageViews[2])
        paymentImageViews[2].snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.height.equalTo(20)
        }

        paymentContainer.addSubview(paymentImageViews[1])
        paymentImageViews[1].snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(paymentImageViews[2].snp.trailing).offset(5)
            make.width.height.equalTo(20)
        }

        paymentContainer.addSubview(paymentImageViews[0])
        paymentImageViews[0].snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
            make.leading.equalTo(paymentImageViews[1].snp.trailing).offset(5)
            make.width.height.equalTo(20)
        }
    }

    private func setUpInfoViews() {
        infoContainer.backgroundColor = .white
        contentView.addSubview(infoContainer)
        infoContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
        menuTextViewHiddenConstraints.append(contentsOf: infoContainer.snp.prepareConstraints { make in
            make.bottom.equalToSuperview()
        })
        menuTextViewVisibleConstraints.append(contentsOf: infoContainer.snp.prepareConstraints { make in
            make.top.equalToSuperview()
        })

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(751), for: .vertical)
        titleLabel.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
        titleLabel.setContentHuggingPriority(UILayoutPriority(251), for: .vertical)
        infoContainer.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(10)
        }

        distanceLabel.font = .systemFont(ofSize: 11, weight: .medium)
        infoContainer.addSubview(distanceLabel)
        distanceLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalTo(titleLabel)
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
        }

        statusLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        statusLabel.setContentCompressionResistancePriority(UILayoutPriority(751), for: .vertical)
        statusLabel.setContentHuggingPriority(UILayoutPriority(251), for: .horizontal)
        statusLabel.setContentHuggingPriority(UILayoutPriority(251), for: .vertical)
        infoContainer.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.bottom.equalToSuperview().inset(10)
        }

        timeLabel.font = .systemFont(ofSize: 12, weight: .medium)
        infoContainer.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(statusLabel.snp.trailing).offset(2)
            make.lastBaseline.equalTo(statusLabel.snp.lastBaseline)
            make.trailing.equalToSuperview().inset(10)
        }
    }

    private func setUpSeparator() {
        separator.backgroundColor = .separator
        contentView.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.top.equalTo(infoContainer.snp.bottom)
            make.height.equalTo(1)
            make.leading.trailing.equalToSuperview().inset(10)
        }
    }

    private func setUpMenuView() {
        menuTextView.font = .systemFont(ofSize: 11)
        menuTextView.isEditable = false
        menuTextView.isSelectable = false
        menuTextView.textColor = UIColor(white: 0.33, alpha: 1)
        menuTextView.isScrollEnabled = false
        menuTextView.bounces = false
        menuTextView.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        contentView.addSubview(menuTextView)
        menuTextView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        menuTextViewVisibleConstraints.append(contentsOf: menuTextView.snp.prepareConstraints { make in
            make.top.equalTo(separator.snp.bottom)
        })
        menuTextViewHiddenConstraints.append(contentsOf: menuTextView.snp.prepareConstraints { make in
            make.height.equalTo(0)
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

    private func updateDistanceLabelText() {
        if let eatery = eatery, let userLocation = userLocation {
            let distance = userLocation.distance(from: eatery.location, in: .miles)
            distanceLabel.text = "\(Double(round(10 * distance) / 10)) mi"
        } else {
            distanceLabel.text = "-- mi"
        }
    }

    private func updateInfoViews() {
        guard let eatery = eatery else {
            return
        }

        // start loading background image view as soon as possible

        if let url = URL(string: eateryImagesBaseURL + eatery.slug + ".jpg") {
            let placeholder = UIImage.image(withColor: UIColor(white: 0.97, alpha: 1.0))
            backgroundImageView.kf.setImage(with: url, placeholder: placeholder, options: [.transition(.fade(0.35))])
        }

        // title

        titleLabel.text = eatery.nickname

        // distance

        updateDistanceLabelText()

        // payment

        var images: [UIImage] = []

        if eatery.paymentMethods.contains(.Cash) || eatery.paymentMethods.contains(.CreditCard), let icon = UIImage(named: "cashIcon") {
            images.append(icon)
        }

        if eatery.paymentMethods.contains(.BRB), let icon = UIImage(named: "brbIcon") {
            images.append(icon)
        }

        if eatery.paymentMethods.contains(.Swipes), let icon = UIImage(named: "swipeIcon") {
            images.append(icon)
        }

        for (image, imageView) in zip(images, paymentImageViews) {
            imageView.image = image
            imageView.isHidden = false
        }

        for imageView in paymentImageViews[images.count...] {
            imageView.isHidden = true
        }

        // text of status label, time label
        // text color of all info labels
        // overlay visibility

        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        switch eateryStatus {
        case let .open(status, message):
            statusLabel.text = status
            timeLabel.text = message

            titleLabel.textColor = .black
            statusLabel.textColor = .eateryGreen
            timeLabel.textColor = .lightGray
            distanceLabel.textColor = .lightGray

            closedOverlay.isHidden = true

        case let .closing(status, message):
            statusLabel.text = status
            timeLabel.text = message

            titleLabel.textColor = .black
            statusLabel.textColor = .eateryRed
            timeLabel.textColor = .lightGray
            distanceLabel.textColor = .lightGray

            closedOverlay.isHidden = true

        case let .closed(status, message):
            statusLabel.text = status
            timeLabel.text = message

            titleLabel.textColor = .darkGray
            statusLabel.textColor = .darkGray
            timeLabel.textColor = .lightGray
            distanceLabel.textColor = .lightGray

            closedOverlay.isHidden = false
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }

    private func hideMenuTextView() {
        for constraint in menuTextViewVisibleConstraints {
            constraint.deactivate()
        }
        for constraint in menuTextViewHiddenConstraints {
            constraint.activate()
        }

        backgroundImageView.isHidden = false
    }

    private func showMenuTextView() {
        for constraint in menuTextViewHiddenConstraints {
            constraint.deactivate()
        }
        for constraint in menuTextViewVisibleConstraints {
            constraint.activate()
        }
        
        backgroundImageView.isHidden = true
    }

}
