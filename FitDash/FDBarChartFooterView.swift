//
//  FDBarChartFooterView.swift
//  FitDash
//
//  Created by Jillian Burgess on 12/1/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

let AxisLabelFooterPadding: CGFloat = 4.0

class FDBarChartFooterView: UIView {
	
	var leftLabel: UILabel!
	var rightLabel: UILabel!
	var padding: CGFloat!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = UIColor.clearColor()
		
		padding = AxisLabelFooterPadding
		
		leftLabel = UILabel()
		leftLabel.adjustsFontSizeToFitWidth = true
		leftLabel.font = UIFont(name: "HelveticaNeue", size: 12.0)
		leftLabel.textAlignment = .Left
//		leftLabel.shadowColor = UIColor.blackColor()
//		leftLabel.shadowOffset = CGSizeMake(0, 1)
		leftLabel.textColor = navyBlue
		leftLabel.backgroundColor = UIColor.clearColor()
		self.addSubview(leftLabel)
		
		rightLabel = UILabel()
		rightLabel.adjustsFontSizeToFitWidth = true
		rightLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12.0)
		rightLabel.textAlignment = .Right
//		rightLabel.shadowColor = UIColor.blackColor()
//		rightLabel.shadowOffset = CGSizeMake(0, 1)
		rightLabel.textColor = navyBlue
		rightLabel.backgroundColor = UIColor.clearColor()
		self.addSubview(rightLabel)

	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()

		var xOffset = self.padding
		var yOffset: CGFloat = 0.0
		var width = ceil(self.bounds.size.width * 0.5) - self.padding
		
		self.leftLabel.frame = CGRectMake(xOffset, yOffset, width, self.bounds.size.height)
		self.rightLabel.frame = CGRectMake(CGRectGetMaxX(leftLabel.frame), yOffset, width, self.bounds.size.height)
	}
	
}