//
//  FavoriteTableViewCell.swift
//  Eatery
//
//  Created by Noah Pikielny on 4/12/21.
//  Copyright © 2021 Cornell AppDev. All rights reserved.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {

    private var nameLabel: UILabel!
    private var servingLabel: UILabel!

    private var favoriteStatus: UIImageView!
    public var favorited = true {
        didSet {
            favoriteStatus.image = favorited ? .favoritedImage : .unfavoritedImage
            favoriteStatus.tintColor = favorited ? .favoriteYellow : .lightGray
        }
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        nameLabel = UILabel(frame: .zero)
        nameLabel.font = .preferredFont(forTextStyle: .headline)
        nameLabel.numberOfLines = 0
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(12)
        }

        servingLabel = UILabel(frame: .zero)
        servingLabel.font = .preferredFont(forTextStyle: .subheadline)
        servingLabel.textColor = .gray
        contentView.addSubview(servingLabel)
        servingLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.leading.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(12)
        }

        favoriteStatus = UIImageView()
        favoriteStatus.image = .favoritedImage
        favoriteStatus.contentMode = .scaleAspectFill
        contentView.addSubview(favoriteStatus)
        favoriteStatus.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview().inset(20)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(name: String, restaurants: String?, favorited: Bool = true) {
        nameLabel.text = name
        servingLabel.text = restaurants ?? "Not currently being served"
        self.favorited = favorited
    }

}
