//
//  CampusEateryStationTableHeaderView.swift
//  Eatery
//
//  Created by Ethan Fine on 2/27/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import UIKit

class CampusEateryStationTableHeaderView: UITableViewHeaderFooterView {
    
    private var headerView: UIView!
    private var sectionLabel: UILabel!
    
    override init(reuseIdentifier: String?) {
        headerView = UIView()
        headerView.backgroundColor = .white
        sectionLabel = UILabel()
        sectionLabel.font = .systemFont(ofSize: 18, weight: .medium)
        headerView.addSubview(sectionLabel)
        sectionLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().inset(10)
        }
        
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(stationTitle: String) {
        addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        sectionLabel.text = stationTitle
    }
    
}
