import UIKit

class BRBTableViewCell: UITableViewCell {

    let leftLabel = UILabel()
    let rightLabel = UILabel()
    let centerLabel = UILabel()
    
    var leftC = UIColor(), rightC = UIColor(), centerC = UIColor()
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if selectionStyle != .none {
            contentView.backgroundColor = highlighted ? .eateryBlue : .white
            leftLabel.textColor = highlighted ? .white : leftC
            rightLabel.textColor = highlighted ? .white : rightC
            centerLabel.textColor = highlighted ? .white : centerC
        }
    }
    
    func setTextColors(leftColor : UIColor = .black, rightColor: UIColor = .gray, centerColor: UIColor = .eateryBlue) {
        leftC = leftColor
        leftLabel.textColor = leftC
        rightC = rightColor
        rightLabel.textColor = rightC
        centerC = centerColor
        centerLabel.textColor = centerC
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: reuseIdentifier == "MoreCell" ? .default : style, reuseIdentifier: reuseIdentifier)

        setTextColors() // initialize to defaults

        contentView.backgroundColor = .white
        
        // add custom labels
        
        rightLabel.textColor = .gray
        centerLabel.textColor = .eateryBlue
        centerLabel.textAlignment = .center

        contentView.addSubview(leftLabel)
        contentView.addSubview(rightLabel)
        contentView.addSubview(centerLabel)

        leftLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20.0)
            make.centerY.equalToSuperview()
        }

        centerLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        rightLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20.0)
            make.centerY.equalToSuperview()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        leftLabel.text = nil
        rightLabel.text = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
