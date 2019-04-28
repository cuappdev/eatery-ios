//
//  HistogramTestViewController.swift
//  Eatery
//
//  Created by Ethan Fine on 4/26/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class HistogramTestViewController: UIViewController {
    
    var histogram: WaitTimeHistogram!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .lightGray
        
        let frame = CGRect(x: 30, y: 30, width: 100, height: 100)
        let waitTimeHistogram = HistogramViewController(frame: frame, data: [(2, 4), (4, 6), (3, 7), (5, 7), (1, 3), (7, 9)])
        addChildViewController(waitTimeHistogram)
        view.addSubview(waitTimeHistogram.view)
        waitTimeHistogram.didMove(toParentViewController: self)
        //histogram = WaitTimeHistogram(frame: frame, data: [4, 5, 7, 8, 9, 10])
        
        waitTimeHistogram.view.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.top.leading.equalTo(view).offset(30)
        }
    }
    
}
