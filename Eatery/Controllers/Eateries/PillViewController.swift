//
//  PillViewController.swift
//  Eatery
//
//  Created by William Ma on 4/10/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import SnapKit
import UIKit

protocol PillViewControllerDelegate: AnyObject {

    func pillViewControllerSelectedSegmentDidChange(_ pillViewController: PillViewController)

}

class PillViewController: UIViewController {

    let pillView = PillView()
    private var showPillConstraints: [Constraint] = []
    private var hidePillConstraints: [Constraint] = []
    private(set) var isShowingPill: Bool {
        didSet {
            if isShowingPill {
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
        }
    }

    private let containerController = UIViewController()
    private var containerView: UIView { containerController.view }
    let leftViewController: UIViewController
    let rightViewController: UIViewController

    weak var delegate: PillViewControllerDelegate?

    init(leftViewController: UIViewController, rightViewController: UIViewController) {
        self.leftViewController = leftViewController
        self.rightViewController = rightViewController
        self.isShowingPill = false
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) will not be implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addChildViewController(containerController)
        containerController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 56, right: 0)
        containerView.backgroundColor = .clear
        view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        containerController.didMove(toParentViewController: self)

        containerController.addChildViewController(leftViewController)
        containerView.addSubview(leftViewController.view)
        leftViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        leftViewController.didMove(toParentViewController: containerController)

        containerController.addChildViewController(rightViewController)
        containerView.addSubview(rightViewController.view)
        rightViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        rightViewController.didMove(toParentViewController: containerController)

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

        setShowPill(true, animated: false)
        if pillView.leftSegmentSelected {
            showLeftViewController()
        } else {
            showRightViewController()
        }
    }

    func setShowPill(_ showPill: Bool, animated: Bool) {
        // Prevents newly created cells from sharing the pill animation
        view.layoutIfNeeded()
        let animation = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
            self.isShowingPill = showPill
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

        delegate?.pillViewControllerSelectedSegmentDidChange(self)
    }

    private func showRightViewController() {
        leftViewController.view.removeFromSuperview()

        containerView.addSubview(rightViewController.view)
        rightViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        delegate?.pillViewControllerSelectedSegmentDidChange(self)
    }

}
