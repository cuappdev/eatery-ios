import UIKit
import SnapKit
import DiningStack

class EateryARDetailCard: UIView {
    var topLabel: UILabel!
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!

    init(eatery: Eatery) {
        super.init(frame: .zero)

        backgroundColor = .white

        topLabel = UILabel()
        topLabel.text = "Near You"
        topLabel.textColor = .lightGray
        topLabel.font = .systemFont(ofSize: 12.0, weight: .semibold)
        addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20.0)
        }

        titleLabel = UILabel()
        titleLabel.text = eatery.nickname
        titleLabel.font = .systemFont(ofSize: 28.0, weight: .semibold)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(topLabel.snp.bottom).offset(4.0)
            make.leading.equalToSuperview().inset(20.0)
        }

        subtitleLabel = UILabel()
        subtitleLabel.text = "Tap to view more"
        subtitleLabel.font = .systemFont(ofSize: 18.0, weight: .semibold)
        subtitleLabel.textColor = .gray
        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4.0)
            make.leading.equalToSuperview().inset(20.0)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
