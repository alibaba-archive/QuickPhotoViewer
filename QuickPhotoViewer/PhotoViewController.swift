//
//  PhotoViewController.swift
//  QuickPhotoViewer
//
//  Created by 洪鑫 on 2017/3/15.
//  Copyright © 2017年 Teambition. All rights reserved.
//

import UIKit
import Kingfisher

internal protocol PhotoViewControllerDelegate: class {
    func photoViewControllerDidTapPhoto(_ controller: PhotoViewController)
    func photoViewController(_ controller: PhotoViewController, didDoubleTapPhotoAt point: CGPoint, in view: UIView)
    func photoViewControllerDidTapBackground(_ controller: PhotoViewController)
    func photoViewController(_ controller: PhotoViewController, didDoubleTapBackgroundAt point: CGPoint, in view: UIView)
}

internal class PhotoViewController: UIViewController {
    internal weak var delegate: PhotoViewControllerDelegate?
    internal var photo: QPhoto!
    internal var pageIndex = 0

    fileprivate(set) lazy var scrollView: UIScrollView = self.makeScrollView()
    fileprivate(set) lazy var imageView: UIImageView = self.makeImageView()

    fileprivate var imageViewLeading: NSLayoutConstraint!
    fileprivate var imageViewTrailing: NSLayoutConstraint!
    fileprivate var imageViewTop: NSLayoutConstraint!
    fileprivate var imageViewBottom: NSLayoutConstraint!

    fileprivate var panGestureRecognizer: UIPanGestureRecognizer!
    fileprivate var panGestureStartPoint: CGPoint?

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestureRecognizers()
        loadPhoto()
    }

    // MARK: - Public
    internal func zoomPhotoToFit(from point: CGPoint, in view: UIView) {
        if scrollView.zoomScale == scrollView.minimumZoomScale {
            zoomImageViewToFit(from: view.convert(point, to: imageView))
        } else {
            zoomImageViewToMinimum()
        }
    }
}

extension PhotoViewController {
    // MARK: - Helpers
    fileprivate func setupUI() {
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        edgesForExtendedLayout = .top

        scrollView.delegate = self

        view.addSubview(scrollView)
        scrollView.addSubview(imageView)

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView]))

        imageViewLeading = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1, constant: 0)
        imageViewTrailing = NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: imageView, attribute: .trailing, multiplier: 1, constant: 0)
        imageViewTop = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1, constant: 0)
        imageViewBottom = NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1, constant: 0)
        scrollView.addConstraints([imageViewLeading, imageViewTrailing, imageViewTop, imageViewBottom])
    }

    fileprivate func setupGestureRecognizers() {
        imageView.isUserInteractionEnabled = true

        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(singleTapGesture)

        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageDoubleTapped(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGesture)

        singleTapGesture.require(toFail: doubleTapGesture)

        view.isUserInteractionEnabled = true

        let backgroundSingleTapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:)))
        backgroundSingleTapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(backgroundSingleTapGesture)

        let backgroundDoubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundDoubleTapped(_:)))
        backgroundDoubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(backgroundDoubleTapGesture)

        backgroundSingleTapGesture.require(toFail: backgroundDoubleTapGesture)

        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(backgroundPanned(_:)))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
    }

    fileprivate func loadPhoto() {
        if let localImage = photo.localImage {
            imageView.image = localImage
            self.updateScrollViewZoomScale()
        } else if let url = photo.url {
            let imageResource = ImageResource(downloadURL: url, cacheKey: url.cacheKey)
            imageView.kf.setImage(with: imageResource,
                                  placeholder: photo.localThumbnailImage,
                                  options: nil,
                                  progressBlock: { (downloadedSize, totalSize) in

                }, completionHandler: { (image, error, cacheType, url) in
                    self.updateScrollViewZoomScale()
            })
        }
    }

    // MARK: - Make functions
    fileprivate func makeScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.maximumZoomScale = PhotoPreview.maximumZoomScale
        scrollView.minimumZoomScale = PhotoPreview.minimumZoomScale
        return scrollView
    }

    fileprivate func makeImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }
}

extension PhotoViewController {
    // MARK: - Zooming
    fileprivate func updateScrollViewZoomScale() {
        guard let image = imageView.image else {
            return
        }
        let minimumZoomScale = min(min(view.bounds.width / image.size.width, view.bounds.height / image.size.height), 1)
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.zoomScale = minimumZoomScale
    }

    fileprivate func zoomImageView() {
        guard let image = imageView.image else {
            return
        }
        let horizontalPadding = max((view.bounds.width - image.size.width * scrollView.zoomScale) / 2, 0)
        let verticalPadding = max((view.bounds.height - image.size.height * scrollView.zoomScale) / 2, 0)
        imageViewLeading.constant = horizontalPadding
        imageViewTrailing.constant = horizontalPadding
        imageViewTop.constant = verticalPadding
        imageViewBottom.constant = verticalPadding
        view.layoutIfNeeded()
    }

    fileprivate func zoomImageViewToFit(from point: CGPoint) {
        guard let image = imageView.image else {
            return
        }
        let minimumZoomScaleForFit: CGFloat = 2

        let scaleX = view.bounds.width / image.size.width
        let scaleY = view.bounds.height / image.size.height

        let scale: CGFloat = {
            if min(scaleX, scaleY) > 1 {
                return max(min(scaleX, scaleY), minimumZoomScaleForFit) * scrollView.minimumZoomScale
            } else {
                return max(max(scaleX, scaleY) / min(scaleX, scaleY), minimumZoomScaleForFit) * scrollView.minimumZoomScale
            }
        }()

        let newWidth = scrollView.bounds.width / scale
        let newHeight = scrollView.bounds.height / scale
        let newRect = CGRect(x: point.x - newWidth / 2, y: point.y - newHeight / 2, width: newWidth, height: newHeight)
        scrollView.zoom(to: newRect, animated: true)
    }

    fileprivate func zoomImageViewToMinimum() {
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
    }
}

extension PhotoViewController {
    // MARK: - Actions
    func imageTapped(_ sender: UITapGestureRecognizer) {
        delegate?.photoViewControllerDidTapPhoto(self)
    }

    func imageDoubleTapped(_ sender: UITapGestureRecognizer) {
        delegate?.photoViewController(self, didDoubleTapPhotoAt: sender.location(in: imageView), in: imageView)
    }

    func backgroundTapped(_ sender: UITapGestureRecognizer) {
        delegate?.photoViewControllerDidTapBackground(self)
    }

    func backgroundDoubleTapped(_ sender: UITapGestureRecognizer) {
        delegate?.photoViewController(self, didDoubleTapBackgroundAt: sender.location(in: view), in: view)
    }

    func backgroundPanned(_ sender: UIPanGestureRecognizer) {
        guard scrollView.zoomScale == scrollView.minimumZoomScale else {
            return
        }
        let currentLocation = sender.location(in: view)
        switch sender.state {
        case .began:
            panGestureStartPoint = currentLocation
        case .changed:
            if let panGestureStartPoint = panGestureStartPoint {
                let distanceX = currentLocation.x - panGestureStartPoint.x
                let distanceY = currentLocation.y - panGestureStartPoint.y
                print("distanceX: \(distanceX)")
                print("distanceY: \(distanceY)")
            }
        case .possible, .ended, .cancelled, .failed:
            panGestureStartPoint = nil
        }
    }
}

extension PhotoViewController: UIGestureRecognizerDelegate {
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return false
    }
}

extension PhotoViewController: UIScrollViewDelegate {
    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        zoomImageView()
    }
}
