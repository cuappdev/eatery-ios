import UIKit

@objc protocol FilterDateViewDelegate {
    @objc optional func didFilterDate(_ sender: UIButton)
}

class FilterDateView: UIView {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateButton: UIButton!
    
    var filterDateView: UIView!
    var delegate: FilterDateViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        filterDateView = loadViewFromNib()
        filterDateView.frame = bounds
        filterDateView.autoresizingMask = .flexibleWidth
        
        addSubview(filterDateView)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "FilterDateView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    @IBAction func didFilterDate(_ sender: UIButton) {
        delegate?.didFilterDate!(sender)
    }
}
