import UIKit

protocol FilterDateViewDelegate: AnyObject {

    func filterDateViewWasSelected(_ filterDateView: FilterDateView)

}

class FilterDateView: UIView {

    let dateLabel = UILabel()
    let dayLabel = UILabel()
    private let dateButton = UIButton()

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
        addSubview(dayLabel)
        dayLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(15)
        }

        dateLabel.textAlignment = .center
        dateLabel.font = .systemFont(ofSize: 28, weight: .semibold)
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
        delegate?.filterDateViewWasSelected(self)
    }

}
