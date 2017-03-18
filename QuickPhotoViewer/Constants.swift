//
//  Constants.swift
//  QuickPhotoViewer
//
//  Created by 洪鑫 on 2017/3/15.
//  Copyright © 2017年 Teambition. All rights reserved.
//

import UIKit

internal struct PhotoPreview {
    static let pageSpacing: CGFloat = 20
    static let maximumZoomScale: CGFloat = 3
    static let minimumZoomScale: CGFloat = 1
}

internal struct PhotoPanning {
    static let gestureMaximumTriggerAngle: CGFloat = 20
    static let gestureMinimumZoomScale: CGFloat = 0.3
    static let gestureMinimumAlpha: CGFloat = 0
}

internal struct Gradient {
    static let height: CGFloat = 110
    static let startColor = UIColor.black.withAlphaComponent(0.3).cgColor
    static let endColor = UIColor.black.withAlphaComponent(0).cgColor
    static let startPoint = CGPoint(x: 0, y: 0)
    static let endPoint = CGPoint(x: 0, y: 1)
}
