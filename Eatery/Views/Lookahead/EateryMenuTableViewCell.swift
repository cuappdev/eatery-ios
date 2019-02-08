import UIKit

protocol EateryMenuCellDelegate: AnyObject {
    func didTapShareMenuButton(_ cell: EateryMenuTableViewCell?)
}

class EateryMenuTableViewCell: UITableViewCell {

    // Share features may be removed soon
    // var shareMenuButton = UIButton()
    // var shareIcon = UIImageView()

    var menuImageView = UIImageView()
    
    weak var delegate: EateryMenuCellDelegate?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        contentView.backgroundColor = .wash

        menuImageView.contentMode = .scaleToFill
        contentView.addSubview(menuImageView)
        menuImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(14)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

    private func didTapShareMenuButton(_ sender: UIButton) {
        delegate?.didTapShareMenuButton(self)
    }

}
