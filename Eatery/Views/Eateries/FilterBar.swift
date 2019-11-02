import UIKit
import SnapKit

enum Filter: String {

    static let areaFilters: Set<Filter> = [
        .north,
        .west,
        .central
    ]

    static let categoryFilters: Set<Filter> = [
        .pizza,
        .chinese,
        .wings,
        .korean,
        .japanese,
        .thai,
        .burgers,
        .mexican,
        .bubbleTea
    ]

    case nearest = "Nearest First"

    case north = "North"
    case west = "West"
    case central = "Central"
    case swipes = "Swipes"
    case brb = "BRB"

    case pizza = "Pizza"
    case chinese = "Chinese"
    case wings = "Wings"
    case korean = "Korean"
    case japanese = "Japanese"
    case thai = "Thai"
    case burgers = "Burgers"
    case mexican = "Mexican"
    case bubbleTea = "Bubble Tea"

}

protocol FilterBarDelegate: AnyObject {

    func filterBar(_ filterBar: FilterBar, selectedFiltersDidChange newValue: [Filter])

    func filterBar(_ filterBar: FilterBar, filterWasSelected filter: Filter)

}

class FilterBar: UIView {

    private var buttons: [Filter : UIButton] = [:]
    weak var delegate: FilterBarDelegate?
    var scrollView: UIScrollView!

    let padding: CGFloat = EateriesViewController.collectionViewMargin

    var displayedFilters: [Filter] = [] {
        didSet {
            layoutButtons(filters: displayedFilters)

            if let prevFilters = UserDefaults.standard.stringArray(forKey: "filters") {
                for string in prevFilters {
                    if let filter = Filter(rawValue: string), buttons.keys.contains(filter) {
                        selectedFilters.insert(filter)
                        buttons[filter]!.isSelected = true
                    }
                }

                delegate?.filterBar(self, selectedFiltersDidChange: Array(selectedFilters))
            }
        }
    }
    var selectedFilters: Set<Filter> = []

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

        snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }

    func layoutButtons(filters: [Filter]) {
        var totalWidth: CGFloat = 0.0

        var previousLayout: UIButton?
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
            button.isSelected = selectedFilters.contains(filter)
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
                if previousLayout == nil {
                    make.leading.equalToSuperview()
                } else {
                    make.leading.equalTo(previousLayout!.snp.trailing).offset(padding / 2)
                }
            }
            buttons[filter] = button
            previousLayout = button

            totalWidth += button.frame.width + (index == filters.count - 1 ? 0.0 : padding / 2)
        }

        scrollView.contentSize = CGSize(width: totalWidth, height: frame.height)
        scrollView.setContentOffset(CGPoint(x: -padding, y: 0), animated: false)
    }

    @objc func buttonPressed(sender: UIButton) {
        sender.isSelected.toggle()

        if sender.isSelected {
            let filter = displayedFilters[sender.tag]
            selectedFilters.insert(filter)

            delegate?.filterBar(self, filterWasSelected: filter)
        } else {
            selectedFilters.remove(displayedFilters[sender.tag])
        }
        
        let defaults = UserDefaults.standard
        defaults.set(selectedFilters.map { $0.rawValue }, forKey: "filters")

        delegate?.filterBar(self, selectedFiltersDidChange: Array(selectedFilters))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
