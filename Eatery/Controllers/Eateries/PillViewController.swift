//
//  PillViewController.swift
//  Eatery
//
//  Created by William Ma on 4/10/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import SnapKit
import UIKit

class PillViewController: UIViewController {

    let pillView = PillView()

    private var showPillConstraints: [Constraint] = []
    private var hidePillConstraints: [Constraint] = []

    private let containerView = UIView()
    let leftViewController: UIViewController
    let rightViewController: UIViewController

    init(leftViewController: UIViewController, rightViewController: UIViewController) {
        self.leftViewController = leftViewController
        self.rightViewController = rightViewController
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.backgroundColor = .clear
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addChildViewController(leftViewController)
        containerView.addSubview(leftViewController.view)
        leftViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        leftViewController.didMove(toParentViewController: self)

        addChildViewController(rightViewController)
        containerView.addSubview(rightViewController.view)
        rightViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        rightViewController.didMove(toParentViewController: self)

        pillView.addTarget(self, action: #selector(pillSelectionDidChange), for: .valueChanged)
        view.addSubview(pillView)
        pillView.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(264)
            make.centerX.equalToSuperview()
        }
        showPillConstraints = pillView.snp.prepareConstraints { make in
            make.bottom.equalTo(view.snp.bottomMargin).inset(8)
        }
        hidePillConstraints = pillView.snp.prepareConstraints { make in
            make.top.equalTo(view.snp.bottom).offset(8)
        }

        leftViewController.view.preservesSuperviewLayoutMargins = true
        rightViewController.view.preservesSuperviewLayoutMargins = true
        containerView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 56, right: 0)

        setShowPill(true, animated: false)
        if pillView.leftSegmentSelected {
            showLeftViewController()
        } else {
            showRightViewController()
        }
    }

    func setShowPill(_ showPill: Bool, animated: Bool) {
        let animation = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
            if showPill {
                for constraint in self.hidePillConstraints {
                    constraint.deactivate()
                }

                for constraint in self.showPillConstraints {
                    constraint.activate()
                }
            } else {
                for constraint in self.showPillConstraints {
                    constraint.deactivate()
                }
                for constraint in self.hidePillConstraints {
                    constraint.activate()
                }
            }

            self.view.layoutIfNeeded()
        }

        animation.startAnimation()
        if !animated {
            animation.stopAnimation(false)
            animation.finishAnimation(at: .end)
        }
    }

    @objc private func pillSelectionDidChange() {
        if pillView.leftSegmentSelected {
            showLeftViewController()
        } else {
            showRightViewController()
        }
    }

    private func showLeftViewController() {
        rightViewController.view.removeFromSuperview()
        
        containerView.addSubview(leftViewController.view)
        leftViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func showRightViewController() {
        leftViewController.view.removeFromSuperview()

        containerView.addSubview(rightViewController.view)
        rightViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}
