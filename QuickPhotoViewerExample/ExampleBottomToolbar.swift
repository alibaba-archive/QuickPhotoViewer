//
//  ExampleBottomToolbar.swift
//  QuickPhotoViewerExample
//
//  Created by 洪鑫 on 2017/3/15.
//  Copyright © 2017年 Teambition. All rights reserved.
//

import UIKit

let kExampleBottomToolbarHeight: CGFloat = 64

class ExampleBottomToolbar: UIView {
    lazy var pageIndexLabel: UILabel = {
        let pageIndexLabel = UILabel()
        pageIndexLabel.translatesAutoresizingMaskIntoConstraints = false
        pageIndexLabel.font = .systemFont(ofSize: 14)
        pageIndexLabel.textColor = .white
        pageIndexLabel.textAlignment = .left
        return pageIndexLabel
    }()
    lazy var downloadImageView: UIImageView = {
        let downloadImageView = UIImageView()
        downloadImageView.translatesAutoresizingMaskIntoConstraints = false
        return downloadImageView
    }()
    lazy var shareImageView: UIImageView = {
        let shareImageView = UIImageView()
        shareImageView.translatesAutoresizingMaskIntoConstraints = false
        return shareImageView
    }()

    var shareHandler: (() -> Void)?

    // MARK: - Public
    func setCurrentIndex(_ currentIndex: Int, totalCount: Int) {
        pageIndexLabel.text = "\(currentIndex) / \(totalCount)"
    }

    // MARK: - Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: - Helpers
    fileprivate func commonInit() {
        backgroundColor = .clear

        setCurrentIndex(0, totalCount: 0)
        downloadImageView.image = #imageLiteral(resourceName: "downloadIcon")
        shareImageView.image = #imageLiteral(resourceName: "shareIcon")
        shareImageView.isUserInteractionEnabled = true
        let shareTapGesture = UITapGestureRecognizer(target: self, action: #selector(shareImageViewTapped(_:)))
        shareImageView.addGestureRecognizer(shareTapGesture)

        addSubview(pageIndexLabel)
        addSubview(downloadImageView)
        addSubview(shareImageView)

        addConstraint(NSLayoutConstraint(item: pageIndexLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))

        addConstraint(NSLayoutConstraint(item: downloadImageView, attribute: .width, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 24))
        addConstraint(NSLayoutConstraint(item: downloadImageView, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 24))
        addConstraint(NSLayoutConstraint(item: downloadImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))

        addConstraint(NSLayoutConstraint(item: shareImageView, attribute: .width, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 24))
        addConstraint(NSLayoutConstraint(item: shareImageView, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 24))
        addConstraint(NSLayoutConstraint(item: shareImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[pageIndexLabel]-20-[downloadImageView]-20-[shareImageView]-15-|", options: [], metrics: nil, views: ["pageIndexLabel": pageIndexLabel, "downloadImageView": downloadImageView, "shareImageView": shareImageView]))

        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: kExampleBottomToolbarHeight))
    }

    // MARK: - Actions
    @objc func shareImageViewTapped(_ sender: UITapGestureRecognizer) {
        shareHandler?()
    }
}
