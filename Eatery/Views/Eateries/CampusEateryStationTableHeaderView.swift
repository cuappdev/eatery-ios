//
//  CampusEateryStationTableHeaderView.swift
//  Eatery
//
//  Created by Ethan Fine on 2/27/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import UIKit

class CampusEateryStationTableHeaderView: UITableViewHeaderFooterView {
    
    private let headerView = UIView()
    private let sectionLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        headerView.backgroundColor = .white
        sectionLabel.font = .systemFont(ofSize: 18, weight: .medium)
        addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        headerView.addSubview(sectionLabel)
        sectionLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(stationTitle: String) {
        sectionLabel.text = stationTitle
    }
    
}
