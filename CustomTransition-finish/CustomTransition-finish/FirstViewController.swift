//
//  FirstViewController.swift
//  InteractiveTransition
//
//  Created by Yaroslav Arsenkin on 13/07/16.
//  Copyright © 2016 willhaben internet service GmbH & Co KG. All rights reserved.
//

import UIKit

final class FirstViewController: UIViewController {

	@IBAction func didTapPresentButton(sender: UIButton) {
		guard let secondVC = storyboard?.instantiateViewControllerWithIdentifier(String(SecondViewController.self)) else { return }
		secondVC.modalPresentationStyle = .Custom
		secondVC.transitioningDelegate = self
		presentViewController(secondVC, animated: true, completion: nil)
	}

}

extension FirstViewController: UIViewControllerTransitioningDelegate {
	
	func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return TransitionAnimator(transitionMode: .Present)
	}
	
	func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return TransitionAnimator(transitionMode: .Dismiss)
	}
	
	
}
