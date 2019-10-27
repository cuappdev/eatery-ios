//
//  MenuViewController.swift
//  Eatery
//
//  Created by William Ma on 9/18/19.
//  Copyright © 2019 William Ma. All rights reserved.
//

import Hero
import Kingfisher
import SnapKit
import UIKit

class MenuViewController: UIViewController {

    private var fadeInOnViewDidAppear = true
    private let navigationBar = UINavigationBar()
    private let navigationBarBackground = UIView()

    private let scrollView = UIScrollView()
    let imageView = UIImageView()
    let gradientView = MenuGradientView()

    let headerView = UIView()
    let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpScrollView()
        setUpImageView()
        setUpGradientView()
        setUpHeaderView()
        setUpContentView()
        setUpNavigationBarAndBackground()
    }

    private func setUpScrollView() {
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.delaysContentTouches = true
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setUpImageView() {
        imageView.contentMode = .scaleAspectFill
        scrollView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.equalTo(view).dividedBy(3)
            make.top.leading.trailing.width.equalToSuperview()
        }
    }

    private func setUpGradientView() {
        scrollView.addSubview(gradientView)
        gradientView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(imageView)
            make.height.equalTo(imageView).multipliedBy(2.0 / 3.0)
        }
    }

    private func setUpHeaderView() {
        scrollView.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.bottom.equalTo(imageView)
            make.leading.trailing.width.equalToSuperview()
        }
    }

    private func setUpContentView() {
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.leading.trailing.bottom.width.equalToSuperview()
        }
    }

    private func setUpNavigationBarAndBackground() {
        navigationBar.tintColor = .white
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.delegate = self

        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.leading.trailing.equalToSuperview()
        }

        navigationBarBackground.backgroundColor = nil
        view.insertSubview(navigationBarBackground, belowSubview: navigationBar)
        navigationBarBackground.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.bottom.equalTo(navigationBar)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Why fade in the navigation bar instead of using hero?
        //
        // Hero does not play well with transparent navigation bars: the
        // background is rendered opaquely.
        if fadeInOnViewDidAppear {
            fadeInNavigationBar()
            fadeInOnViewDidAppear = false
        }
    }

    private func fadeInNavigationBar() {
        navigationBar.alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.navigationBar.alpha = 1
        }
    }

    func setBackButtonTitle(_ title: String) {
        navigationBar.items = [UINavigationItem(title: title), UINavigationItem(title: "")]
    }

}

extension MenuViewController: UIScrollViewDelegate {

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

        if navigationBar.frame.intersects(contentView.convert(contentView.bounds, to: view)) {
            UIView.animate(withDuration: 0.25) {
                self.navigationBarBackground.backgroundColor = .eateryBlue
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                self.navigationBarBackground.backgroundColor = nil
            }
        }
    }

}

extension MenuViewController: UINavigationBarDelegate {

    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        navigationController?.popViewController(animated: true)
        return false
    }

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }

}

class MenuGradientView: UIView {

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
