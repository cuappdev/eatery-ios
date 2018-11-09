import UIKit

@objc protocol FilterEateriesViewDelegate {
    @objc optional func didFilterMeal(_ sender: UIButton)
    @objc optional func didFilterDate(_ sender: UIButton)
}

class FilterEateriesTableViewCell: UITableViewCell {

    @IBOutlet weak var filterBreakfastButton: UIButton!
    @IBOutlet weak var filterLunchButton: UIButton!
    @IBOutlet weak var filterDinnerButton: UIButton!
    
    fileprivate var tapGestureRecognizer: UITapGestureRecognizer?
    var delegate: FilterEateriesViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    @IBAction func didFilterMeal(_ sender: UIButton) {
        delegate?.didFilterMeal!(sender)
    }

}
