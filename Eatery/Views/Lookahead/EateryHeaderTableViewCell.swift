import UIKit

protocol EateryHeaderCellDelegate: AnyObject {

    func didTapInfoButton(_ cell: EateryHeaderTableViewCell)
    func didTapToggleMenuButton(_ cell: EateryHeaderTableViewCell)

}

class EateryHeaderTableViewCell: UITableViewCell {
    
    let eateryNameLabel = UILabel()
    let eateryHoursLabel = UILabel()
    let moreInfoIndicatorImageView = UIImageView()

    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.eateryHeaderCellPressed(_:)))
        recognizer.delegate = self
        recognizer.cancelsTouchesInView = false
        return recognizer
    }()
    weak var delegate: EateryHeaderCellDelegate?

    var isExpanded = false {
        didSet {
            moreInfoIndicatorImageView.image =
                isExpanded ? UIImage(named: "upArrow.png") : UIImage(named: "downArrow.png")
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        addGestureRecognizer(tapGestureRecognizer)

        eateryNameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        contentView.addSubview(eateryNameLabel)
        eateryNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(13)
            make.leading.equalToSuperview().inset(10)
        }

        eateryHoursLabel.setContentHuggingPriority(UILayoutPriority(251), for: .vertical)
        eateryHoursLabel.font = .systemFont(ofSize: 12, weight: .medium)
        contentView.addSubview(eateryHoursLabel)
        eateryHoursLabel.snp.makeConstraints { make in
            make.top.equalTo(eateryNameLabel.snp.bottom)
            make.leading.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(12)
        }

        moreInfoIndicatorImageView.contentMode = .scaleAspectFit
        moreInfoIndicatorImageView.image = UIImage(named: "upArrow.png")
        contentView.addSubview(moreInfoIndicatorImageView)
        moreInfoIndicatorImageView.snp.makeConstraints { make in
            make.trailing.equalTo(contentView.snp.trailingMargin)
            make.width.equalTo(16)
            make.height.equalTo(10)
            make.centerY.equalToSuperview()
            make.leading.equalTo(eateryNameLabel.snp.trailing).inset(8)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }
    
    @objc func eateryHeaderCellPressed(_ sender: UITapGestureRecognizer) {
        delegate?.didTapToggleMenuButton(self)
    }
    
}
