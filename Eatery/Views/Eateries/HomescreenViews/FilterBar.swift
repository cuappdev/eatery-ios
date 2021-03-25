import SnapKit
import SwiftyUserDefaults
import UIKit

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
    case favorites = "Favorite Items"

}

protocol FilterBarDelegate: AnyObject {

    func filterBar(_ filterBar: FilterBar, selectedFiltersDidChange newValue: [Filter])

    func filterBar(_ filterBar: FilterBar, filterWasSelected filter: Filter)

}

class FilterBar: UIView {

    // Half the height of a UISearchBar embedded in a UINavigationBar
    private static let filterBarHeight = 56 / 2

    private var buttons: [Filter: UIButton] = [:]
    weak var delegate: FilterBarDelegate?
    var scrollView: UIScrollView!

    let padding: CGFloat = EateriesViewController.collectionViewMargin

    var displayedFilters: [Filter] = [] {
        didSet {
            layoutButtons(filters: displayedFilters)

            for string in Defaults[\.filters] {
                if let filter = Filter(rawValue: string), buttons.keys.contains(filter) {
                    selectedFilters.insert(filter)
                }
            }

            delegate?.filterBar(self, selectedFiltersDidChange: Array(selectedFilters))
        }
    }
    var selectedFilters: Set<Filter> = [] {
        didSet {
            for (filter, button) in buttons {
                button.isSelected = selectedFilters.contains(filter)
            }
            Defaults[\.filters] = selectedFilters.map { $0.rawValue }
        }
    }

    private let impactGenerator = UIImpactFeedbackGenerator(style: .light)

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
            make.height.equalTo(FilterBar.filterBarHeight)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
                make.height.equalToSuperview()
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
        let filter = displayedFilters[sender.tag]
        toggleFilter(filter, scrollVisible: false, notifyDelegate: true)
    }

    func toggleFilter(_ filter: Filter, scrollVisible: Bool, notifyDelegate: Bool = false) {
        if selectedFilters.contains(filter) {
            selectedFilters.remove(filter)
        } else {
            selectedFilters.insert(filter)

            if notifyDelegate {
                delegate?.filterBar(self, filterWasSelected: filter)
            }
        }

        if scrollVisible, let button = buttons[filter] {
            scrollView.scrollRectToVisible(button.frame, animated: true)
        }

        if notifyDelegate {
            delegate?.filterBar(self, selectedFiltersDidChange: Array(selectedFilters))
        }

        impactGenerator.impactOccurred()
    }

}
