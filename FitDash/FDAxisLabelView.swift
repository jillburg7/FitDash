//
//  FDAxisLabelView.swift
//  FitDash
//
//  Created by Jillian Burgess on 11/16/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import UIKit
import CoreGraphics

let AxisLabelSeparatorWidth:CGFloat = 0.5
let AxisLabelSeparatorHeight:CGFloat = 3.0
let AxisLabelSectionPadding:CGFloat = 1.0

class FDAxisLabelView: UIView {
	
	var leftLabel: UILabel!
	var rightLabel: UILabel!
	
	var sectionCount = 5
	var separatorColor = UIColor.whiteColor()
	
	override init(frame aRect: CGRect) {
		super.init(frame: aRect)
		self.backgroundColor = UIColor.clearColor()
		
		self.leftLabel = UILabel()
		self.leftLabel.textAlignment = .Left
		self.leftLabel.adjustsFontSizeToFitWidth = true
		self.leftLabel.textColor = UIColor.whiteColor()
		self.leftLabel.backgroundColor = UIColor.clearColor()
		self.addSubview(self.leftLabel)
		
		self.rightLabel = UILabel()
		self.rightLabel.textAlignment = .Right
		self.rightLabel.adjustsFontSizeToFitWidth = true
		self.rightLabel.textColor = UIColor.whiteColor()
		self.rightLabel.backgroundColor = UIColor.clearColor()
		self.addSubview(self.rightLabel)
	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func setLeftLabelText(left: String) {
		self.leftLabel.text = left
	}
	
	func setRightLabelText(right: String) {
		self.rightLabel.text = right
	}
	
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
		super.drawRect(rect)
		
        // Drawing code
		var context = UIGraphicsGetCurrentContext()
		CGContextSetStrokeColorWithColor(context, self.separatorColor.CGColor)
		CGContextSetLineWidth(context, 0.5)
		CGContextSetShouldAntialias(context, true)
		
		var xOffset:CGFloat = 0.0
		var yOffset = AxisLabelSeparatorWidth
		var stepLength = ceil(self.bounds.size.width / CGFloat(self.sectionCount - 1))
		
		for var i=0; i<self.sectionCount; i++ {
			CGContextSaveGState(context)
			CGContextMoveToPoint(context, xOffset + AxisLabelSeparatorWidth * 0.5, yOffset)
			CGContextAddLineToPoint(context, xOffset + AxisLabelSeparatorWidth * 0.5, yOffset + AxisLabelSeparatorWidth)
			CGContextStrokePath(context);
			xOffset += stepLength;
			
			CGContextRestoreGState(context);
		}
		
		if self.sectionCount > 1 {
			CGContextSaveGState(context)
			CGContextMoveToPoint(context, self.bounds.size.width - AxisLabelSeparatorWidth * 0.5, yOffset)
			CGContextAddLineToPoint(context, self.bounds.size.width - AxisLabelSeparatorWidth * 0.5, yOffset + AxisLabelSeparatorHeight)
			CGContextStrokePath(context)
			CGContextRestoreGState(context);
		}
    }

	override func layoutSubviews() {
		super.layoutSubviews()
		
		var xOffset:CGFloat = 0.0
		var yOffset = AxisLabelSectionPadding
		var width = ceil(self.bounds.size.width * 0.5)
		
		self.leftLabel.frame = CGRectMake(xOffset, yOffset, width, self.bounds.size.height)
		self.rightLabel.frame = CGRectMake(CGRectGetMaxX(leftLabel.frame), yOffset, width, self.bounds.size.height);

	}
	
	func setSectionCount(sections: Int) {
		self.sectionCount = sections
		self.setNeedsDisplay()
	}
	
	func setFooterSeparatorColor(footerSeparatorColor: UIColor) {
		self.separatorColor = footerSeparatorColor
		self.setNeedsDisplay()
	}
}
