import Foundation
import SwiftyJSON
import UIKit

extension CampusEatery {

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

}

extension Eatery {

    //!TODO: Maybe cache this value? I don't think this is too expensive
    var isFavorite: Bool {
        get {
            let ar = UserDefaults.standard.stringArray(forKey: "favorites") ?? []
            return ar.contains {
                $0 == name
            }
        }

        set {
            var ar = UserDefaults.standard.stringArray(forKey: "favorites") ?? []
            if newValue && !isFavorite {
                ar.append(name)
            } else if (!newValue && isFavorite) {
                let idx = ar.index {
                    $0 == name
                }

                if let idx = idx {
                    ar.remove(at: idx)
                }
            }

            UserDefaults.standard.set(ar, forKey: "favorites")
        }
    }

}
