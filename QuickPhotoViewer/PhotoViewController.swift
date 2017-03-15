//
//  PhotoViewController.swift
//  QuickPhotoViewer
//
//  Created by 洪鑫 on 2017/3/15.
//  Copyright © 2017年 Teambition. All rights reserved.
//

import UIKit
import Kingfisher

internal class PhotoViewController: UIViewController {
    var photo: QPhoto!

    internal var pageIndex = 0

    fileprivate lazy var scrollView: UIScrollView = self.makeScrollView()
    fileprivate lazy var imageView: UIImageView = self.makeImageView()

    fileprivate var imageViewWidth: NSLayoutConstraint!
    fileprivate var imageViewHeight: NSLayoutConstraint!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPhoto()
    }
}

extension PhotoViewController {
    // MARK: - Helpers
    fileprivate func setupUI() {
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        edgesForExtendedLayout = .top

        scrollView.delegate = self
        imageView.isUserInteractionEnabled = true

        view.addSubview(scrollView)
        scrollView.addSubview(imageView)

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[scrollView]|", options: [], metrics: nil, views: ["scrollView": scrollView]))

        scrollView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: scrollView, attribute: .centerX, multiplier: 1, constant: 0))
        scrollView.addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: scrollView, attribute: .centerY, multiplier: 1, constant: 0))
        imageViewWidth = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        imageViewHeight = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        scrollView.addConstraints([imageViewWidth, imageViewHeight])

        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(singleTapGesture)
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
        scrollView.isScrollEnabled = false
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
        if image.size.width > image.size.height {
            imageViewWidth.constant = max(image.size.width * scrollView.zoomScale, view.bounds.width)
            imageViewHeight.constant = image.size.height * scrollView.zoomScale
        } else if image.size.width < image.size.height {
            imageViewWidth.constant = image.size.width * scrollView.zoomScale
            imageViewHeight.constant = max(image.size.height * scrollView.zoomScale, view.bounds.height)
        } else {
            imageViewWidth.constant = image.size.width * scrollView.zoomScale
            imageViewHeight.constant = image.size.height * scrollView.zoomScale
        }
        view.layoutIfNeeded()
    }
}

extension PhotoViewController {
    // MARK: - Actions
    func imageTapped(_ sender: UITapGestureRecognizer) {

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
