import Crashlytics

extension Answers {
    static func eateriesOpened() {
        Answers.logCustomEvent(withName: "Eateries Opened", customAttributes: nil)
    }

    static func logGuideOpened() {
        Answers.logCustomEvent(withName: "Guide Opened", customAttributes: nil)
    }

    static func logSearchResultSelected(for query: String) {
        Answers.logCustomEvent(withName: "Search Result Selected", customAttributes: ["query": query])
    }

    static func logMenuShared(eateryId: String, meal: String) {
        Answers.logCustomEvent(withName: "Menu Shared", customAttributes: ["eateryId": eateryId, "meal": meal])
    }

    static func logMenuOpened(eateryId: String) {
        Answers.logCustomEvent(withName: "Menu Opened", customAttributes: ["eateryId": eateryId])
    }

    static func logDirectionsAsked(eateryId: String) {
        Answers.logCustomEvent(withName: "Directions Asked", customAttributes: ["eateryId": eateryId])
    }

    static func logMapOpened(eateryId: String) {
        Answers.logCustomEvent(withName: "Map Opened", customAttributes: ["eateryId": eateryId])
    }

    static func login(succeeded: Bool, timeLapsed: TimeInterval) {
        Answers.logLogin(withMethod: nil, success: succeeded as NSNumber, customAttributes: ["timeLapsed": timeLapsed])
    }
}
