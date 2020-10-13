import Foundation

struct TimeFactory {

    static func interval(hours: Double, minutes: Double) -> TimeInterval {
        60 * minutes + 60 * 60 * hours
    }

    static func displayTextForEvent(_ event: Event) -> String {
        dateConverter(date1: event.start, date2: event.end)
    }

    static func dateConverter(date1: Date, date2: Date) -> String {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "America/New_York")!

        let hour1 = calendar.component(.hour, from: date1)
        let minute1 = calendar.component(.minute, from: date1)

        var first = "\(TimeFactory.hourConverter(hour1))"
            + "\(TimeFactory.minConverter(minute1))"
            + "\(TimeFactory.amOrPm(hour1))"
        first = shorthand(of: first) ?? first

        let hour2 = calendar.component(.hour, from: date2)
        let minute2 = calendar.component(.minute, from: date2)

        var second = "\(TimeFactory.hourConverter(hour2))"
            + "\(TimeFactory.minConverter(minute2))"
            + "\(TimeFactory.amOrPm(hour2))"
        second = shorthand(of: second) ?? second

        return "\(first) to \(second)"
    }

    private static func hourConverter(_ hour: Int) -> String {
        let moddedHour = hour % 12
        if moddedHour == 0 {
            return "12"
        }
        return "\(moddedHour)"
    }

    private static func minConverter(_ min: Int) -> String {
        if min != 0 {
            if min > 9 {
                return ":\(min)"
            } else {
                return ":0\(min)"
            }
        } else {
            return ""
        }
    }

    private static func amOrPm(_ hour: Int) -> String {
        if hour >= 12 {
            return "pm"
        } else {
            return "am"
        }
    }

    private static func shorthand(of timeString: String) -> String? {
        switch timeString {
        case "12am": return "midnight"
        case "12pm": return "noon"
        default: return nil
        }
    }

    /// Compute the time representation of given date measured in seconds.
    /// This function answers the question: how long has it been since the start
    /// of the day?
    static func time(of date: Date) -> TimeInterval {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        return TimeInterval(hour * 3600 + minute * 60 + second)
    }

}
