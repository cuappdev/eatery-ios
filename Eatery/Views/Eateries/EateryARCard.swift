import UIKit
import SnapKit
import Kingfisher
import CoreLocation

class EateryARCard: UIView {

    var titleLabel: UILabel!
    var statusLabel: UILabel!
    var timeLabel: UILabel!
    var distanceLabel: UILabel!
    var eatery: Eatery!

    init(frame: CGRect, eatery: Eatery, userLocation: CLLocation?) {
        super.init(frame: frame)

        self.eatery = eatery

        backgroundColor = .white

        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .semibold)
        titleLabel.text = eatery.nickname

        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.top.equalToSuperview().inset(10)
        }

        statusLabel = UILabel()
        statusLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .semibold)
        addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.equalToSuperview().inset(10)
            make.height.equalTo(14.0)
            make.bottom.equalToSuperview().inset(10)
        }

        timeLabel = UILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 12.0)
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(statusLabel.snp.trailing).offset(4)
            make.centerY.equalTo(statusLabel)
        }

        distanceLabel = UILabel()
        distanceLabel.font = UIFont.systemFont(ofSize: 11.0, weight: .medium)
        addSubview(distanceLabel)
        distanceLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.centerY.equalTo(titleLabel)
            
        }

        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        switch eateryStatus {
        case let .open(status, message):
            statusLabel.text = status
            timeLabel.text = message
            
            titleLabel.textColor = .black
            statusLabel.textColor = .eateryBlue
            timeLabel.textColor = .gray
            distanceLabel.textColor = .darkGray

        case let .closing(status, message):
            statusLabel.text = status
            timeLabel.text = message

            titleLabel.textColor = .black
            statusLabel.textColor = .eateryRed
            timeLabel.textColor = .gray
            distanceLabel.textColor = .darkGray

        case let .closed(status, message):
            statusLabel.text = status
            timeLabel.text = message

            titleLabel.textColor = .darkGray
            statusLabel.textColor = .darkGray
            timeLabel.textColor = .gray
            distanceLabel.textColor = .gray
        }

        update(userLocation: userLocation)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(userLocation: CLLocation?) {
        if let distance = userLocation?.distance(from: eatery.location) {
            distanceLabel.text = "\(Double(round(10 * distance / metersInMile) / 10)) mi"
        } else {
            distanceLabel.text = "-- mi"
        }
    }

}
