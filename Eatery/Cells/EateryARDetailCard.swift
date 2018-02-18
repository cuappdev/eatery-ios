import UIKit
import SnapKit
import DiningStack

class EateryARDetailCard: UIView {
    var topIcon: UIImageView!
    var topLabel: UILabel!
    var titleLabel: UILabel!
    var statusLabel: UILabel!
    var timeLabel: UILabel!
    var viewMoreLabel: UILabel!

    init(eatery: Eatery) {
        super.init(frame: .zero)

        backgroundColor = .white
        layer.cornerRadius = 8.0
        layer.shadowRadius = 52.0
        layer.shadowOpacity = 0.5

        topIcon = UIImageView(image: #imageLiteral(resourceName: "blackEateryPin"))
        topIcon.tintColor = .eateryBlue
        topIcon.contentMode = .scaleAspectFit
        addSubview(topIcon)
        topIcon.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20.0)
            make.size.equalTo(14.0)
        }

        topLabel = UILabel()
        topLabel.text = "Near You"
        topLabel.textColor = .eateryBlue
        topLabel.font = .systemFont(ofSize: 14.0, weight: .semibold)
        addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.leading.equalTo(topIcon.snp.trailing).offset(4.0)
            make.centerY.equalTo(topIcon)
            make.height.equalTo(18.0)
        }

        titleLabel = UILabel()
        titleLabel.text = eatery.nickname
        titleLabel.font = .systemFont(ofSize: 28.0, weight: .semibold)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(topLabel.snp.bottom).offset(4.0)
            make.leading.equalToSuperview().inset(20.0)
            make.height.equalTo(32.0)
        }

        statusLabel = UILabel()
        statusLabel.text = "Tap to view more"
        statusLabel.font = .systemFont(ofSize: 18.0, weight: .semibold)
        statusLabel.textColor = .gray
        addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4.0)
            make.leading.equalToSuperview().inset(20.0)
            make.height.equalTo(24.0)
        }

        timeLabel = UILabel()
        timeLabel.font = .systemFont(ofSize: 18.0, weight: .medium)
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.leading.equalTo(statusLabel.snp.trailing).offset(4.0)
            make.centerY.equalTo(statusLabel)
        }

        viewMoreLabel = UILabel()
        viewMoreLabel.text = "Tap to view more"
        viewMoreLabel.font = .systemFont(ofSize: 14.0, weight: .semibold)
        viewMoreLabel.textColor = .lightGray
        addSubview(viewMoreLabel)
        viewMoreLabel.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(4.0)
            make.leading.equalToSuperview().inset(20.0)
            make.bottom.equalToSuperview().inset(60.0)
        }

        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        switch eateryStatus {
        case .open(let message):
            titleLabel.textColor = .black
            statusLabel.text = "Open"
            statusLabel.textColor = .eateryBlue
            timeLabel.text = message
            timeLabel.textColor = .gray
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
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func highlight() {
        UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            self.transform = CGAffineTransform(translationX: 0.0, y: -20.0)
        }, completion: nil)
    }

    func unhighlight() {
        UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            self.transform = .identity
        }, completion: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        highlight()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if bounds.contains(touch.location(in: self)) {
                highlight()
            } else {
                unhighlight()
            }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        unhighlight()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        unhighlight()
    }
}
