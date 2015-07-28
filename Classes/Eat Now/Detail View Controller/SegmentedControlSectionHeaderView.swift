//
//  SegmentedControlSectionHeaderView.swift
//  
//
//  Created by Eric Appel on 7/20/15.
//
//

import UIKit

protocol SegmentChangedDelegate {
    func valueChangedForSegmentedControl(sender: UISegmentedControl)
}

class SegmentedControlSectionHeaderView: UIView {

    var delegate: SegmentChangedDelegate!

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
        delegate.valueChangedForSegmentedControl(sender)
    }

}
