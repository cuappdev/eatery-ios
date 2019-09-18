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

/**
 Manage a scroll view and an image view with a parallax effect.
 */
class ImageParallaxScrollViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let imageView = UIImageView()
    
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
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
        }

        imageView.contentMode = .scaleAspectFill
        scrollView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.equalTo(view).dividedBy(3)
            make.top.leading.trailing.width.equalToSuperview()
        }

        contentView.backgroundColor = .green
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    func loadImage(from url: URL) {
        imageView.kf.setImage(with: url)
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
            imageView.transform = CGAffineTransform(translationX: 0.0, y: scrollView.contentOffset.y / 3)
            imageView.snp.updateConstraints { make in
                make.top.equalToSuperview()
                make.height.equalTo(view).dividedBy(3)
            }
        }
    }

}
