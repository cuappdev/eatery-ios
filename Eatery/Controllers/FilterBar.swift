import UIKit
import SnapKit

enum Filter: String {
    case nearest = "Nearest"
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
    
    private var selectedFilters: Set<Filter> = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(white: 0.93, alpha: 1)
        
        scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInset.left = 10.0
        scrollView.contentInset.right = 10.0
        scrollView.alwaysBounceHorizontal = true
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        for (index, filter) in filters.enumerated() {
            let button = UIButton()
            button.setTitle(filter.rawValue, for: .normal)
            button.setTitleColor(UIColor.eateryBlue, for: .normal)
            button.layer.cornerRadius = 4.0
            button.clipsToBounds = true
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
            button.sizeToFit()
            button.frame.size.width += 16.0
            button.frame.size.height = frame.height - 20.0
            button.center.y = frame.height / 2

            if index > 0 {
                button.frame.origin.x = buttons[index - 1].frame.maxX + 10.0
            } else {
                button.frame.origin.x = 0.0
            }

            button.tag = index
            button.setBackgroundImage(UIImage.image(withColor: UIColor.white), for: .normal)
            button.setBackgroundImage(UIImage.image(withColor: UIColor.eateryBlue), for: .highlighted)
            button.setBackgroundImage(UIImage.image(withColor: UIColor.eateryBlue), for: .selected)
            button.setTitleColor(UIColor.white, for: .selected)
            button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)

            scrollView.addSubview(button)
            buttons.append(button)
        }

        scrollView.contentSize = CGSize(width: buttons.last?.frame.maxX ?? 0.0, height: frame.height)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let prevFilters = UserDefaults.standard.stringArray(forKey: "filters") {
            for string in prevFilters {
                if let filter = Filter(rawValue: string),
                    let index = filters.index(of: filter) {
                    buttons[index].isSelected = true
                    selectedFilters.insert(filter)
                }
            }
            
            delegate?.filters = selectedFilters
        }
    }
    
    func buttonPressed(sender: UIButton) {
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
