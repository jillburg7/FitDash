//
//  FD_JBViewController.swift
//  FitDash
//
//  Created by Jillian Burgess on 11/1/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import UIKit
import HealthKit

class FDJawboneChartViewController: FDBaseViewController, JBLineChartViewDataSource, JBLineChartViewDelegate {
	
	let labelColor = UIColor.whiteColor()
	let theme = UIColor(red: 30.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 0.5)
	var colors = UIColor(hue: 45.9/255.0, saturation: 205.0/255.0, brightness: 40.8/255.0, alpha: 1.0)
	
	@IBOutlet var lineChart: JBLineChartView!
	
	@IBAction override func refresh(sender: AnyObject) {
		super.refresh(sender)
		getData()
		displayTodaysStats()
	}
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.lineChart.dataSource = self
		self.lineChart.delegate = self
		view.addSubview(lineChart)
		getData()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(true)
		displayTodaysStats()
		self.lineChart.backgroundColor = theme
		dates = self.tupleData.0
		values = self.tupleData.1
		numberOfPoints = values.count
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
	
	func lineChartView(lineChartView: JBLineChartView!, fillColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
		return labelColor
	}
	
	func lineChartView(lineChartView: JBLineChartView!, showsDotsForLineAtLineIndex lineIndex: UInt) -> Bool {
		return true
	}
	
	func lineChartView(lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
		return true
	}
	
	func lineChartView(lineChartView: JBLineChartView!, verticalSelectionColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
		return colors
	}
	
	func lineChartView(lineChartView: JBLineChartView!, selectionFillColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
		return UIColor.clearColor()
	}
	
	func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
		return theme
	}
	
	func lineChartView(lineChartView: JBLineChartView!, didSelectLineAtIndex lineIndex: UInt, horizontalIndex: UInt) {
		var value = self.values[Int(horizontalIndex)]
		var date = self.dates[Int(horizontalIndex)]
		df.timeStyle = .NoStyle
		self.sleepLabel.text = "value: \(value), date: \(df.stringFromDate(date))"
	}

}