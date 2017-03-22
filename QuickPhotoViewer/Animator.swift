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
    case dismiss(toView: UIView?)
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
            return 0.25
        case .dismiss(_):
            return 0.25
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

            let fromRect = transitionContext.containerView.convert(fromView.frame, from: fromView.superview)
            let toRect = transitionContext.finalFrame(for: toViewController)
            transitionContext.containerView.addSubview(toViewController.view)

            let scale = CGAffineTransform(scaleX: fromRect.width / toRect.width, y: fromRect.height / toRect.height)
            let translation = CGAffineTransform(translationX: fromRect.midX - toRect.midX, y: fromRect.midY - toRect.midY)
            toViewController.view.transform = scale.concatenating(translation)

            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           delay: 0,
                           options: [.beginFromCurrentState, .curveEaseIn],
                           animations: {
                            toViewController.view.transform = CGAffineTransform(scaleX: 1, y: 1)
                }, completion: { _ in
                    let success = !transitionContext.transitionWasCancelled
                    if !success {
                        toViewController.view.removeFromSuperview()
                    }
                    transitionContext.completeTransition(success)
            })

        case .dismiss(let toView):
            guard let fromViewController = transitionContext.viewController(forKey: .from), let toViewController = transitionContext.viewController(forKey: .to) else {
                return
            }
            guard let photoViewer = fromViewController as? QuickPhotoViewer, let photoViewController = photoViewer.viewControllers?.first as? PhotoViewController else {
                return
            }

            let fromPhoto = UIImageView(image: photoViewController.imageView.image)
            fromPhoto.contentMode = .scaleAspectFill
            let fromPhotoRect = transitionContext.containerView.convert(photoViewController.imageView.frame, from: photoViewController.imageView.superview)
            photoViewController.imageView.removeFromSuperview()

            let toRect: CGRect = {
                if let toView = toView, photoViewer.photoTransitionAnimation == .default {
                    return transitionContext.containerView.convert(toView.frame, from: toView.superview)
                }
                return CGRect(origin: CGPoint(x: fromPhotoRect.minX, y: transitionContext.containerView.frame.maxY), size: fromPhotoRect.size)
            }()
            toViewController.view.frame = transitionContext.finalFrame(for: toViewController)
            transitionContext.containerView.addSubview(toViewController.view)

            transitionContext.containerView.addSubview(fromViewController.view)
            fromViewController.view.alpha = 1

            fromPhoto.frame = fromPhotoRect
            transitionContext.containerView.addSubview(fromPhoto)

            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           delay: 0,
                           options: [.beginFromCurrentState],
                           animations: {
                            fromPhoto.clipsToBounds = true
                            fromPhoto.frame = toRect
                            if let toView = toView {
                                fromPhoto.layer.cornerRadius = toView.layer.cornerRadius
                            }
                            fromViewController.view.alpha = 0
                }, completion: { _ in
                    fromPhoto.removeFromSuperview()
                    let success = !transitionContext.transitionWasCancelled
                    if !success {
                        toViewController.view.removeFromSuperview()
                    }
                    transitionContext.completeTransition(success)
            })
        }
    }
}
