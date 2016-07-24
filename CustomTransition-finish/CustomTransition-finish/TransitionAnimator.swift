//
//  TransitionAnimator.swift
//  InteractiveTransition
//
//  Created by Yaroslav Arsenkin on 16/07/16.
//  Copyright © 2016 willhaben internet service GmbH & Co KG. All rights reserved.
//

import UIKit

@objc enum StackModalTransitionMode: Int {
	case Present, Dismiss
	
	private func isPresenting() -> Bool {
		return self == .Present
	}
}

final class TransitionAnimator: NSObject {
	
	private let kAnimationDuration: NSTimeInterval = 0.6
	private let kAnimationFirstVisibleViewDelay: NSTimeInterval = 0.0
	private let kAnimationSecondVisibleViewDelay: NSTimeInterval = 0.1
	private let kAnimationHarderSpringDamping: CGFloat = 0.7
	private let kAnimationSmootherSpringDamping: CGFloat = 0.85
	private let kAnimationDismissSpringDamping: CGFloat = 1.0
	private let kAnimationSlowerSpringVelocity: CGFloat = 1.0
	private let kAnimationFasterSpringVelocity: CGFloat = 2.5
	private let kTransformViewScale: CGFloat = 0.95;

	private let transitionMode: StackModalTransitionMode
	
	
	// MARK: Lifecycle
	
	init(transitionMode: StackModalTransitionMode) {
		self.transitionMode = transitionMode
		
		super.init()
	}
	
	
}

extension TransitionAnimator: UIViewControllerAnimatedTransitioning {
	
	func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
		return kAnimationDuration
	}
	
	func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
		guard let snapshotToSqueeze = snapshotToSqueeze(withContext: transitionContext) else {
			transitionContext.completeTransition(false)
			return
		}
		guard let viewToSlide = viewToSlide(withContext: transitionContext) else {
			transitionContext.completeTransition(false)
			return
		}
		
		prepareForAnimation(forSqueezeRelatedSnapshot: snapshotToSqueeze, viewToSlide: viewToSlide)
		startAnimation(forSqueezeRelatedSnapshot: snapshotToSqueeze, viewToSlide: viewToSlide, transitionContext: transitionContext)
	}
	
	
}

private extension TransitionAnimator {
	
	func snapshotToSqueeze(withContext transitionContext: UIViewControllerContextTransitioning) -> UIView? {
		let key = transitionMode.isPresenting() ? UITransitionContextFromViewControllerKey : UITransitionContextToViewControllerKey
		guard let viewToSqueeze = transitionContext.viewControllerForKey(key)?.view else { return nil }
		guard let containerView = transitionContext.containerView() else { return nil }
		
		let snapshotToSqueeze = viewToSqueeze.snapshotViewAfterScreenUpdates(false)
		let background = backgroundView(withFrame: viewToSqueeze.frame)
		
		containerView.addSubview(background)
		containerView.addSubview(snapshotToSqueeze)
		
		return snapshotToSqueeze
	}

	func viewToSlide(withContext transitionContext: UIViewControllerContextTransitioning) -> UIView? {
		let key = transitionMode.isPresenting() ? UITransitionContextToViewKey : UITransitionContextFromViewKey
		guard let viewToSlide = transitionContext.viewForKey(key) else { return nil }
		guard let containerView = transitionContext.containerView() else { return nil }
		
		containerView.addSubview(viewToSlide)
		
		return viewToSlide
	}
	
	func prepareForAnimation(forSqueezeRelatedSnapshot snapshot: UIView, viewToSlide: UIView) {
		if transitionMode.isPresenting() {
			viewToSlide.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(viewToSlide.bounds))
		} else {
			snapshot.transform = CGAffineTransformMakeScale(kTransformViewScale, kTransformViewScale)
		}
	}
	
	func startAnimation(forSqueezeRelatedSnapshot snapshot: UIView, viewToSlide: UIView, transitionContext: UIViewControllerContextTransitioning) {
		let completionBlock: (Bool) -> Void = { finished in
			transitionContext.completeTransition(finished)
		}
		
		if transitionMode.isPresenting() {
			startAnimationForPresentingMode(withSnapshotToSqueeze: snapshot, viewToSlide: viewToSlide, completionBlock: completionBlock)
		} else {
			startAnimationForDismissingMode(withSnapshotToSqueeze: snapshot, viewToSlide: viewToSlide, completionBlock: completionBlock)
		}
	}
	
	func startAnimationForPresentingMode(withSnapshotToSqueeze snapshot: UIView, viewToSlide: UIView, completionBlock: (Bool) -> Void) {
		UIView.animateWithDuration(kAnimationDuration,
		                           delay: kAnimationFirstVisibleViewDelay,
		                           usingSpringWithDamping: kAnimationHarderSpringDamping,
		                           initialSpringVelocity: kAnimationSlowerSpringVelocity,
		                           options: .CurveEaseOut,
		                           animations: {
									snapshot.transform = CGAffineTransformMakeScale(self.kTransformViewScale, self.kTransformViewScale)
			}, completion: nil)
		
		UIView.animateWithDuration(kAnimationDuration,
		                           delay: kAnimationSecondVisibleViewDelay,
		                           usingSpringWithDamping: kAnimationSmootherSpringDamping,
		                           initialSpringVelocity: kAnimationFasterSpringVelocity,
		                           options: .CurveEaseOut,
		                           animations: {
									viewToSlide.transform = CGAffineTransformIdentity
			}, completion: completionBlock)
	}
	
	func startAnimationForDismissingMode(withSnapshotToSqueeze snapshot: UIView, viewToSlide: UIView, completionBlock: (Bool) -> Void) {
		UIView.animateWithDuration(kAnimationDuration,
		                           delay: kAnimationFirstVisibleViewDelay,
		                           usingSpringWithDamping: kAnimationDismissSpringDamping,
		                           initialSpringVelocity: kAnimationSlowerSpringVelocity,
		                           options: .CurveEaseIn,
		                           animations: {
									viewToSlide.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(viewToSlide.bounds))
			}, completion: nil)
		
		UIView.animateWithDuration(kAnimationDuration,
		                           delay: kAnimationSecondVisibleViewDelay,
		                           usingSpringWithDamping: kAnimationDismissSpringDamping,
		                           initialSpringVelocity: kAnimationSlowerSpringVelocity,
		                           options: .CurveEaseIn,
		                           animations: {
									snapshot.transform = CGAffineTransformIdentity
			}, completion: completionBlock)
	}

	func backgroundView(withFrame frame: CGRect) -> UIView {
		let background = UIView(frame: frame)
		background.backgroundColor = .whiteColor()
		let backgroundOverlay = UIView(frame: background.frame)
		backgroundOverlay.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
		background.addSubview(backgroundOverlay)
		
		return background
	}
	
	
}

