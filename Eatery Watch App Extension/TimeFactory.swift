import Foundation
import DiningStack

extension TimeInterval {
    static func intervalWithHoursAndMinutesFromNow(hours: Double, minutes: Double) -> TimeInterval {
        return 60 * minutes + 60 * 60 * hours
    }
}

func displayTextForEvent(_ event: Event) -> String {
    return dateConverter(date1: event.startDate, date2: event.endDate)
}

/// Returns: Time representation of given date measured in seconds.
func timeOfDate(_ date: Date) -> Int {
    // TODO: Specify timezone?
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: date)
    let minute = calendar.component(.minute, from: date)
    let second = calendar.component(.second, from: date)
    return hour * 3600 + minute * 60 + second
}

// TODO: make this an extension on MXLCalendarEvent
func dateConverter(date1: Date, date2: Date) -> String {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "America/New_York")!

    let hour1 = calendar.component(.hour, from: date1)
    let minute1 = calendar.component(.minute, from: date1)

    let hour2 = calendar.component(.hour, from: date2)
    let minute2 = calendar.component(.minute, from: date2)

    var first = ""
    var second = ""

    first = "\(hourConverter(hour1))\(minConverter(minute1))\(amOrPm(hour1))"
    first.convertTimeIfNeeded()

    second = "\(hourConverter(hour2))\(minConverter(minute2))\(amOrPm(hour2))"
    second.convertTimeIfNeeded()

    // TODO: incorporate eventSummary if applicable

    return "\(first) to \(second)"
}

private func hourConverter(_ hour: Int) -> String {
    let moddedHour = hour % 12
    if moddedHour == 0 {
        return "12"
    }
    return "\(moddedHour)"
}

private func minConverter(_ min: Int) -> String {
    if (min != 0) {
        if (min > 9) {
            return ":\(min)"
        } else {
            return ":0\(min)"
        }
    } else {
        return ""
    }
}

private func amOrPm(_ hour: Int) -> String {
    if hour >= 12 {
        return "pm"
    } else {
        return "am"
    }
}

extension String {
    mutating func convertTimeIfNeeded() {
        if self == "12am" {
            self = "midnight"
        } else if self == "12pm" {
            self = "noon"
        }
    }
}
