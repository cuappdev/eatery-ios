import UIKit
import SnapKit
import Crashlytics

protocol FilterBarDelegate: AnyObject {

    func filterBar(_ filterBar: FilterBar, selectedFiltersDidChange newValue: [FilterBar.Filter])

}

class FilterBar: UIView {

    enum Filter: String, CaseIterable {

        case nearest = "Nearest First"
        case north = "North"
        case west = "West"
        case central = "Central"
        case swipes = "Swipes"
        case brb = "BRB"

    }
    
    private var buttons: [UIButton] = []
    private let scrollView = UIScrollView()

    private let padding: CGFloat = EateriesViewController.collectionViewMargin

    private(set) var selectedFilters: Set<Filter> = []
    var filters = Filter.allCases {
        didSet {
            layoutButtons()
        }
    }

    weak var delegate: FilterBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInset.left = padding
        scrollView.contentInset.right = padding
        scrollView.alwaysBounceHorizontal = true
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        layoutButtons()
    }
    
    func layoutButtons() {
        for button in buttons {
            button.removeFromSuperview()
        }
        buttons.removeAll(keepingCapacity: true)

        var totalWidth: CGFloat = 0.0

        for (index, filter) in filters.enumerated() {
            let button = UIButton()
            button.setTitle(filter.rawValue, for: .normal)

            button.setTitleColor(UIColor.eateryBlue.withAlphaComponent(0.8), for: .normal)
            button.setTitleColor(UIColor.eateryBlue.withAlphaComponent(0.8), for: .highlighted)
            button.setTitleColor(.white, for: .selected)
            button.setBackgroundImage(UIImage.image(withColor: UIColor(white: 0.95, alpha: 1.0)), for: .normal)
            button.setBackgroundImage(UIImage.image(withColor: UIColor(white: 0.85, alpha: 1.0)), for: .highlighted)
            button.setBackgroundImage(UIImage.image(withColor: UIColor.eateryBlue), for: .selected)
            button.setBackgroundImage(UIImage.image(withColor: UIColor.transparentEateryBlue), for: .focused)

            button.layer.cornerRadius = 8.0
            button.clipsToBounds = true
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
            button.sizeToFit()
            button.frame.size.width += 16.0
            button.frame.size.height = frame.height
            button.center.y = frame.height / 2

            button.tag = index
            button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
            
            scrollView.addSubview(button)
            button.snp.makeConstraints { make in
                make.centerY.equalTo(snp.centerY)
                make.width.equalTo(button.frame.size.width)
                make.height.equalToSuperview().offset(-padding)
                if index > 0 {
                    make.leading.equalTo(buttons[index-1].snp.trailing).offset(padding / 2)
                } else {
                    make.leading.equalToSuperview()
                }
            }
            buttons.append(button)

            totalWidth += button.frame.width + (index == filters.count - 1 ? 0.0 : padding / 2)
        }

        scrollView.contentSize = CGSize(width: totalWidth, height: frame.height)
        scrollView.setContentOffset(CGPoint(x: -padding, y: 0), animated: false)
    }
    
    @objc func buttonPressed(sender: UIButton) {
        sender.isSelected.toggle()

        if sender.isSelected {
            let filter = filters[sender.tag]
            selectedFilters.insert(filter)
            // TODO: 
            // Answers.logEateryFilterApplied(filterType: filter.rawValue)
        } else {
            selectedFilters.remove(filters[sender.tag])
        }

        delegate?.filterBar(self, selectedFiltersDidChange: selectedFilters.map { $0 })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
