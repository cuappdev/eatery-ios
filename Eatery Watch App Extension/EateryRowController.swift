import WatchKit
import DiningStack

class EateryRowController: NSObject {
    @IBOutlet var statusSeparator: WKInterfaceSeparator!
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var timeLabel: WKInterfaceLabel!
    
    func setEatery(eatery: Eatery) {
        titleLabel.setText(eatery.nickname)
        
        let eateryStatus = eatery.generateDescriptionOfCurrentState()
        switch eateryStatus {
        case let .open(status, message):
            statusSeparator.setColor(UIColor.eateryGreen)
            timeLabel.setText(status + " " + message)
        case let .closed(status, message):
            statusSeparator.setColor(UIColor.primary)
            timeLabel.setText(status + " " + message)
        }
    }
}
