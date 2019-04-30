//
//  HistogramTestViewController.swift
//  Eatery
//
//  Created by Ethan Fine on 4/26/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

class HistogramTestViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        
        let frame = CGRect(x: 10, y: 30, width: 350, height: 150)
        let waitTimeHistogram = HistogramViewController(frame: frame, data: [(2, 4), (4, 6), (3, 7), (5, 7), (1, 3), (7, 9), (2, 4), (4, 6), (3, 7), (5, 7), (1, 3), (7, 9), (2, 4), (4, 6), (3, 7), (5, 7), (1, 3), (7, 9), (2, 4), (4, 6), (3, 7)])
        addChildViewController(waitTimeHistogram)
        view.addSubview(waitTimeHistogram.view)
        waitTimeHistogram.didMove(toParentViewController: self)
        
        waitTimeHistogram.view.snp.makeConstraints { make in
            make.width.equalTo(350)
            make.height.equalTo(150)
            make.top.equalTo(view).offset(100)
            make.leading.equalTo(view).offset(10)
        }
    }
    
}
