//
//  LookAheadViewController.swift
//  Eatery
//
//  Created by William Ma on 2/11/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import Crashlytics
import UIKit
import SwiftyJSON
import NVActivityIndicatorView

class LookAheadViewController: UIViewController {

    typealias EateryArea = (area: Area, eateries: [Eatery])

    private enum CellIdentifier: String {

        case eatery

    }

    private enum HeaderIdentifier: String {

        case header

    }

    private enum MealChoice: Int, CustomStringConvertible {

        case breakfast
        case lunch
        case dinner

        var description: String {
            switch self {
            case .breakfast: return "Breakfast"
            case .lunch: return "Lunch"
            case .dinner: return "Dinner"
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
                    dateView.textColor = .black
                } else {
                    dateView.textColor = UIColor.black.withAlphaComponent(0.3)
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

    /// Try and find the event that most closely matches the specified meal
    private func findEvent(from events: [Eatery.EventName: Event], matching meal: MealChoice) -> Event? {
        switch meal {
        case .breakfast: return events["Breakfast"] ?? events["Brunch"]
        case .lunch: return events["Lunch"] ?? events["Brunch"] ?? events["Lite Lunch"]
        case .dinner: return events["Dinner"]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        navigationItem.title = "Upcoming Menus"
        view.backgroundColor = .wash

        setUpTableView()

        setUpFilterView()

        tableView.contentInset.top = filterView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        computeFilterViewPosition()



        Answers.logWeeklyMenuOpened()

        computeCurrentSelectedMeal()
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
        NetworkManager.shared.getEateries { (eateries, error) in
            DispatchQueue.main.async(execute: { [weak self] in
                guard let `self` = self else { return }

                guard let eateries = eateries else { return }
                var eateriesByArea: [Area: [Eatery]] = [:]
                let displayedAreas: [Area] = [.West, .North, .Central]

                for eatery in eateries where eatery.eateryType == .Dining && displayedAreas.contains(eatery.area) {
                    eateriesByArea[eatery.area, default: []].append(eatery)
                }

                self.eateriesByArea = [
                    (area: .West, eateries: eateriesByArea[.West] ?? []),
                    (area: .North, eateries: eateriesByArea[.North] ?? []),
                    (area: .Central, eateries: eateriesByArea[.Central] ?? [])
                ]

                self.tableView.reloadData()

                UIView.animate(withDuration: 0.3, animations: {
                    self.activityIndicator?.alpha = 0.0
                })
            })
        }
    }

    func scrollToTop() {
        if tableView.contentOffset.y > 0 {
            let contentOffset = -(filterBarHeight + (navigationController?.navigationBar.frame.height ?? 0))
            tableView.setContentOffset(CGPoint(x: 0, y: contentOffset), animated: true)
        }
    }

    private func computeFilterViewPosition() {
        filterView.frame.origin.y = max(0, -(tableView.contentOffset.y + filterView.frame.height))
    }

    /// Compute the selectedMeal based on the current hour
    private func computeCurrentSelectedMeal() {
        let currentHour = Calendar.current.component(.hour, from: Date())
        switch currentHour {
        case 0...9: selectedMeal = .breakfast
        case 10...15: selectedMeal = .lunch
        case 15...23: selectedMeal = .dinner
        default: selectedMeal = .breakfast
        }
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
        cell.eateryName = eatery.nameShort

        let events = eatery.eventsOnDate(selectedDate)
        if let event = findEvent(from: events, matching: selectedMeal) {
            cell.eateryStatus = "Open"
            cell.eateryStatusColor = .eateryGreen
            cell.eateryHours = TimeFactory.displayTextForEvent(event)
            cell.eateryHoursColor = .secondary
            cell.moreInfoIndicatorIsHidden = false

            cell.menu = event.getMenuIterable()
            cell.isExpanded = expandedCellPaths.contains(indexPath)
        } else {
            cell.eateryStatus = "Closed"
            cell.eateryStatusColor = .secondary
            cell.eateryHours = nil
            cell.moreInfoIndicatorIsHidden = true

            cell.isExpanded = false
        }

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderIdentifier.header.rawValue) as! LookAheadHeaderView
        header.title = eateriesByArea[section].area.rawValue
        return header
    }

}

extension LookAheadViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let cell = tableView.cellForRow(at: indexPath) as? LookAheadTableViewCell else {
            return
        }

        let eatery = eateriesByArea[indexPath.section].eateries[indexPath.row]
        guard let _ = findEvent(from: eatery.eventsOnDate(selectedDate), matching: selectedMeal) else {
            return
        }

        if expandedCellPaths.contains(indexPath) {
            expandedCellPaths.remove(indexPath)
            cell.isExpanded = false
        } else {
            expandedCellPaths.insert(indexPath)
            cell.isExpanded = true
        }

        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
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
