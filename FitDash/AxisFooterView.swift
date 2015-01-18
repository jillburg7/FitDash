//
//  FDAxisLabelView.swift
//  FitDash
//
//  Created by Jillian Burgess on 11/16/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import UIKit
import CoreGraphics

let AxisLabelSeparatorWidth:CGFloat = 0.4
let AxisLabelSeparatorHeight:CGFloat = 3.0
let AxisLabelSectionPadding:CGFloat = 1.0

class AxisFooterView: UIView {
	
	var _topSeparatorView: UIView!
	var leftLabel: UILabel!
	var rightLabel: UILabel!
	
	var sectionCount = 5
	var separatorColor = UIColor.blackColor()
	
	override init(frame aRect: CGRect) {
		super.init(frame: aRect)
		self.backgroundColor = UIColor.clearColor()
		separatorColor = UIColor.blackColor()
		
		_topSeparatorView = UIView()
		_topSeparatorView.backgroundColor = red
		self.addSubview(_topSeparatorView)
		
		leftLabel = UILabel()
		leftLabel.textAlignment = .Left
		leftLabel.adjustsFontSizeToFitWidth = true
		leftLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12.0)
		leftLabel.textColor = navyBlue
		leftLabel.backgroundColor = UIColor.clearColor()
		self.addSubview(leftLabel)
		
		rightLabel = UILabel()
		rightLabel.textAlignment = .Right
		rightLabel.adjustsFontSizeToFitWidth = true
		rightLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12.0)
		rightLabel.textColor = navyBlue
		rightLabel.backgroundColor = UIColor.clearColor()
		self.addSubview(rightLabel)
	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func setLeftLabelText(left: String) {
		leftLabel.text = left
	}
	
	func setRightLabelText(right: String) {
		rightLabel.text = right
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
		
		var xOffset:CGFloat = 0.0
		var yOffset = AxisLabelSectionPadding
		var width = ceil(self.bounds.size.width * 0.5)
		
		leftLabel.frame = CGRectMake(xOffset, yOffset, width, self.bounds.size.height)
		rightLabel.frame = CGRectMake(CGRectGetMaxX(leftLabel.frame), yOffset, width, self.bounds.size.height)

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
