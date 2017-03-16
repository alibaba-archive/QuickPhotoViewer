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

public enum QuickPhotoViewerToolbarAnimation {
    case none
    case fade
    case slide
}

public class QuickPhotoViewer: UIViewController {
    public weak var dataSource: QuickPhotoViewerDataSource?
    public weak var delegate: QuickPhotoViewerDelegate?

    public var photos = [QPhoto]()
    public var initialPageIndex = 0
    public var topToolbar: UIView?
    public var bottomToolbar: UIView?
    public var toolbarUpdateAnimation: QuickPhotoViewerToolbarAnimation = .slide
    public var transitioningSourceView: UIView?

    public fileprivate(set) var viewMode: QuickPhotoViewerViewMode = .normal
    public fileprivate(set) var currentPageIndex = 0
    public var currentPhoto: QPhoto? {
        guard !photos.isEmpty else {
            return nil
        }
        guard 0..<photos.count ~= currentPageIndex else {
            return nil
        }
        return photos[currentPageIndex]
    }

    fileprivate lazy var pageViewController: UIPageViewController = self.makePageViewController()
    fileprivate lazy var topGradientLayer: CAGradientLayer = self.makeTopGradientLayer()
    fileprivate lazy var bottomGradientLayer: CAGradientLayer = self.makeBottomGradientLayer()

    fileprivate var topToolbarTop: NSLayoutConstraint?
    fileprivate var bottomToolbarBottom: NSLayoutConstraint?

    // MARK: - Life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureToolbars()
        initPages()
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        topGradientLayer.frame = CGRect(origin: .zero, size: CGSize(width: view.bounds.width, height: Gradient.height))
        bottomGradientLayer.frame = CGRect(origin: CGPoint(x: 0, y: view.bounds.height - Gradient.height), size: CGSize(width: view.bounds.width, height: Gradient.height))
    }

    // MARK: - Overriding
    public override var prefersStatusBarHidden: Bool {
        return true
    }

    public override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if let transitioningSourceView = transitioningSourceView {
            let transitioningDelegate = QuickPhotoViewerTransitioning(.dismiss(toView: transitioningSourceView))
            self.transitioningDelegate = transitioningDelegate
            super.dismiss(animated: flag, completion: completion)
        } else {
            super.dismiss(animated: flag, completion: completion)
        }
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

        pageViewController.dataSource = self
        pageViewController.delegate = self

        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)

        view.layer.insertSublayer(topGradientLayer, above: pageViewController.view.layer)
        view.layer.insertSublayer(bottomGradientLayer, above: pageViewController.view.layer)
    }

    fileprivate func configureToolbars() {
        if let topToolbar = topToolbar {
            topToolbar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(topToolbar)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[topToolbar]|", options: [], metrics: nil, views: ["topToolbar": topToolbar]))
            topToolbarTop = NSLayoutConstraint(item: topToolbar, attribute: .top, relatedBy: .equal, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
            view.addConstraint(topToolbarTop!)
        }
        if let bottomToolbar = bottomToolbar {
            bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(bottomToolbar)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomToolbar]|", options: [], metrics: nil, views: ["bottomToolbar": bottomToolbar]))
            bottomToolbarBottom = NSLayoutConstraint(item: bottomToolbar, attribute: .bottom, relatedBy: .equal, toItem: bottomLayoutGuide, attribute: .top, multiplier: 1, constant: 0)
            view.addConstraint(bottomToolbarBottom!)
        }
        switchViewMode(to: viewMode, with: .none)
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
        photoViewController.delegate = self
        photoViewController.photo = photos[currentPageIndex]
        pageViewController.setViewControllers([photoViewController], direction: .forward, animated: false, completion: nil)
    }

    fileprivate func switchViewMode(to newMode: QuickPhotoViewerViewMode, with animation: QuickPhotoViewerToolbarAnimation) {
        guard viewMode != newMode else {
            return
        }
        viewMode = newMode

        switch animation {
        case .none:
            switch newMode {
            case .normal:
                topToolbar?.alpha = 1
                bottomToolbar?.alpha = 1
            case .fullScreen:
                topToolbar?.alpha = 0
                bottomToolbar?.alpha = 0
            }
        case .fade:
            switch newMode {
            case .normal:
                UIView.animate(withDuration: 0.3, animations: {
                    self.topToolbar?.alpha = 1
                    self.bottomToolbar?.alpha = 1
                })
            case .fullScreen:
                UIView.animate(withDuration: 0.3, animations: {
                    self.topToolbar?.alpha = 0
                    self.bottomToolbar?.alpha = 0
                })
            }
        case .slide:
            switch newMode {
            case .normal:
                if let _ = topToolbar, let topToolbarTop = topToolbarTop {
                    topToolbarTop.constant = 0
                }
                if let _ = bottomToolbar, let bottomToolbarBottom = bottomToolbarBottom {
                    bottomToolbarBottom.constant = 0
                }
                UIView.animate(withDuration: 0.25, animations: {
                    self.view.layoutIfNeeded()
                })
            case .fullScreen:
                if let topToolbar = topToolbar, let topToolbarTop = topToolbarTop {
                    topToolbarTop.constant = -topToolbar.frame.height
                }
                if let bottomToolbar = bottomToolbar, let bottomToolbarBottom = bottomToolbarBottom {
                    bottomToolbarBottom.constant = bottomToolbar.frame.height
                }
                UIView.animate(withDuration: 0.25, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }

    // MARK: - Make functions
    fileprivate func makePageViewController() -> UIPageViewController {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        return pageViewController
    }

    fileprivate func makeTopGradientLayer() -> CAGradientLayer {
        let topGradientLayer = CAGradientLayer()
        topGradientLayer.colors = [Gradient.startColor, Gradient.endColor]
        topGradientLayer.startPoint = Gradient.startPoint
        topGradientLayer.endPoint = Gradient.endPoint
        return topGradientLayer
    }

    fileprivate func makeBottomGradientLayer() -> CAGradientLayer {
        let bottomGradientLayer = CAGradientLayer()
        bottomGradientLayer.colors = [Gradient.endColor, Gradient.startColor]
        bottomGradientLayer.startPoint = Gradient.startPoint
        bottomGradientLayer.endPoint = Gradient.endPoint
        return bottomGradientLayer
    }
}

extension QuickPhotoViewer: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    // MARK: - UIPageViewControllerDataSource & UIPageViewControllerDelegate
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil
    }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

    }
}

extension QuickPhotoViewer: PhotoViewControllerDelegate {
    // MARK: - PhotoViewControllerDelegate
    func photoViewControllerDidTapPhoto(_ controller: PhotoViewController) {
        switch viewMode {
        case .normal:
            switchViewMode(to: .fullScreen, with: toolbarUpdateAnimation)
        case .fullScreen:
            switchViewMode(to: .normal, with: toolbarUpdateAnimation)
        }
    }

    func photoViewController(_ controller: PhotoViewController, didDoubleTapPhotoAt point: CGPoint, in view: UIView) {
        controller.zoomPhotoToFit(from: point, in: view)
    }

    func photoViewControllerDidTapBackground(_ controller: PhotoViewController) {
        switch viewMode {
        case .normal:
            switchViewMode(to: .fullScreen, with: toolbarUpdateAnimation)
        case .fullScreen:
            switchViewMode(to: .normal, with: toolbarUpdateAnimation)
        }
    }

    func photoViewController(_ controller: PhotoViewController, didDoubleTapBackgroundAt point: CGPoint, in view: UIView) {
        controller.zoomPhotoToFit(from: point, in: view)
    }
}
