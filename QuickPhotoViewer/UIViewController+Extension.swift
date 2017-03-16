//
//  UIViewController+Extension.swift
//  QuickPhotoViewer
//
//  Created by 洪鑫 on 2017/3/16.
//  Copyright © 2017年 Teambition. All rights reserved.
//

import UIKit

public extension UIViewController {
    public func present(_ photoViewer: QuickPhotoViewer,
                        from view: UIView,
                        animated flag: Bool = true,
                        completion: (() -> Void)? = nil) {
        let transitioningDelegate = QuickPhotoViewerTransitioning(.present(fromView: view))
        photoViewer.transitioningDelegate = transitioningDelegate
        present(photoViewer, animated: flag, completion: completion)
    }
}
