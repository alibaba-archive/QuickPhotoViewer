//
//  Animator.swift
//  QuickPhotoViewer
//
//  Created by 洪鑫 on 2017/3/16.
//  Copyright © 2017年 Teambition. All rights reserved.
//

import UIKit

internal enum QuickPhotoViewerAnimation {
    case present(fromView: UIView)
    case dismiss(toView: UIView)
}

internal class QuickPhotoViewerTransitioning: NSObject, UIViewControllerTransitioningDelegate {
    private var animation: QuickPhotoViewerAnimation!

    internal init(_ animation: QuickPhotoViewerAnimation) {
        self.animation = animation
    }

    internal func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return QuickPhotoViewerAnimator(animation)
    }

    internal func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return QuickPhotoViewerAnimator(animation)
    }
}

internal class QuickPhotoViewerAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private var animation: QuickPhotoViewerAnimation!

    internal init(_ animation: QuickPhotoViewerAnimation) {
        self.animation = animation
    }

    internal func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        switch animation! {
        case .present(_):
            return 0.3
        case .dismiss(_):
            return 0.3
        }
    }

    internal func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch animation! {
        case .present(let fromView):
            guard let toViewController = transitionContext.viewController(forKey: .to) else {
                return
            }
            if let photoViewer = toViewController as? QuickPhotoViewer {
                photoViewer.transitioningSourceView = fromView
            }
            let toRect = transitionContext.finalFrame(for: toViewController)
            toViewController.view.frame = toRect
            transitionContext.containerView.addSubview(toViewController.view)
            toViewController.view.alpha = 0
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           delay: 0,
                           options: [.beginFromCurrentState],
                           animations: {
                            toViewController.view.alpha = 1
                }, completion: { _ in
                    let success = !transitionContext.transitionWasCancelled
                    if !success {
                        toViewController.view.removeFromSuperview()
                    }
                    transitionContext.completeTransition(success)
            })
        case .dismiss(_):
            guard let fromViewController = transitionContext.viewController(forKey: .from), let toViewController = transitionContext.viewController(forKey: .to) else {
                return
            }
            toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
            transitionContext.containerView.addSubview(toViewController.view)
            transitionContext.containerView.addSubview(fromViewController.view)
            fromViewController.view.alpha = 1
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           delay: 0,
                           options: [.beginFromCurrentState],
                           animations: {
                            fromViewController.view.alpha = 0
                }, completion: { _ in
                    let success = !transitionContext.transitionWasCancelled
                    if !success {
                        toViewController.view.removeFromSuperview()
                    }
                    transitionContext.completeTransition(success)
            })
        }
    }
}
