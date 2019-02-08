import UIKit

protocol FilterEateriesViewDelegate: class {

    func filterEateriesView(_ filterEateriesView: FilterEateriesView, didFilterMeal sender: UIButton)
    func filterEateriesView(_ filterEateriesView: FilterEateriesView, didFilterDate sender: UIButton)

}

class FilterEateriesView: UIView, UIGestureRecognizerDelegate {

    let filterDatesContainer = UIView()
    let dateViews: [FilterDateView] =
        (1...7).map { _ in FilterDateView() }

    let filterMealsContainer = UIView()
    let filterBreakfastButton = UIButton()
    let filterLunchButton = UIButton()
    let filterDinnerButton = UIButton()

    var filterDateHeight: CGFloat {
        // the filterDatesContainer does not necessarily touch the filterMealsContainer,
        // so we must compute the height of the date view plus the whitespace between
        // the two containers
        return bounds.height - filterMealsContainer.frame.height
    }

    weak var delegate: FilterEateriesViewDelegate?

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        for view in dateViews {
            view.delegate = self
        }

        addSubview(filterDatesContainer)
        filterDatesContainer.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(44)
        }

        filterDatesContainer.addSubview(dateViews[0])
        dateViews[0].snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
        }
        for (prev, view) in zip(dateViews[..<(dateViews.count - 1)], dateViews[1...]) {
            filterDatesContainer.addSubview(view)
            view.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.leading.equalTo(prev.snp.trailing)
                make.width.equalTo(dateViews[0])
            }
        }
        dateViews.last?.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
        }

        let dateAndMealSeparator = UIView()
        dateAndMealSeparator.backgroundColor = .wash
        addSubview(dateAndMealSeparator)
        dateAndMealSeparator.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }

        let filterMealsContainer = UIView()
        addSubview(filterMealsContainer)
        filterMealsContainer.snp.makeConstraints { make in
            make.top.equalTo(dateAndMealSeparator.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }

        filterBreakfastButton.tag = 0
        filterBreakfastButton.setTitle("Breakfast", for: .normal)
        filterBreakfastButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        filterBreakfastButton.setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
        filterBreakfastButton.setTitleColor(UIColor.eateryBlue, for: .selected)
        filterBreakfastButton.addTarget(self, action: #selector(didFilterMeal(_:)), for: .touchUpInside)
        filterMealsContainer.addSubview(filterBreakfastButton)
        filterBreakfastButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }

        let leftSeparator = UIView()
        leftSeparator.backgroundColor = .wash
        filterMealsContainer.addSubview(leftSeparator)
        leftSeparator.snp.makeConstraints { make in
            make.leading.equalTo(filterBreakfastButton.snp.trailing).inset(8)
            make.width.equalTo(1)
        }

        filterLunchButton.tag = 1
        filterLunchButton.setTitle("Lunch", for: .normal)
        filterLunchButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        filterLunchButton.setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
        filterLunchButton.setTitleColor(UIColor.eateryBlue, for: .selected)
        filterLunchButton.addTarget(self, action: #selector(didFilterMeal(_:)), for: .touchUpInside)
        filterMealsContainer.addSubview(filterLunchButton)
        filterLunchButton.snp.makeConstraints { make in
            make.leading.equalTo(filterBreakfastButton.snp.trailing).inset(8)
            make.centerY.equalToSuperview()
            make.width.equalTo(filterBreakfastButton.snp.width)
        }

        let rightSeparator = UIView()
        rightSeparator.backgroundColor = .wash
        filterMealsContainer.addSubview(rightSeparator)
        rightSeparator.snp.makeConstraints { make in
            make.leading.equalTo(filterLunchButton.snp.trailing).inset(8)
            make.width.equalTo(1)
        }

        filterDinnerButton.tag = 2
        filterDinnerButton.setTitle("Dinner", for: .normal)
        filterDinnerButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        filterDinnerButton.setTitleColor(UIColor.black.withAlphaComponent(0.5), for: .normal)
        filterDinnerButton.setTitleColor(UIColor.eateryBlue, for: .selected)
        filterDinnerButton.addTarget(self, action: #selector(didFilterMeal(_:)), for: .touchUpInside)
        filterMealsContainer.addSubview(filterDinnerButton)
        filterDinnerButton.snp.makeConstraints { make in
            make.leading.equalTo(rightSeparator.snp.trailing).inset(8)
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
            make.width.equalTo(filterLunchButton.snp.width)
        }

        let bottomSeparator = UIView()
        bottomSeparator.backgroundColor = .wash
        addSubview(bottomSeparator)
        bottomSeparator.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.top.equalTo(filterMealsContainer.snp.bottom)
            make.height.equalTo(1)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

    @objc private func didFilterMeal(_ sender: UIButton) {
        delegate?.filterEateriesView(self, didFilterMeal: sender)
    }

}

extension FilterEateriesView: FilterDateViewDelegate {

    func filterDateViewWasSelected(_ filterDateView: FilterDateView, sender button: UIButton) {
        delegate?.filterEateriesView(self, didFilterDate: button)
    }

}
