import UIKit

@objc protocol EateryMenuCellDelegate {
    @objc optional func didTapShareMenuButton(_ cell: EateryMenuTableViewCell?)
}

class EateryMenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var shareMenuButton: UIButton!
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var shareIcon: UIImageView!
    
    var delegate: EateryMenuCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        contentView.backgroundColor = .lightGray
    }
    
    @IBAction func didTapShareMenuButton(_ sender: UIButton) {
        delegate?.didTapShareMenuButton!(self)
    }
}
