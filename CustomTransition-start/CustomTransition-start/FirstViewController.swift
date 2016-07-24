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
		presentViewController(secondVC, animated: true, completion: nil)
	}

}
