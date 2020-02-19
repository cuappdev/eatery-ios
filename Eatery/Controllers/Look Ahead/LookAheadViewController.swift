//
//  LookAheadViewController.swift
//  Eatery
//
//  Created by William Ma on 2/11/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView

class LookAheadViewController: UIViewController {

    typealias EateryArea = (area: Area, eateries: [CampusEatery])

    private enum CellIdentifier: String {

        case eatery

    }

    private enum HeaderIdentifier: String {

        case header

    }

    private enum MealChoice: Int, CaseIterable, CustomStringConvertible, Comparable {

        case breakfast
        case lunch
        case dinner

        static func <(lhs: MealChoice, rhs: MealChoice) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }

        init?(hour: Int) {
            for choice in MealChoice.allCases {
                if choice.hours.contains(hour) {
                    self = choice
                    return
                }
            }

            return nil
        }

        init(from date: Date) {
            var calendar = Calendar.current
            calendar.timeZone = TimeZone(identifier: "America/New_York")!

            let hour = calendar.component(.hour, from: date)
            self = MealChoice(hour: hour) ?? .breakfast
        }

        var description: String {
            switch self {
            case .breakfast: return "Breakfast"
            case .lunch: return "Lunch"
            case .dinner: return "Dinner"
            }
        }

        var hours: CountableClosedRange<Int> {
            switch self {
            case .breakfast: return 0...9
            case .lunch: return 10...15
            case .dinner: return 15...23
            }
        }

    }

    private enum DayChoice: Int, CaseIterable {

        case today
        case dayOne
        case dayTwo
        case dayThree
        case dayFour
        case dayFive
        case daySix

    }

    // views

    private var activityIndicator: NVActivityIndicatorView?

    private let filterView = FilterEateriesView(frame: .zero)
    private let tableView = UITableView(frame: .zero, style: .grouped)

    // data

    private var eateriesByArea = [EateryArea]()

    // state

    private var expandedCellPaths: Set<IndexPath> = []

    private var selectedMeal: MealChoice = .breakfast {
        didSet {
            for (index, button) in filterView.mealButtons.enumerated() {
                button.isSelected = index == selectedMeal.rawValue
            }

            expandedCellPaths.removeAll()
            tableView.reloadData()
        }
    }

    private var selectedDay: DayChoice = .today {
        didSet {
            for (index, dateView) in filterView.dateViews.enumerated() {
                if index == selectedDay.rawValue {
                    let color = UIColor.black
                    dateView.dayLabel.textColor = color
                    dateView.dateLabel.textColor = color
                } else {
                    let color = UIColor.black.withAlphaComponent(0.3)
                    dateView.dayLabel.textColor = color
                    dateView.dateLabel.textColor = color
                }
            }

            expandedCellPaths.removeAll()
            tableView.reloadData()
        }
    }
    private let dates: [Date] = DayChoice.allCases.map {
        Calendar.current.date(byAdding: .day, value: $0.rawValue, to: Date()) ?? Date()
    }
    private var selectedDate: Date {
        return dates[selectedDay.rawValue]
    }

    // used to prevent table view jitter when recomputing layout
    private var cellHeights: [IndexPath: CGFloat] = [:]

    /// Try and find the event that most closely matches the specified meal
    private func findEvent(from events: [CampusEatery.EventName: Event], matching meal: MealChoice) -> Event? {
        switch meal {
        case .breakfast: return events["Breakfast"] ?? events["Brunch"]
        case .lunch: return events["Lunch"] ?? events["Brunch"] ?? events["Lite Lunch"]
        case .dinner: return events["Dinner"]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Upcoming Menus"
        view.backgroundColor = .wash

        setUpTableView()

        setUpFilterView()

        tableView.contentInset.top = filterView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        computeFilterViewPosition()

        selectedMeal = MealChoice(from: Date())
        selectedDay = .today

        queryEateries()
        startLoadingView()
    }

    private func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = .separator
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .wash

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.register(LookAheadTableViewCell.self, forCellReuseIdentifier: CellIdentifier.eatery.rawValue)
        tableView.register(LookAheadHeaderView.self, forHeaderFooterViewReuseIdentifier: HeaderIdentifier.header.rawValue)
    }

    private func setUpFilterView() {
        filterView.delegate = self

        view.addSubview(filterView)
        filterView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view)
        }
    }

    private func startLoadingView() {
        let indicator = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin, color: .transparentEateryBlue)
        view.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(44)
        }

        indicator.startAnimating()
        activityIndicator = indicator
    }

    private func queryEateries() {
        NetworkManager.shared.getCampusEateries(useCachedData: true) { (eateries, error) in
            DispatchQueue.main.async(execute: { [weak self] in
                guard let `self` = self else { return }

                guard let eateries = eateries else { return }
                var eateriesByArea: [Area: [CampusEatery]] = [:]
                let displayedAreas: [Area] = [.west, .north, .central]

                for eatery in eateries {
                    if let area = eatery.area,
                        eatery.eateryType == .dining,
                        displayedAreas.contains(area) {
                        eateriesByArea[area, default: []].append(eatery)
                    }
                }

                self.eateriesByArea = [
                    (area: .west, eateries: eateriesByArea[.west] ?? []),
                    (area: .north, eateries: eateriesByArea[.north] ?? []),
                    (area: .central, eateries: eateriesByArea[.central] ?? [])
                ]

                self.tableView.reloadData()

                UIView.animate(withDuration: 0.3, animations: {
                    self.activityIndicator?.alpha = 0.0
                })
            })
        }
    }

    private func computeFilterViewPosition() {
        filterView.frame.origin.y = max(
            view.layoutMargins.top - filterView.separatorY,
            -(tableView.contentOffset.y + filterView.frame.height))
    }

}

extension LookAheadViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return eateriesByArea.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eateriesByArea[section].eateries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.eatery.rawValue) as! LookAheadTableViewCell

        let eatery = eateriesByArea[indexPath.section].eateries[indexPath.row]
        cell.eateryNameLabel.text = eatery.displayName

        let events = eatery.eventsByName(onDayOf: selectedDate)
        if let event = findEvent(from: events, matching: selectedMeal) {
            if selectedDay == .today {
                // There is an event, and it's today

                switch event.currentStatus() {
                case .notStarted:
                    cell.eateryStatusLabel.text = "Will Open"
                    cell.eateryStatusLabel.textColor = .secondary
                    cell.eateryHoursLabel.text = TimeFactory.displayTextForEvent(event)
                    cell.eateryHoursLabel.textColor = .secondary

                case .startingSoon:
                    cell.eateryStatusLabel.text = "Opening"
                    cell.eateryStatusLabel.textColor = .eateryOrange
                    cell.eateryHoursLabel.text = "in \(Int(event.start.timeIntervalSinceNow / 60) + 1)m"
                    cell.eateryHoursLabel.textColor = .secondary

                case .started:
                    cell.eateryStatusLabel.text = "Open"
                    cell.eateryStatusLabel.textColor = .eateryGreen
                    cell.eateryHoursLabel.text = TimeFactory.displayTextForEvent(event)
                    cell.eateryHoursLabel.textColor = .secondary

                case .endingSoon:
                    cell.eateryStatusLabel.text = "Closing"
                    cell.eateryStatusLabel.textColor = .eateryOrange
                    cell.eateryHoursLabel.text = "in \(Int(event.end.timeIntervalSinceNow / 60) + 1)m"
                    cell.eateryHoursLabel.textColor = .secondary

                case .ended:
                    cell.eateryStatusLabel.text = "Was Open"
                    cell.eateryStatusLabel.textColor = .secondary
                    cell.eateryHoursLabel.text = TimeFactory.displayTextForEvent(event)
                    cell.eateryHoursLabel.textColor = .secondary
                }
            } else {
                // There is an event, and it's in the future

                cell.eateryStatusLabel.text = "Open"
                cell.eateryStatusLabel.textColor = .eateryGreen
                cell.eateryHoursLabel.text = TimeFactory.displayTextForEvent(event)
                cell.eateryHoursLabel.textColor = .secondary
            }

            cell.moreInfoIndicatorImageView.isHidden = false
            cell.menuView.menu = event.menu
            cell.isExpanded = expandedCellPaths.contains(indexPath)
        } else {
            // There's no event

            cell.eateryStatusLabel.text = "Closed"
            cell.eateryStatusLabel.textColor = .secondary
            cell.eateryHoursLabel.text = nil
            cell.moreInfoIndicatorImageView.isHidden = true

            cell.isExpanded = false
        }

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderIdentifier.header.rawValue) as! LookAheadHeaderView
        header.titleLabel.text = eateriesByArea[section].area.rawValue
        return header
    }

}

extension LookAheadViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let eatery = eateriesByArea[indexPath.section].eateries[indexPath.row]
        guard let _ = findEvent(from: eatery.eventsByName(onDayOf: selectedDate), matching: selectedMeal) else {
            return
        }

        let cell = tableView.cellForRow(at: indexPath) as? LookAheadTableViewCell

        if expandedCellPaths.contains(indexPath) {
            expandedCellPaths.remove(indexPath)
            cell?.isExpanded = false

            // beginUpdates followed by endUpdates forces the tableView to recompute
            // cell geometry without needing to reload the cell
            tableView.beginUpdates()
            tableView.endUpdates()
        } else {
            expandedCellPaths.insert(indexPath)
            cell?.isExpanded = true

            tableView.beginUpdates()
            tableView.endUpdates()

            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath] ?? UITableViewAutomaticDimension
    }

}

extension LookAheadViewController: FilterEateriesViewDelegate {

    func filterEateriesView(_ filterEateriesView: FilterEateriesView, didFilterDate sender: FilterDateView) {
        guard let index = filterEateriesView.dateViews.firstIndex(of: sender), let day = DayChoice(rawValue: index) else {
            return
        }

        selectedDay = day
    }

    func filterEateriesView(_ filterEateriesView: FilterEateriesView, didFilterMeal sender: UIButton) {
        guard let index = filterEateriesView.mealButtons.firstIndex(of: sender), let meal = MealChoice(rawValue: index) else {
            return
        }

        selectedMeal = meal
    }

}

extension LookAheadViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        computeFilterViewPosition()
    }

}
