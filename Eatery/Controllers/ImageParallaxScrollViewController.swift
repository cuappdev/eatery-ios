//
//  ImageParallaxScrollViewController.swift
//  ScrollImageView
//
//  Created by William Ma on 9/18/19.
//  Copyright © 2019 William Ma. All rights reserved.
//

import Kingfisher
import SnapKit
import UIKit

// MARK: - Image Parallalax Scroll View Controller

/**
 Manage a scroll view and an image view with a parallax effect.
 */
class ImageParallaxScrollViewController: UIViewController {

    private let navigationBar = UINavigationBar()
    var backButtonTitle: String? {
        didSet {
            reloadNavigationBarItems()
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private let scrollView = UIScrollView()
    private let imageView = UIImageView()

    private let titleLabel = UILabel()
    override var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    let accessoryView = UIView()
    let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.delaysContentTouches = false
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        imageView.contentMode = .scaleAspectFill
        scrollView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.equalTo(view).dividedBy(3)
            make.top.leading.trailing.width.equalToSuperview()
        }

        navigationBar.tintColor = .white
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.barTintColor = .blue
        navigationBar.shadowImage = UIImage()
        navigationBar.delegate = self
        scrollView.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        let gradientView = GradientView(frame: .zero)
        gradientView.alpha = 0.5
        scrollView.addSubview(gradientView)
        gradientView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(imageView)
            make.height.equalTo(imageView).multipliedBy(2.0 / 3.0)
        }

        titleLabel.isOpaque = false
        titleLabel.font = .boldSystemFont(ofSize: 34)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .white
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 100), for: .horizontal)
        scrollView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.bottom.equalTo(imageView.snp.bottom).inset(16)
        }

        scrollView.addSubview(accessoryView)
        accessoryView.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(16)
            make.width.equalTo(0).priority(.low) // compress the view if its not needed
            make.trailing.equalToSuperview()
            make.bottom.equalTo(imageView.snp.bottom).inset(16)
        }

        contentView.backgroundColor = .green
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }

        reloadNavigationBarItems()
    }

    func loadImage(from url: URL) {
        imageView.kf.setImage(with: url)
    }

    private func reloadNavigationBarItems() {
        navigationBar.items = [
            UINavigationItem(title: backButtonTitle ?? ""),
            UINavigationItem(title: "")
        ]
    }

}

extension ImageParallaxScrollViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            imageView.transform = CGAffineTransform.identity
            imageView.snp.updateConstraints { make in
                make.top.equalToSuperview().offset(scrollView.contentOffset.y)
                make.height.equalTo(view).dividedBy(3).offset(-scrollView.contentOffset.y)
            }
        } else {
            imageView.transform = CGAffineTransform(translationX: 0, y: scrollView.contentOffset.y / 3)
            imageView.snp.updateConstraints { make in
                make.top.equalToSuperview()
                make.height.equalTo(view).dividedBy(3)
            }
        }

        let adjustedOffset = scrollView.contentOffset.y + view.layoutMargins.top
        if adjustedOffset < 0 {
            navigationBar.transform = CGAffineTransform(translationX: 0, y: 2 / 3 * adjustedOffset)
        } else {
            navigationBar.transform = .identity
        }
    }

}

extension ImageParallaxScrollViewController: UINavigationBarDelegate {

    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        navigationController?.popViewController(animated: true)
        return false
    }

}

// MARK: - Gradient View

private class GradientView: UIView {

    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        if let gradientLayer = layer as? CAGradientLayer {
            gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
