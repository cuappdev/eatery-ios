import UIKit
import CoreLocation
import Kingfisher
import NVActivityIndicatorView
import SnapKit

class EateryCollectionViewCell: UICollectionViewCell {

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    private static let shadowRadius: CGFloat = 12

    let paymentView = PaymentMethodsView()

    let backgroundImageView = UIImageView()
    private let closedOverlay = UIView()

    let infoContainer = UIView()
    let titleLabel = UILabel()
    let statusLabel = UILabel()
    let timeLabel = UILabel()
    private let distanceLabel = UILabel()
    private let favoritesView = UILabel()

    private let separator = UIView()

    private let menuTextView = UITextView()
    private var favoriteHiddenConstraints = [Constraint]()
    private var favoriteVisibleConstraints = [Constraint]()

    var userLocation: CLLocation? {
        didSet {
            updateDistanceLabelText()
        }
    }

    private var eatery: Eatery?
    private var favorites: [String]?
    var isShowingFavorites: Bool = false {
        didSet {
            isShowingFavorites ? showFavorites() : hideFavorites()
        }
    }

    private let activityIndicatorBackground = UIView()

    private let activityIndicator = NVActivityIndicatorView(
        frame: CGRect(x: 0, y: 0, width: 22, height: 22),
        type: .circleStrokeSpin,
        color: .white
    )

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true

        layer.shadowRadius = EateryCollectionViewCell.shadowRadius
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 4.0, height: 4.0)
        layer.masksToBounds = false

        contentView.backgroundColor = .white

        setUpPaymentView()
        setUpInfoViews()
        setUpSeparator()
        setUpMenuView()
        setUpBackgroundViews()
        setupFavoritesView()

        // activate constraints to hide text view
        hideFavorites()
    }

    private func setUpBackgroundViews() {
        backgroundImageView.contentMode = .scaleAspectFill
        contentView.insertSubview(backgroundImageView, at: 0)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        closedOverlay.backgroundColor = UIColor(white: 1.0, alpha: 0.65)
        backgroundImageView.addSubview(closedOverlay)
        closedOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let layoutGuide = UILayoutGuide()
        addLayoutGuide(layoutGuide)
        layoutGuide.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(infoContainer.snp.top)
        }

        activityIndicatorBackground.backgroundColor = UIColor(white: 0.0, alpha: 0.65)
        activityIndicatorBackground.layer.cornerRadius = 8
        backgroundImageView.addSubview(activityIndicatorBackground)
        activityIndicatorBackground.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.center.equalTo(layoutGuide)
        }

        activityIndicatorBackground.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.width.height.equalTo(22)
            make.center.equalToSuperview()
        }
    }

    private func setUpPaymentView() {
        contentView.addSubview(paymentView)
        paymentView.layer.zPosition = 1
        paymentView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(10)
        }
    }

    private func setUpInfoViews() {
        infoContainer.isOpaque = false
        infoContainer.backgroundColor = .white
        contentView.addSubview(infoContainer)
        infoContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
        favoriteHiddenConstraints.append(
            contentsOf: infoContainer.snp.prepareConstraints { make in
            make.bottom.equalToSuperview()
            }
        )
        favoriteVisibleConstraints.append(
            contentsOf: infoContainer.snp.prepareConstraints { make in
            make.top.equalToSuperview()
            }
        )

        titleLabel.isOpaque = false
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
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
        }
        favoriteVisibleConstraints.append(
            contentsOf: distanceLabel.snp.prepareConstraints { make in
            make.centerY.equalTo(titleLabel)
            }
        )
        favoriteHiddenConstraints.append(
            contentsOf: distanceLabel.snp.prepareConstraints { make in
            make.centerY.equalToSuperview()
            }
        )

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
        menuTextView.isUserInteractionEnabled = false
        contentView.addSubview(menuTextView)
        menuTextView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        favoriteVisibleConstraints.append(
            contentsOf: menuTextView.snp.prepareConstraints { make in
            make.top.equalTo(separator.snp.bottom)
            }
        )
        favoriteHiddenConstraints.append(
            contentsOf: menuTextView.snp.prepareConstraints { make in
            make.height.equalTo(0)
            }
        )
    }

    private func setupFavoritesView() {
        favoritesView.numberOfLines = 0
        favoritesView.backgroundColor = .clear

        contentView.addSubview(favoritesView)
        favoritesView.snp.makeConstraints { make in
            make.top.equalTo(infoContainer.snp.bottom).offset(2.5)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        favoriteHiddenConstraints.append(
            contentsOf: favoritesView.snp.prepareConstraints { make in
                make.height.equalTo(0)
            }
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

    private func updateDistanceLabelText() {
        if let eatery = eatery, let userLocation = userLocation {
            let distance = userLocation.distance(from: eatery.location).converted(to: .miles).value
            distanceLabel.text = "\(Double(round(10 * distance) / 10)) mi"
        } else {
            distanceLabel.text = "-- mi"
        }
    }

    func configure(eatery: Eatery, showFavorites: Bool) {
        self.eatery = eatery
        favorites = eatery.getFavorites()

        // start loading background image view as soon as possible

        backgroundImageView.kf.setImage(with: eatery)

        // title

        titleLabel.text = eatery.displayName

        // distance

        updateDistanceLabelText()

        // payment

        paymentView.paymentMethods = eatery.paymentMethods

        // text of status label, time label
        // text color of all info labels
        // overlay visibility

        let eateryStatus = eatery.currentStatus()
        switch eateryStatus {
        case .open, .closingSoon:
            titleLabel.textColor = .black
            closedOverlay.isHidden = true
        case .closed, .openingSoon:
            titleLabel.textColor = .darkGray
            closedOverlay.isHidden = false
        }

        let presentation = eatery.currentPresentation()
        statusLabel.text = presentation.statusText
        statusLabel.textColor = presentation.statusColor
        timeLabel.text = presentation.nextEventText

        timeLabel.textColor = .lightGray
        distanceLabel.textColor = .lightGray
        let favoriteFoods = eatery.getFavorites().sorted()
        if favoriteFoods.count > 0 {
            let font = UIFont.systemFont(ofSize: 14)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.paragraphSpacing = 0.25 * font.lineHeight

            let newLine = NSAttributedString(string: "\n")
            let favoritesText = NSMutableAttributedString()
            let maxHeight = frame.height - max(infoContainer.bounds.size.height, 56) // Max is for calculations before layout
            
            if favoriteFoods.count * font.lineHeight < maxHeight {
                
            } else {
                
            }
            
            for food in favoriteFoods {
                
                
                
            }
            if favoritesList.map { $0.size().height }.reduce(0, +) < maxHeight {
                for food in favoritesList {
                    favoritesText.append(food)
                    favoritesText.append(newLine)
                }
            } else {
                var lineWidth: CGFloat = 0
                var cannotDisplayFullText = false
                for food in favoritesList {
                    let emptyLineSpace = favoritesView.bounds.size.width - (lineWidth + food.size().width)
                    if cannotDisplayFullText ||
                        (favoritesText.size().height + font.lineHeight * 1.5 >= maxHeight &&
                            emptyLineSpace < food.size().width + font.xHeight * 3) {
                        cannotDisplayFullText = true
                        continue
                    }
                    if emptyLineSpace < 0 && lineWidth != 0 {
                        lineWidth = food.size().width
                        favoritesText.append(newLine)
                        favoritesText.append(food)
                    } else {
                        lineWidth += food.size().width
                        favoritesText.append(food)
                    }
                }
                if cannotDisplayFullText {
                    favoritesText.append(NSAttributedString(
                        string: "...",
                        attributes: [
                            .foregroundColor: UIColor.gray,
                            .font: font,
                            .paragraphStyle: paragraphStyle
                        ]
                    ))
                }
            }
            favoritesView.attributedText = favoritesText
        }
        isShowingFavorites = showFavorites
    }

    private func getFavoriteString(food: String, ending: Bool = false) {
        var name: NSMutableAttributedString = NSMutableAttributedString(
            string: " \(food.trim())",
            attributes: [
                .foregroundColor: UIColor.gray,
                .font: font,
                .paragraphStyle: paragraphStyle
            ]
        )
        if let image = UIImage.favoritedImage?.withRenderingMode(.automatic) {
            name = name.prependImage(image, yOffset: -1.5, scale: 0.5)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
    }

    private func hideFavorites() {
        favoritesView.isHidden = true
        distanceLabel.textAlignment = .right
        for constraint in favoriteVisibleConstraints {
            constraint.deactivate()
        }
        for constraint in favoriteHiddenConstraints {
            constraint.activate()
        }

        backgroundImageView.isHidden = false
    }

    private func showFavorites() {
        favoritesView.isHidden = false
        distanceLabel.textAlignment = .left
        for constraint in favoriteHiddenConstraints {
            constraint.deactivate()
        }
        for constraint in favoriteVisibleConstraints {
            constraint.activate()
        }

        backgroundImageView.isHidden = true
    }

    func setActivityIndicatorAnimating(_ animating: Bool, animated: Bool) {
        let actions: () -> Void = {
            if animating {
                self.activityIndicator.startAnimating()

                self.activityIndicator.alpha = 1
                self.activityIndicatorBackground.alpha = 1
            } else {
                self.activityIndicator.stopAnimating()

                self.activityIndicator.alpha = 0
                self.activityIndicatorBackground.alpha = 0
            }
        }

        if animated {
            UIView.animate(withDuration: 0.25, animations: actions)
        } else {
            actions()
        }
    }

}
