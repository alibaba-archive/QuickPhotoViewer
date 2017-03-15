//
//  QuickPhotoViewer.swift
//  QuickPhotoViewer
//
//  Created by 洪鑫 on 2017/3/15.
//  Copyright © 2017年 Teambition. All rights reserved.
//

import UIKit

public enum QuickPhotoViewerViewMode {
    case normal
    case fullScreen
}

open class QuickPhotoViewer: UIPageViewController {
    open weak var viewerDataSource: QuickPhotoViewerDataSource?
    open weak var viewerDelegate: QuickPhotoViewerDelegate?

    open var photos = [QPhoto]()
    open var initialPageIndex = 0
    open var topToolbar: UIView?
    open var bottomToolbar: UIView?

    open fileprivate(set) var currentPageIndex = 0
    open fileprivate(set) var viewMode: QuickPhotoViewerViewMode = .normal
    open var currentPhoto: QPhoto? {
        guard !photos.isEmpty else {
            return nil
        }
        guard 0..<photos.count ~= currentPageIndex else {
            return nil
        }
        return photos[currentPageIndex]
    }

    // MARK: - Life cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureToolbars()
        initPages()
    }

    // MARK: - Overriding
    open override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension QuickPhotoViewer {
    // MARK: - Public
}

extension QuickPhotoViewer {
    // MARK: - Helpers
    fileprivate func setupUI() {
        view.backgroundColor = .black
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        edgesForExtendedLayout = .top
        dataSource = self
        delegate = self
    }

    fileprivate func configureToolbars() {
        if let topToolbar = topToolbar {
            topToolbar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(topToolbar)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topToolbar]|", options: [], metrics: nil, views: ["topToolbar": topToolbar]))
            view.addConstraint(NSLayoutConstraint(item: topToolbar, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
        }
        if let bottomToolbar = bottomToolbar {
            bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bottomToolbar)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomToolbar]|", options: [], metrics: nil, views: ["bottomToolbar": bottomToolbar]))
            view.addConstraint(NSLayoutConstraint(item: bottomToolbar, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0))
        }
    }

    fileprivate func initPages() {
        guard !photos.isEmpty else {
            return
        }
        if !(0..<photos.count ~= initialPageIndex) {
            initialPageIndex = 0
        }
        currentPageIndex = initialPageIndex
        let photoViewController = PhotoViewController()
        photoViewController.photo = photos[currentPageIndex]
        setViewControllers([photoViewController], direction: .forward, animated: false, completion: nil)
    }
}

extension QuickPhotoViewer: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    // MARK: - UIPageViewControllerDataSource & UIPageViewControllerDelegate
    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }

    open func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil
    }

    open func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

    }
}
