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
	
	var _topSeparatorView: UIView!
	var leftLabel: UILabel!
	var rightLabel: UILabel!
	var padding: CGFloat!
	var sectionCount = 5
	var separatorColor = UIColor.blackColor()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = UIColor.clearColor()
		
		padding = AxisLabelFooterPadding
		
		_topSeparatorView = UIView()
		_topSeparatorView.backgroundColor = red
		self.addSubview(_topSeparatorView)
		separatorColor = UIColor.blackColor()
		
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
	
	// Only override drawRect: if you perform custom drawing.
	// An empty implementation adversely affects performance during animation.
	override func drawRect(rect: CGRect) {
		super.drawRect(rect)
		
		// Drawing code
		var context = UIGraphicsGetCurrentContext()
		CGContextSetStrokeColorWithColor(context, separatorColor.CGColor)
		CGContextSetLineWidth(context, 0.5)
		CGContextSetShouldAntialias(context, true)
		
		var xOffset:CGFloat = 0.0
		var yOffset = AxisLabelSeparatorWidth
		var stepLength = ceil(self.bounds.size.width / CGFloat(sectionCount - 1))
	
		
		for var i=0; i < sectionCount; i++ {
			CGContextSaveGState(context)
			CGContextMoveToPoint(context, xOffset + AxisLabelSeparatorWidth * 0.5, yOffset)
			CGContextAddLineToPoint(context, xOffset + AxisLabelSeparatorWidth * 0.5, yOffset + AxisLabelSeparatorHeight)
			CGContextStrokePath(context);
			xOffset += stepLength;
			
			CGContextRestoreGState(context);
		}
		
		if sectionCount > 1 {
			CGContextSaveGState(context)
			CGContextMoveToPoint(context, self.bounds.size.width - AxisLabelSeparatorWidth * 0.5, yOffset)
			CGContextAddLineToPoint(context, self.bounds.size.width - AxisLabelSeparatorWidth * 0.5, yOffset + AxisLabelSeparatorHeight)
			CGContextStrokePath(context)
			CGContextRestoreGState(context);
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()

		_topSeparatorView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, AxisLabelSeparatorWidth)
		
		var xOffset = self.padding
		var yOffset: CGFloat = 0.0
		var width = ceil(self.bounds.size.width * 0.5) - self.padding
		
		self.leftLabel.frame = CGRectMake(xOffset, yOffset, width, self.bounds.size.height)
		self.rightLabel.frame = CGRectMake(CGRectGetMaxX(leftLabel.frame), yOffset, width, self.bounds.size.height)
	}
	
	
	func setSectionCount(sections: Int) {
		sectionCount = sections
		self.setNeedsDisplay()
	}
	
	func setFooterSeparatorColor(footerSeparatorColor: UIColor) {
		separatorColor = footerSeparatorColor
		_topSeparatorView.backgroundColor = navyBlue
		self.setNeedsDisplay()
	}
}