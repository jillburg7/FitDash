//
//  ViewController.swift
//  FitDash
//
//  Created by Jillian Burgess on 10/12/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import UIKit
import HealthKit

class FDBEMSimpleGraphViewController: FDBaseViewController, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate {
	
	let labelColor = UIColor.whiteColor()
	
//	@IBOutlet var ageLabel: UILabel!
//	@IBOutlet var dataRefreshLabel: UILabel!
//	@IBOutlet var stepsLabel: UILabel!
//	@IBOutlet var distanceLabel: UILabel!
//	@IBOutlet var flightsClimbedLabel: UILabel!
//	@IBOutlet var sleepLabel: UILabel!
//	
	@IBAction override func refresh(sender: AnyObject) {
		//update the refresh time
		self.dataRefreshLabel.text = "Updated: \(df.stringFromDate(self.now))"
		getData()
		displayTodaysStats()
	}

	@IBOutlet var graphView: BEMSimpleLineGraphView!
	
	// MARK: - Overrides
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.dates = self.tupleData.0
		self.values = self.tupleData.1
		numberOfPoints = 9
		self.graphView.reloadGraph()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		displayTodaysStats()
		// Do any additional setup after loading the view, typically from a nib.
		self.graphView.enableBezierCurve = true
		self.graphView.enableYAxisLabel = true
		self.graphView.autoScaleYAxis = true
		self.graphView.alwaysDisplayDots = true
		self.graphView.alphaLine = 1.0
		self.graphView.colorXaxisLabel = labelColor
		self.graphView.colorYaxisLabel = labelColor
		self.graphView.colorTouchInputLine = UIColor.whiteColor()
		self.graphView.alphaTouchInputLine = 1.0
		//		self.graphView.widthLine = 3.0;
		self.graphView.enableTouchReport = true
		self.graphView.enablePopUpReport = true
		self.graphView.enableReferenceAxisLines = true
		self.graphView.enableReferenceAxisFrame = true
		self.graphView.reloadGraph()
	}
	
	// MARK: - BEMSimpleLineGraphDataSource
	//	Required Data Source Methods
	
	// REQUIRED FUNCTION:
	// Specify the number of points on the graph. BEMSimpleLineGraph will pass the
	//	graph of interest in the graph parameter. The line graph gets the value
	//	returned by this method from its data source and caches it.
	// RETURNS: Number of points in the graph.
	func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView!) -> Int {
		return numberOfPoints
	}
	
	// REQUIRED FUNCTION:
	// Informs the position of each point on the Y-Axis at a given index. This method is
	//	called for every point specified in the numberOfPointsInLineGraph: method. The
	//	parameter index is the position from left to right of the point on the X-Axis.
	// RETURNS: The value of the point on the Y-Axis for the index.
	func lineGraph(graph: BEMSimpleLineGraphView!, valueForPointAtIndex index: Int) -> CGFloat {
		if !values.isEmpty {
			return CGFloat(values[index])
		}
		else {
			return 0.0
		}
	}
	
	// MARK: BEMSimpleLineGraph Methods
	
	func lineGraph(graph: BEMSimpleLineGraphView!, labelOnXAxisForIndex index: Int) -> String! {
		if !dates.isEmpty {      //(index % 2) == 1 &&
			let df = NSDateFormatter()
			df.dateStyle = .ShortStyle
			return df.stringFromDate(dates[index])
		} else { return "" }
	}
	
	func lineGraphDidBeginLoading(graph: BEMSimpleLineGraphView!) {
		println("-----------------------")
		println("graph did begin loading")
	}
	
	func lineGraphDidFinishLoading(graph: BEMSimpleLineGraphView!) {
		println("dates: \(self.graphView.graphValuesForXAxis())")
		println("values: \(self.graphView.graphValuesForDataPoints())")
		println("graph did finish loading")
		println("------------------------")
	}
	
}

