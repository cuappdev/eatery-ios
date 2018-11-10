import WatchKit
import Foundation
import DiningStack

enum SortingOption {
    case OpenAndAlphabetical
    case Alphabetical
}

let DATA = DataManager.sharedInstance

class EateriesInterfaceController: WKInterfaceController {

    @IBOutlet var table: WKInterfaceTable!
    
    var eateries = [Eatery]()
    var dateLastFetched = Date()
    var curSortingOption = SortingOption.OpenAndAlphabetical
    
    @IBAction func refreshMenuItem() {
        configureTable()
    }
    
    @IBAction func sortMenuItem() {
        curSortingOption = curSortingOption == .Alphabetical ? .OpenAndAlphabetical : .Alphabetical
        self.sortEateries()
        self.configureTable()
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        getEateries()
    }
    
    /** Fetch list of Eateries from DataManager */
    func getEateries() {
        DATA.fetchEateries(false) { _ in
            DispatchQueue.main.async {
                self.dateLastFetched = Date()
                self.eateries = DATA.eateries
                self.sortEateries()
                self.configureTable()
            }
        }
    }
    
    // Sort Eateries Function
    func sortEateries() {
        
        // Sort eateris by open/close, then alphabetically
        let sortAlphabeticallyAndByOpenClosure = { (a: Eatery, b: Eatery) -> Bool in
    
            if a.isOpenToday() && !b.isOpenToday() {
                return true
            }
            if !a.isOpenToday() && b.isOpenToday() {
                return false
            }
            
            let aState = a.generateDescriptionOfCurrentState()
            let bState = b.generateDescriptionOfCurrentState()
            
            switch aState {
            case .open:
                switch bState {
                case .open:
                    return a.nickname < b.nickname

                default:
                    return true
                }

            case .closing:
                switch bState {
                case .open:
                    return false
                case .closing:
                    return a.nickname < b.nickname
                case .closed:
                    return true
                }
                
            case .closed:
                switch bState {
                case .closed:
                    return a.nickname < b.nickname
                default:
                    return false
                }
            }
        }
        
        // Sort eateries just alphabetically
        let sortAlphabeticallyClosure = { (a: Eatery, b: Eatery) -> Bool in
            return a.nickname < b.nickname
        }
        
        curSortingOption == .Alphabetical ? eateries.sort(by: sortAlphabeticallyClosure) : eateries.sort(by: sortAlphabeticallyAndByOpenClosure)
    }

    /** Updates table and stores eateries. Use this to update Eatery times in table. */
    func configureTable() {
        table.setNumberOfRows(eateries.count, withRowType: "EateryRow")
        for index in eateries.indices {
            if let controller = table.rowController(at: index) as? EateryRowController {
                controller.setEatery(eatery: eateries[index])
            }
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        presentController(withName: "Menu", context: eateries[rowIndex])
    }

    override func willActivate() {
        super.willActivate()
        // If it is past midnight of the following day of last fetch, fetch.
        let startOfNextDay = Calendar.current.startOfDay(for: dateLastFetched.addingTimeInterval(86400))
        if Date().timeIntervalSince(startOfNextDay) > 0 {
            getEateries()
        } else {
            configureTable()
        }
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    
}
