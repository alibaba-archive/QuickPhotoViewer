//
//  ExampleTopToolbar.swift
//  QuickPhotoViewerExample
//
//  Created by 洪鑫 on 2017/3/15.
//  Copyright © 2017年 Teambition. All rights reserved.
//

import UIKit

let kExampleTopToolbarHeight: CGFloat = 54
let kExampleAvatarSize = CGSize(width: 24, height: 24)

class ExampleTopToolbar: UIView {
    lazy var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        return avatarImageView
    }()
    lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 14)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .left
        return nameLabel
    }()
    lazy var closeImageView: UIImageView = {
        let closeImageView = UIImageView()
        closeImageView.translatesAutoresizingMaskIntoConstraints = false
        return closeImageView
    }()

    var closeHandler: (() -> Void)?

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

        avatarImageView.layer.cornerRadius = kExampleAvatarSize.width / 2
        avatarImageView.layer.masksToBounds = true
        avatarImageView.kf.setImage(with: URL(string: kExamplePhotos[0])!, placeholder: UIColor(white: 221 / 255, alpha: 1).toImage())
        nameLabel.text = "Xin Hong 上传于 15:27"
        closeImageView.image = #imageLiteral(resourceName: "closeIcon")
        closeImageView.isUserInteractionEnabled = true
        let closeTapGesture = UITapGestureRecognizer(target: self, action: #selector(closeImageViewTapped(_:)))
        closeImageView.addGestureRecognizer(closeTapGesture)

        addSubview(avatarImageView)
        addSubview(nameLabel)
        addSubview(closeImageView)

        addConstraint(NSLayoutConstraint(item: avatarImageView, attribute: .width, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: kExampleAvatarSize.width))
        addConstraint(NSLayoutConstraint(item: avatarImageView, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: kExampleAvatarSize.height))
        addConstraint(NSLayoutConstraint(item: avatarImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))

        addConstraint(NSLayoutConstraint(item: nameLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))

        addConstraint(NSLayoutConstraint(item: closeImageView, attribute: .width, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 24))
        addConstraint(NSLayoutConstraint(item: closeImageView, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: 24))
        addConstraint(NSLayoutConstraint(item: closeImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[avatarImageView]-12-[nameLabel]-12-[closeImageView]-15-|", options: [], metrics: nil, views: ["avatarImageView": avatarImageView, "nameLabel": nameLabel, "closeImageView": closeImageView]))

        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: .none, attribute: .notAnAttribute, multiplier: 1, constant: kExampleTopToolbarHeight))
    }

    // MARK: - Actions
    @objc func closeImageViewTapped(_ sender: UITapGestureRecognizer) {
        closeHandler?()
    }
}
