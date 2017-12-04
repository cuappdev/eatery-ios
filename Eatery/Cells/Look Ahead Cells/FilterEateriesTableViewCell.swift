import UIKit

@objc protocol FilterEateriesViewDelegate {
    @objc optional func didFilterMeal(_ sender: UIButton)
    @objc optional func didFilterDate(_ sender: UIButton)
}

class FilterEateriesTableViewCell: UITableViewCell {
    @IBOutlet weak var filterTitleLabel: UILabel!
    @IBOutlet weak var firstDateView: FilterDateView!
    @IBOutlet weak var secondDateView: FilterDateView!
    @IBOutlet weak var thirdDateView: FilterDateView!
    @IBOutlet weak var fourthDateView: FilterDateView!
    @IBOutlet weak var fifthDateView: FilterDateView!
    @IBOutlet weak var sixthDateView: FilterDateView!
    @IBOutlet weak var seventhDateView: FilterDateView!
    @IBOutlet weak var filterBreakfastButton: UIButton!
    @IBOutlet weak var filterLunchButton: UIButton!
    @IBOutlet weak var filterDinnerButton: UIButton!
    
    fileprivate var tapGestureRecognizer: UITapGestureRecognizer?
    var delegate: FilterEateriesViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        filterTitleLabel.text = UIScreen.isNarrowScreen() ? "VIEW MENUS & HOURS FOR AN UPCOMING TIME" : "VIEW MENUS AND HOURS FOR AN UPCOMING TIME"
    }
    
    @IBAction func didFilterMeal(_ sender: UIButton) {
        delegate?.didFilterMeal!(sender)
    }
    
    override func didMoveToWindow() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FilterEateriesTableViewCell.filterEateriesCellPressed(_:)))
        tapGestureRecognizer?.delegate = self
        tapGestureRecognizer?.cancelsTouchesInView = false
        addGestureRecognizer(tapGestureRecognizer!)
    }
    
    @objc func filterEateriesCellPressed(_ sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: self)
        let hitView = hitTest(tapPoint, with: nil)
        
        let filterDateButtons = [firstDateView.dateButton, secondDateView.dateButton, thirdDateView.dateButton, fourthDateView.dateButton, fifthDateView.dateButton, sixthDateView.dateButton, seventhDateView.dateButton]
        
        for button in filterDateButtons {
            if hitView == button {
                delegate?.didFilterDate!(button!)
                break
            }
        }
    }
}
