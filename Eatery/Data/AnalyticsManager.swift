import Crashlytics

private let enableAnalytics = true

extension Answers {
    static func eateriesOpened() {
        if enableAnalytics {
            Answers.logCustomEvent(withName: "Eateries Opened", customAttributes: nil)
        }
    }

    static func logGuideOpened() {
        if enableAnalytics {
            Answers.logCustomEvent(withName: "Guide Opened", customAttributes: nil)
        }
    }

    static func logSearchResultSelected(for query: String) {
        if enableAnalytics {
            Answers.logCustomEvent(withName: "Search Result Selected", customAttributes: ["query": query])
        }
    }

    static func logMenuShared(eateryId: String, meal: String) {
        if enableAnalytics {
            Answers.logCustomEvent(withName: "Menu Shared", customAttributes: ["eateryId": eateryId, "meal": meal])
        }
    }

    static func logMenuOpened(eateryId: String) {
        if enableAnalytics {
            Answers.logCustomEvent(withName: "Menu Opened", customAttributes: ["eateryId": eateryId])
        }
    }

    static func logDirectionsAsked(eateryId: String) {
        if enableAnalytics {
            Answers.logCustomEvent(withName: "Directions Asked", customAttributes: ["eateryId": eateryId])
        }
    }

    static func logMapOpened(eateryId: String) {
        if enableAnalytics {
            Answers.logCustomEvent(withName: "Map Opened", customAttributes: ["eateryId": eateryId])
        }
    }

    static func login(succeeded: Bool, timeLapsed: TimeInterval) {
        if enableAnalytics {
            Answers.logLogin(withMethod: nil, success: succeeded as NSNumber, customAttributes: ["timeLapsed": timeLapsed])
        }
    }
}
