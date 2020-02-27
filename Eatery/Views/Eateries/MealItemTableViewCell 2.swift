//
//  MealItemTableViewCell.swift
//  Eatery
//
//  Created by Ethan Fine on 2/9/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import UIKit

class MealItemTableViewCell: UITableViewCell {

    private var favoriteButton: UIImageView?
    private(set) var menuItem: Menu.Item?
    private let nameLabel = UILabel()
    
    private var favoriteButtonAttributes: (imageName: String, tintColor: UIColor)? {
        guard let menuItem = menuItem else { return nil }
        return (menuItem.favorited) ? ("selected", UIColor.favoriteYellow) : ("unselected", UIColor.eateryBlue)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        nameLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.snp.makeConstraints { make in
            make.edges.equalTo(self).inset(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Configures the cell's nameLabel text to match the menu item text (adjusting for whether or not the item is healthy) and adds a favorite button to the cell corresponding to whether the user has favorited the menu item
    func configure(for menuItem: Menu.Item) {
        self.menuItem = menuItem
        
        let itemText = (menuItem.healthy) ? NSMutableAttributedString(string: "\(menuItem.name.trim()) ")
        .appendImage(UIImage(named: "appleIcon")!, yOffset: -1.5) : NSMutableAttributedString(string: menuItem.name)
        nameLabel.attributedText = itemText
        
        let starImageName = favoriteButtonAttributes!.imageName
        let starImage = UIImage(named: starImageName)?.withRenderingMode(.alwaysTemplate)
        favoriteButton = UIImageView(image: starImage)
        favoriteButton!.tintColor = favoriteButtonAttributes!.tintColor
        favoriteButton!.isUserInteractionEnabled = true
        let favoriteTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedFavorite))
        favoriteButton!.addGestureRecognizer(favoriteTapGestureRecognizer)
        addSubview(favoriteButton!)
        favoriteButton!.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton!.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().inset(4)
            make.trailing.equalToSuperview().inset(16)
            make.width.equalTo(favoriteButton!.snp_width)
        }
    }
    
    /// Sets label text but removes favoriting ability
    func setLabelText(_ text: String) {
        nameLabel.text = text
        if let favoriteButton = favoriteButton {
            favoriteButton.removeFromSuperview()
        }
    }
    
    @objc private func tappedFavorite() {
        guard menuItem != nil else { return }
        menuItem!.favorited.toggle()
        print(menuItem!.favorited)
        let starImageName = favoriteButtonAttributes!.imageName
        let starImage = UIImage(named: starImageName)?.withRenderingMode(.alwaysTemplate)
        favoriteButton!.image = starImage
        favoriteButton!.tintColor = favoriteButtonAttributes!.tintColor
    }

}
