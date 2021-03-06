//
//  TabbedPageViewController.swift
//  Eatery
//
//  Created by William Ma on 9/25/19.
//  Copyright © 2019 CUAppDev. All rights reserved.
//

import UIKit

protocol TabbedPageViewControllerDelegate: AnyObject {

    func tabbedPageViewController(
        _ tabbedPageViewController: TabbedPageViewController,
        titleForViewController viewController: UIViewController
    ) -> String?

    func tabbedPageViewController(
        _ tabbedPageViewController: TabbedPageViewController,
        heightOfContentForViewController viewController: UIViewController
    ) -> CGFloat

}

class TabbedPageViewController: UIViewController {

    private let viewControllers: [UIViewController]
    private var didLoad = false

    private var pageViewController: UIPageViewController!
    private var tabBar: TabBar?

    weak var delegate: TabbedPageViewControllerDelegate?

    private var currentViewController: UIViewController? {
        pageViewController.viewControllers?.first
    }

    var currentViewControllerIndex: Int? {
        get {
            if let viewController = currentViewController {
                return viewControllers.index(of: viewController)
            } else {
                return nil
            }
        }
        set {
            if let index = newValue {
                setPage(forViewControllerAt: index)
            }
        }
    }

    init(viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        if viewControllers.count > 1 {
            let titles = viewControllers.map {
                delegate?.tabbedPageViewController(self, titleForViewController: $0) ?? ""
            }
            let tabBar = UnderlineTabBarControl(sections: titles)
            tabBar.addTarget(
                self,
                action: #selector(tabBarControlSelectedSegmentIndexDidChange(_:)),
                for: .valueChanged
            )

            view.addSubview(tabBar)
            tabBar.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.leading.trailing.equalToSuperview().inset(16)
                make.height.equalTo(32)
            }

            self.tabBar = tabBar
        }

        pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.view.isUserInteractionEnabled = viewControllers.count != 1

        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints { make in
            if let tabBar = tabBar {
                make.top.equalTo(tabBar.snp.bottom)
            } else {
                make.top.equalTo(view)
            }

            make.leading.trailing.bottom.equalToSuperview()
        }
        pageViewController.didMove(toParentViewController: self)

        guard let first = viewControllers.first else {
            return
        }

        pageViewController.setViewControllers(
            [first],
            direction: .forward,
            animated: false,
            completion: nil
        )
        pageViewController.view.snp.makeConstraints { make in
            let height = delegate?.tabbedPageViewController(
                self,
                heightOfContentForViewController: first
            ) ?? 0
            make.height.equalTo(height)
        }
    }

    func setPage(forViewControllerAt index: Int) {
        guard let currentIndex = currentViewControllerIndex, index != currentIndex else {
            return
        }

        let direction: UIPageViewControllerNavigationDirection = index > currentIndex ? .forward : .reverse

        // Why is animated set to false here?
        // Because of a bug in UIPageViewController that causes the app to crash
        // when UIPageViewController.setViewControllers is called when the
        // previous animation did not complete
        // Source: https://stackoverflow.com/a/47878351
        pageViewController.setViewControllers(
            [viewControllers[index]],
            direction: direction,
            animated: false,
            completion: nil
        )

        pageViewControllerDidChangeViewController()
    }

    /// Call this method when the page VC's children are modified.
    /// This method updates the underline bar and adjusts the page view
    /// controller's height.
    private func pageViewControllerDidChangeViewController() {
        adjustPageViewControllerHeight()

        if let index = currentViewControllerIndex, let tabBar = tabBar {
            tabBar.select(at: index)
        }
    }

    private func adjustPageViewControllerHeight() {
        pageViewController.view.snp.updateConstraints { make in
            if let viewController = currentViewController {
                let height = delegate?.tabbedPageViewController(
                    self,
                    heightOfContentForViewController: viewController
                ) ?? 0
                make.height.equalTo(height)
            }
        }
    }

    @objc private func tabBarControlSelectedSegmentIndexDidChange(_ tabBar: UnderlineTabBarControl) {
        setPage(forViewControllerAt: tabBar.selectedSegmentIndex)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if didLoad {
            for case let controller as CampusEateryMealTableViewController in viewControllers {
                controller.tableView.reloadData()
            }
        }
        didLoad = true
    }

}

extension TabbedPageViewController: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        if let index = viewControllers.index(of: viewController), index > 0 {
            return viewControllers[index - 1]
        }
        return nil
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        if let index = viewControllers.index(of: viewController), index < viewControllers.count - 1 {
            return viewControllers[index + 1]
        }
        return nil
    }

}

extension TabbedPageViewController: UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed {
            pageViewControllerDidChangeViewController()
        }
    }

}
