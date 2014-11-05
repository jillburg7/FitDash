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
	
//	@IBAction func refresh(sender: AnyObject) {
//		values.removeAll(keepCapacity: false)
//		dates.removeAll(keepCapacity: false)
////		super.getData()
//	}
	
	@IBOutlet var lineChart: JBLineChartView!
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.lineChart.dataSource = self
		self.lineChart.delegate = self
		view.addSubview(lineChart)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(true)
		self.dates = self.tupleData.0
		self.values = self.tupleData.1
		numberOfPoints = 9
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
	
	
}