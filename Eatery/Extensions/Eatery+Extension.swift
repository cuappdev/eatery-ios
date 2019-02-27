import Foundation
import SwiftyJSON
import UIKit

enum EateryStatus {

    case open(String)
    case opening(String)
    case closing(String)
    case closed(String)
    
    var statusColor: UIColor {
        switch self {
        case .open:
            return .eateryGreen
        case .opening, .closing:
            return .orange
        case .closed:
            return .eateryRed
        }
    }
    
    var statusText: String {
        switch self {
        case .open:
            return "Open"
        case .opening:
            return "Opening"
        case .closing:
            return "Closing"
        case .closed:
            return "Closed"
        }
    }
    
    var message: String {
        switch self {
        case .open(let message), .opening(let message), .closing(let message), .closed(let message):
            return message
        }
    }

}

private let ShortDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mma"
    return formatter
}()

private let kEateryAppendix = JSON(try! Data(contentsOf: Bundle.main.url(forResource: "appendix", withExtension: "json")!)).dictionaryValue

let eateryImagesBaseURL = "https://raw.githubusercontent.com/cuappdev/assets/master/eatery/eatery-images/"

extension Eatery {

    /// Option to sort by campus or by open time
    enum Sorting: String {
        case alphabetically = "Alphabetically"
        case campus = "Campus"
        case location = "Location"
        case open = "Open & Closed"
        case paymentType = "Payment Type"

        static let values = [alphabetically, campus, location, open, paymentType]

        var names: [String] {
            switch self {
            case .alphabetically: return ["All Eateries"]
            case .campus: return ["Central", "West", "North"]
            case .location: return ["Nearest and Open", "Nearest and Closed"]
            case .open: return ["Open", "Closed"]
            case .paymentType: return ["Swipes", "BRB", "Cash"]
            }
        }

        var sectionCount: Int {
            return self.names.count
        }
    }

    //!TODO: Maybe cache this value? I don't think this is too expensive
    var favorite: Bool {
        get {
            let ar = UserDefaults.standard.stringArray(forKey: "favorites") ?? []
            return ar.contains {
                $0 == slug
            }
        }

        set {
            var ar = UserDefaults.standard.stringArray(forKey: "favorites") ?? []
            let contains = self.favorite
            if (newValue && !contains) {
                ar.append(self.slug)
            } else if (!newValue && contains) {
                let idx = ar.index {
                    $0 == slug
                }

                if let idx = idx {
                    ar.remove(at: idx)
                }
            }

            UserDefaults.standard.set(ar, forKey: "favorites");
        }
    }

    // ** COPY OF IMPLEMENTATION IN LiteEatery.swift
    // TODO: refactor to avoid repeated code
    //
    // Generates description of eatery for its current state
    // returns "Opening in x min)" if x <= 60 and is closed"
    // "Closing in x min) if x <= 60 and is open,
    // "Closed" if closed and not opening soon,
    // "Open now" if open and not closing soon
    // Bool value is either stable or about to change
    @available(*, deprecated, renamed: "currentStatus()")
    func generateDescriptionOfCurrentState() -> EateryStatus {
        return currentStatus()
    }

    func currentStatus() -> EateryStatus {
        return status(at: Date())
    }

    func status(at date: Date) -> EateryStatus {
        if isOpenToday() {
            guard let event = activeEventForDate(date) else {
                return .closed("")
            }

            switch event.status(at: date) {
            case .notStarted:
                return .closed("")

            case let .startingSoon(intervalUntilOpen):
                let minutesTillOpen = Int(intervalUntilOpen / 60)
                return .opening("in \(minutesTillOpen + 1)m")

            case .started:
                let timeString = ShortDateFormatter.string(from: event.end)
                return .open("until \(timeString)")

            case let .endingSoon(intervalUntilClose):
                let minutesTillClose = Int(intervalUntilClose / 60)
                return .closing("in \(minutesTillClose + 1)m")

            case .ended:
                let timeString = ShortDateFormatter.string(from: event.start)
                return .closed("until \(timeString)")
            }
        } else {
            return .closed("today")
        }
    }

    // Retrieves a string list of the hours of operation for a day/time
    func activeEventsForDate(date: Date) -> String {
        var resultString = "Closed"

        let events = eventsOnDate(date)
        if events.count > 0 {
            let eventsArray = events.map { $0.1 }
            let sortedEventsArray = eventsArray.sorted {
                $0.startDate.compare($1.startDate) == .orderedAscending
            }

            var mergedTimes = [(Date, Date)]()
            var currentTime: (Date, Date)?
            for time in sortedEventsArray {
                if currentTime == nil {
                    currentTime = (time.startDate, time.endDate)
                    continue
                }
                if currentTime!.1.compare(time.startDate) == .orderedSame {
                    currentTime = (currentTime!.0, time.endDate)
                } else {
                    mergedTimes.append(currentTime!)
                    currentTime = (time.startDate, time.endDate)
                }
            }

            if let time = currentTime {
                mergedTimes.append(time)
            }

            resultString = ""
            for (start, end) in mergedTimes {
                if resultString != "" { resultString += ", " }
                resultString += TimeFactory.dateConverter(date1: start, date2: end)
            }
        }

        return resultString
    }

    var nickname: String {
        guard let appendixJSON = kEateryAppendix[slug] else {
            return name
        }
        return appendixJSON["nickname"].arrayValue.first?.stringValue ?? ""
    }

    func allNicknames() -> [String] {
        guard let appendixJSON = kEateryAppendix[slug] else {
            return [name]
        }
        return appendixJSON["nickname"].arrayValue.map { $0.string! }
    }

    var altitude: Double {
        guard let appendixJSON = kEateryAppendix[slug],
            let altitude = appendixJSON["altitude"].double else {
                return 250.0
        }
        return altitude
    }

}
