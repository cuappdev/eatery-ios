import UIKit

protocol FilterDateViewDelegate: class {

    func filterDateViewWasSelected(_ filterDateView: FilterDateView, sender button: UIButton)

}

class FilterDateView: UIView {

    var dayLabel = UILabel()
    var dateLabel = UILabel()
    var dateButton = UIButton()

    weak var delegate: FilterDateViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        dateButton.setTitle(nil, for: .normal)
        addSubview(dateButton)
        dateButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        dayLabel.textAlignment = .center
        dayLabel.font = .systemFont(ofSize: 12, weight: .medium)
        dayLabel.textColor = UIColor.colorFromCode(0xACADAE)
        addSubview(dayLabel)
        dayLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(15)
        }

        dateLabel.textAlignment = .center
        dateLabel.font = .systemFont(ofSize: 28, weight: .semibold)
        dateLabel.textColor = UIColor.colorFromCode(0xACADAE)
        addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(dayLabel.snp.bottom)
        }

        dateButton.addTarget(self, action: #selector(dateButtonPressed(_:)), for: .touchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

    @objc private func dateButtonPressed(_ sender: UIButton) {
        delegate?.filterDateViewWasSelected(self, sender: sender)
    }

}
