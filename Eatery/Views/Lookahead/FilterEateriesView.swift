import UIKit

@objc protocol FilterEateriesViewDelegate {

    @objc optional func didFilterMeal(_ sender: UIButton)
    @objc optional func didFilterDate(_ sender: UIButton)

}

class FilterEateriesView: UIView, UIGestureRecognizerDelegate {

    static func loadFromNib() -> FilterEateriesView {
        return UINib(nibName: "FilterEateriesView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! FilterEateriesView
    }

    @IBOutlet private weak var filterContainerView: UIView!

    @IBOutlet weak var firstDateView: FilterDateView!
    @IBOutlet weak var secondDateView: FilterDateView!
    @IBOutlet weak var thirdDateView: FilterDateView!
    @IBOutlet weak var fourthDateView: FilterDateView!
    @IBOutlet weak var fifthDateView: FilterDateView!
    @IBOutlet weak var sixthDateView: FilterDateView!
    @IBOutlet weak var seventhDateView: FilterDateView!

    @IBOutlet private weak var filterMealsView: UIView!
    @IBOutlet weak var filterBreakfastButton: UIButton!
    @IBOutlet weak var filterLunchButton: UIButton!
    @IBOutlet weak var filterDinnerButton: UIButton!

    var filterDateHeight: CGFloat {
        return filterContainerView.frame.height - filterMealsView.frame.height
    }
    
    fileprivate var tapGestureRecognizer: UITapGestureRecognizer?
    weak var delegate: FilterEateriesViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func didFilterMeal(_ sender: UIButton) {
        delegate?.didFilterMeal!(sender)
    }
    
    override func didMoveToWindow() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(filterEateriesCellPressed))
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
