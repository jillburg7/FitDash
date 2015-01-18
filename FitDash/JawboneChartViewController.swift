//
//  FD_JBViewController.swift
//  FitDash
//
//  Created by Jillian Burgess on 11/1/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import UIKit
import HealthKit

class JawboneChartViewController: BaseViewController, JBLineChartViewDataSource, JBLineChartViewDelegate {
	
	
	@IBOutlet var chartTitle: UILabel!
	@IBOutlet var lineChart: JBLineChartView!
	
	let FDLineChartViewControllerChartPadding:CGFloat = 10.0
	let FDLineChartViewControllerChartFooterHeight:CGFloat = 25.0
	
	@IBAction override func refresh(sender: AnyObject) {
		super.refresh(sender)
		getData()
		displayTodaysStats()
	}
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.chartTitle.text = dataTitle
		
		self.lineChart.dataSource = self
		self.lineChart.delegate = self
		self.view.addSubview(lineChart)
		getData()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(true)
		displayTodaysStats()
		self.lineChart.backgroundColor = turquoise
		var footerView = AxisFooterView(frame: CGRectMake(FDLineChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(FDLineChartViewControllerChartFooterHeight * 0.5), self.view.bounds.size.width - (FDLineChartViewControllerChartPadding * 3), FDLineChartViewControllerChartFooterHeight))
		
//		println(df.shortWeekdaySymbols)
		
		df.dateStyle = .ShortStyle
		df.timeStyle = .ShortStyle
		footerView.leftLabel.text = "\(df.stringFromDate(dates.first!))"
		//footerView.leftLabel.textColor = white
		footerView.rightLabel.text = "\(df.stringFromDate(dates.last!))"
		//footerView.rightLabel.textColor = white
		footerView.sectionCount = values.count
		footerView.setFooterSeparatorColor(navyBlue)
		self.lineChart.footerView = footerView
		self.view.addSubview(self.lineChart)
		self.lineChart.reloadData()
	}
	
	
	// MARK: - JBLineChartViewDataSource
	
	// inform the data source how many lines and vertical data points (for each line) are in the chart
	func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
		return 1
	}
	
	func lineChartView(lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
		return UInt(numberOfPoints)
	}

	// MARK: - JBLineChartViewDelegate
	
	//	inform the delegate of the y-position of each point (automatically normalized across the entire chart)
	//	for each line in the chart
	func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
		if !values.isEmpty {
			return CGFloat(values[Int(horizontalIndex)])
		}
		else {
			return 0.0
		}
	}
	
	// MARK: JBLineChartView Methods
	
	/*
	//area under line  -- always displayed
	func lineChartView(lineChartView: JBLineChartView!, fillColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
		return UIColor.greenColor() //white
	}

	//area under line  -- displayed when touched
	func lineChartView(lineChartView: JBLineChartView!, selectionFillColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
		return UIColor.blueColor()
	}
	*/
	
	// color of the line
	func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
		return white
	}
	
	// vertical selection bar -- color fades to tranparent from the returned color
	func lineChartView(lineChartView: JBLineChartView!, verticalSelectionColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
		return navyBlue
	}
	
	// dots
	
	func lineChartView(lineChartView: JBLineChartView!, showsDotsForLineAtLineIndex lineIndex: UInt) -> Bool {
		return true
	}
	
	// dot size
	func lineChartView(lineChartView: JBLineChartView!, dotRadiusForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
		return 8.0 // default is 3x the line width
	}
	
	// dot color
	func lineChartView(lineChartView: JBLineChartView!, colorForDotAtHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> UIColor! {
		return navyBlue	//default is black (when not selected)
	}
	
	// Bezier line (curved)
	func lineChartView(lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
		return true
	}
	
	func lineChartView(lineChartView: JBLineChartView!, widthForLineAtLineIndex lineIndex: UInt) -> CGFloat {
		return 4.0
	}
	
	// TODO: The touchPoint is especially important as it allows you to add custom elements to your chart during selection events. Refer to the demo project (JBLineChartViewController) to see how a tooltip can be used to display additional information during selection events.
	
	// custom actions for selection events
	func lineChartView(lineChartView: JBLineChartView!, didSelectLineAtIndex lineIndex: UInt, horizontalIndex: UInt) {
		var value = self.values[Int(horizontalIndex)]
		var date = self.dates[Int(horizontalIndex)]
		df.timeStyle = .NoStyle
		self.sleepLabel.text = "value: \(value), date: \(df.stringFromDate(date))"
	}
}