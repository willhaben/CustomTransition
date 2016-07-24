//
//  SecondViewController.swift
//  InteractiveTransition
//
//  Created by Yaroslav Arsenkin on 13/07/16.
//  Copyright © 2016 willhaben internet service GmbH & Co KG. All rights reserved.
//

import UIKit

final class SecondViewController: UIViewController {
	
	@IBAction func didTapDismissButton(sender: UIButton) {
		dismissViewControllerAnimated(true, completion: nil)
	}
	
}
