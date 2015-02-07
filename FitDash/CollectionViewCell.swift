//
//  CollectionViewCell.swift
//  FitDash
//
//  Created by Jillian Burgess on 11/30/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var label: UILabel!
	var baseColor: UIColor!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.selected = false
	}
 
	override var selected : Bool {
		didSet {
			self.backgroundColor = selected ? lightTurquoise : baseColor
		}
	}
	
	func setBaseColor(color: UIColor) {
		baseColor = color
		self.backgroundColor = color
	}
	
}
