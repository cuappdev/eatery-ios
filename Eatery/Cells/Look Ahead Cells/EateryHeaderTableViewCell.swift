import UIKit

@objc protocol EateryHeaderCellDelegate {
    @objc optional func didTapInfoButton(_ cell: EateryHeaderTableViewCell)
    @objc optional func didTapToggleMenuButton(_ cell: EateryHeaderTableViewCell)
}

class EateryHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eateryNameLabel: UILabel!
    @IBOutlet weak var eateryHoursLabel: UILabel!
    @IBOutlet weak var moreInfoIndicatorImageView: UIImageView!

    fileprivate var tapGestureRecognizer: UITapGestureRecognizer?
    var delegate: EateryHeaderCellDelegate?
    var isExpanded: Bool = false {
        didSet {
            moreInfoIndicatorImageView.image =
                (isExpanded) ? UIImage(named: "upArrow.png") : UIImage(named: "downArrow.png")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        moreInfoIndicatorImageView.image = UIImage(named: "upArrow.png")
    }
    
    override func didMoveToWindow() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EateryHeaderTableViewCell.eateryHeaderCellPressed(_:)))
        tapGestureRecognizer?.delegate = self
        tapGestureRecognizer?.cancelsTouchesInView = false
        addGestureRecognizer(tapGestureRecognizer!)
    }
    
    @objc func eateryHeaderCellPressed(_ sender: UITapGestureRecognizer) {
        delegate?.didTapToggleMenuButton?(self)
    }
    
}
