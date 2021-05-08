//
//  FavoriteTableViewCell.swift
//  Eatery
//
//  Created by Noah Pikielny on 4/12/21.
//  Copyright © 2021 Cornell AppDev. All rights reserved.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {

    private let nameLabel = UILabel()
    private let servingLabel = UILabel()

    private var favoriteStatus = UIImageView(image: .favoritedImage)
    public var favorited = true {
        didSet {
            favoriteStatus.image = favorited ? .favoritedImage : .unfavoritedImage
            favoriteStatus.tintColor = favorited ? .favoriteYellow : .lightGray
        }
    }
    let padding: CGFloat = 20

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        nameLabel.font = .preferredFont(forTextStyle: .headline)
        nameLabel.numberOfLines = 0
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(padding)
            make.top.equalToSuperview().inset(12)
        }

        favoriteStatus.contentMode = .scaleAspectFill
        contentView.addSubview(favoriteStatus)
        favoriteStatus.snp.makeConstraints { make in
            make.height.width.equalTo(padding)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(padding)
        }

        servingLabel.font = .preferredFont(forTextStyle: .subheadline)
        servingLabel.textColor = .gray
        servingLabel.numberOfLines = 0
        contentView.addSubview(servingLabel)
        servingLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.leading.equalToSuperview().inset(padding)
            make.bottom.equalToSuperview().inset(12)
            make.trailing.lessThanOrEqualTo(favoriteStatus.snp.leading)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(name: String, locations: [String]?, favorited: Bool = true) {
        nameLabel.text = name
        if let locations = locations {
            servingLabel.text = locationString(locations: locations)
        } else {
            servingLabel.text = "Not being served today"
        }
        self.favorited = favorited
    }

    func locationString(locations: [String]) -> String {
        var servingEateries = locations.map({$0 + ", "})
        if servingEateries.count > 1 {
            let penultimateIndex = servingEateries.count - 1
            let penultimateString = servingEateries[penultimateIndex]
            servingEateries[penultimateIndex] = String(penultimateString.prefix(penultimateString.count - 2)) + " & "
        }
        var eateriesText = servingEateries.reduce("", +)
        eateriesText = String(eateriesText.prefix(max(eateriesText.count - 2, 0)))

        return eateriesText
    }
    
}
