import UIKit
import SnapKit

enum Filter: String {
    case nearest = "Nearest First"
    case north = "North"
    case west = "West"
    case central = "Central"
    case swipes = "Swipes"
    case brb = "BRB"
}

fileprivate let filters: [Filter] = [
    .nearest,
    .north,
    .west,
    .central,
    .swipes,
    .brb
]

protocol FilterBarDelegate: class {
    var filters: Set<Filter> { get set }
    func updateFilters(filters: Set<Filter>)
}

class FilterBar: UIView {
    
    private var buttons: [UIButton] = []
    weak var delegate: FilterBarDelegate?
    var scrollView: UIScrollView!

    let padding: CGFloat = collectionViewMargin
    
    private var selectedFilters: Set<Filter> = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear

        scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInset.left = padding
        scrollView.contentInset.right = padding
        scrollView.alwaysBounceHorizontal = true
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        layoutButtons()
    }
    
    func layoutButtons() {

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
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let prevFilters = UserDefaults.standard.stringArray(forKey: "filters") {
            for string in prevFilters {
                if let filter = Filter(rawValue: string),
                    let index = filters.index(of: filter), index < buttons.count {
                    buttons[index].isSelected = true
                    selectedFilters.insert(filter)
                }
            }
            
            delegate?.filters = selectedFilters
        }
    }
    
    @objc func buttonPressed(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            selectedFilters.insert(filters[sender.tag])
            switch filters[sender.tag] {
            case .swipes:
                if let index = filters.index(of: .brb) {
                    buttons[index].isSelected = false
                    selectedFilters.remove(.brb)
                }
            case .brb:
                if let index = filters.index(of: .swipes) {
                    buttons[index].isSelected = false
                    selectedFilters.remove(.swipes)
                }
            case .north:
                if let westIndex = filters.index(of: .west) {
                    buttons[westIndex].isSelected = false
                    selectedFilters.remove(.west)
                }
                if let centralIndex = filters.index(of: .central) {
                    buttons[centralIndex].isSelected = false
                    selectedFilters.remove(.central)
                }
            case .west:
                if let northIndex = filters.index(of: .north) {
                    buttons[northIndex].isSelected = false
                    selectedFilters.remove(.north)
                }
                if let centralIndex = filters.index(of: .central) {
                    buttons[centralIndex].isSelected = false
                    selectedFilters.remove(.central)
                }
            case .central:
                if let westIndex = filters.index(of: .west) {
                    buttons[westIndex].isSelected = false
                    selectedFilters.remove(.west)
                }
                if let northIndex = filters.index(of: .north) {
                    buttons[northIndex].isSelected = false
                    selectedFilters.remove(.north)
                }
            default:
                break
            }
        } else {
            selectedFilters.remove(filters[sender.tag])
        }
        let defaults = UserDefaults.standard
        defaults.set(selectedFilters.map { $0.rawValue }, forKey: "filters")

        delegate?.updateFilters(filters: selectedFilters)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
