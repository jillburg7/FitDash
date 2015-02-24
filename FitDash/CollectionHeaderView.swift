//
//  CollectionHeaderView.swift
//  FitDash
//
//  Created by Jillian Burgess on 11/30/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import UIKit

class CollectionHeaderView: UICollectionReusableView {
        
	@IBAction func previous(sender: UIButton) {
		// TODO: Previous button press action
		println("Pressed previous")
	}
	@IBAction func next(sender: UIButton) {
		// TODO: Next button press action
		println("Pressed next")
	}
	@IBOutlet weak var headerLabel: UILabel!
	
}
