import UIKit
import SnapKit
import Crashlytics

enum Filter: String, CaseIterable {
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
    case boba = "Boba"

    static func getCampusFilters() -> [Filter] {
        return Array(Filter.allCases.prefix(upTo: 6))
    }

    static func getCollegetownFilters() -> [Filter] {
        var ctownFilters = Array(Filter.allCases.suffix(from: 6))
        ctownFilters.insert(Filter.nearest, at: 0)
        return ctownFilters
    }
}

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

    private var buttons: [Filter : UIButton] = [:]
    weak var delegate: FilterBarDelegate?
    var scrollView: UIScrollView!

    let padding: CGFloat = collectionViewMargin

    private var displayedFilters: [Filter] = []
    private var selectedFilters: Set<Filter> = []

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

        layoutButtons(filters: Filter.getCampusFilters())
        layoutButtons(filters: Filter.getCollegetownFilters())
        setDisplayedFilters(filters: Filter.getCampusFilters())
    }

    func setDisplayedFilters(filters: [Filter]) {
        displayedFilters = filters
        updateDisplayedFilters()
    }

    private func updateDisplayedFilters() {
        for filter in buttons.keys {
            buttons[filter]?.isHidden = !displayedFilters.contains(filter)
            buttons[filter]?.isSelected = selectedFilters.contains(filter)
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
            button.isHidden = true

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

            totalWidth += button.frame.width + (index == Filter.allCases.count - 1 ? 0.0 : padding / 2)
        }

        scrollView.contentSize = CGSize(width: totalWidth, height: frame.height)
        scrollView.setContentOffset(CGPoint(x: -padding, y: 0), animated: false)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let prevFilters = UserDefaults.standard.stringArray(forKey: "filters") {
            for string in prevFilters {
                if let filter = Filter(rawValue: string) {
                    selectedFilters.insert(filter)
                    buttons[filter]!.isSelected = true
                }
            }
            
            delegate?.filters = selectedFilters
        }
    }

    @objc func buttonPressed(sender: UIButton) {
        sender.isSelected.toggle()

        if sender.isSelected {
            let filter = displayedFilters[sender.tag]
            selectedFilters.insert(filter)
            // TODO:
            // Answers.logEateryFilterApplied(filterType: filter.rawValue)
        } else {
            selectedFilters.remove(displayedFilters[sender.tag])
        }

        delegate?.filterBar(self, selectedFiltersDidChange: selectedFilters.map { $0 })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
