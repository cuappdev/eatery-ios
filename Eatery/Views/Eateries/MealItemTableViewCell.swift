//
//  MealItemTableViewCell.swift
//  Eatery
//
//  Created by Ethan Fine on 2/9/20.
//  Copyright © 2020 CUAppDev. All rights reserved.
//

import UIKit

class MealItemTableViewCell: UITableViewCell {

    private let favoriteButton = UIButton(type: .custom)
    private(set) var menuItem: Menu.Item?
    private let nameLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        nameLabel.font = UIFont.systemFont(ofSize: 14)
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
        }
        
        favoriteButton.addTarget(self, action: #selector(tappedFavorite), for: .touchUpInside)
        favoriteButton.isHidden = true
        addSubview(favoriteButton)
        favoriteButton.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.width.equalTo(favoriteButton.snp_width)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func favoriteButtonAttributes(isFavorited : Bool) -> (imageName: String, tintColor: UIColor) {
        return isFavorited ? ("selected", .favoriteYellow) : ("unselected", .eateryBlue)
    }
    
    /// Configures the cell's nameLabel text to match the menu item text (adjusting for whether or not the item is healthy) and adds a favorite button to the cell corresponding to whether the user has favorited the menu item
    func configure(for menuItem: Menu.Item) {
        self.menuItem = menuItem

        let itemText = menuItem.healthy
            ? NSMutableAttributedString(string: "\(menuItem.name.trim()) ")
             .appendImage(UIImage(named: "appleIcon")!, yOffset: -1.5)
            : NSMutableAttributedString(string: menuItem.name.trim())
        nameLabel.attributedText = itemText
        
        let favButtonAttributes = favoriteButtonAttributes(isFavorited: menuItem.favorited)
        let starImageName = favButtonAttributes.imageName
        let starImage = UIImage(named: starImageName)?.withRenderingMode(.alwaysTemplate)
        favoriteButton.setImage(starImage, for: .normal)
        favoriteButton.tintColor = favButtonAttributes.tintColor
        favoriteButton.isHidden = false
    }
    
    /// Sets label text but removes favoriting ability
    func setLabelText(_ text: String) {
        nameLabel.text = text
        favoriteButton.removeFromSuperview()
    }
    
    @objc private func tappedFavorite() {
        guard let menuItem = menuItem else { return }
        menuItem.favorited.toggle()
        if menuItem.favorited {
            NotificationsManager.shared.requestAuthorization()
            NotificationsManager.shared.updateNotifications(menuItemNames: [menuItem.name])
        } else {
            NotificationsManager.shared.removeScheduledNotifications(menuItemName: menuItem.name)
        }
        
        let favButtonAttributes = favoriteButtonAttributes(isFavorited: menuItem.favorited)
        let starImage = UIImage(named: favButtonAttributes.imageName)?.withRenderingMode(.alwaysTemplate)
        favoriteButton.setImage(starImage, for: .normal)
        favoriteButton.tintColor = favButtonAttributes.tintColor
    }

}
