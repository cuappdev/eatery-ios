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

    static func logMenuOpenedFromHome(eateryId: String) {
        Answers.logCustomEvent(withName: "Menu Opened from Home", customAttributes: ["eateryId": eateryId])
    }
    
    static func logMenuOpenedFromSearch(eateryId: String) {
        Answers.logCustomEvent(withName: "Menu Opened from Search", customAttributes: ["eateryId": eateryId])
    }
    
    static func logMenuOpenedFromWeeklyMenus(eateryId: String) {
        Answers.logCustomEvent(withName: "Menu Opened from Weekly Menus", customAttributes: ["eateryId": eateryId])
    }

    static func logDirectionsAsked(eateryId: String) {
        Answers.logCustomEvent(withName: "Directions Asked", customAttributes: ["eateryId": eateryId])
    }

    static func logMapOpened() {
        Answers.logCustomEvent(withName: "Map Opened", customAttributes: nil)
    }

    static func logMapAnnotationOpened(eateryId: String) {
        Answers.logCustomEvent(withName: "Map Annotation Opened", customAttributes: ["eateryId": eateryId])
    }
    
    static func logMapSeguedToEateryMenu(eateryId: String) {
        Answers.logCustomEvent(withName: "Map Segued to Eatery Menu", customAttributes: ["eateryId": eateryId])
    }
    
    static func logWeeklyMenuOpened() {
        Answers.logCustomEvent(withName: "Weekly Menu Opened", customAttributes: nil)
    }
    
    static func logBRBLoginOpened() {
        Answers.logCustomEvent(withName: "BRB Login Opened", customAttributes: nil)
    }
    
    static func logEateryFavorited(eateryId: String) {
        Answers.logCustomEvent(withName: "Eatery Favorited", customAttributes: ["eateryId": eateryId])
    }
    
    static func logEateryUnfavorited(eateryId: String) {
        Answers.logCustomEvent(withName: "Eatery Unfavorited", customAttributes: ["eateryId": eateryId])
    }
    
    static func logEateryFilterApplied(filterType: String) {
        Answers.logCustomEvent(withName: "Eatery Filter Applied", customAttributes: ["filterType": filterType])
    }
    
    static func logLookedAheadForMeal() {
        Answers.logCustomEvent(withName: "Looked Ahead for Meal", customAttributes: nil)
    }
    
    static func logLookedAheadDate() {
        Answers.logCustomEvent(withName: "Looked Ahead Date", customAttributes: nil)
    }

    static func login(succeeded: Bool, timeLapsed: TimeInterval) {
        Answers.logLogin(withMethod: nil, success: succeeded as NSNumber, customAttributes: ["timeLapsed": timeLapsed])
    }

    static func logAROpen() {
        Answers.logCustomEvent(withName: "Augmented Reality Opened", customAttributes: nil)
    }
    
}
