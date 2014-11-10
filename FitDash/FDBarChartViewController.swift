//
//  FDBarChartViewController.swift
//  FitDash
//
//  Created by Jillian Burgess on 11/6/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import UIKit

class FDBarChartViewController: FDBaseViewController, JBBarChartViewDataSource, JBBarChartViewDelegate {
	
	let labelColor = UIColor.whiteColor()
	let theme = UIColor(red: 30.0/255.0, green: 200.0/255.0, blue: 200.0/255.0, alpha: 0.5)
	var colors = UIColor(hue: 45.9/255.0, saturation: 205.0/255.0, brightness: 40.8/255.0, alpha: 1.0)
	
	@IBOutlet var minDate: UILabel!
	@IBOutlet var maxDate: UILabel!
	@IBOutlet var minValue: UILabel!
	@IBOutlet var maxValue: UILabel!
	
	@IBOutlet var barChart: JBBarChartView!
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.barChart.dataSource = self
		self.barChart.delegate = self
		view.addSubview(barChart)
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(true)
		barChart.backgroundColor = theme
		dates = self.tupleData.0
		values = self.tupleData.1
		numberOfPoints = values.count
		self.barChart.reloadData()
	}
	
	// MARK: - JBBarChartViewDataSource
	
	func numberOfBarsInBarChartView(barChartView: JBBarChartView!) -> UInt {
		return UInt(numberOfPoints)
	}
	
	// MARK: - JBBarChartViewDelegate
	
	func barChartView(barChartView: JBBarChartView!, heightForBarViewAtIndex index: UInt) -> CGFloat {
		if !values.isEmpty {
			return CGFloat(values[Int(index)])
		}
		else {
			return 0.0
		}
	}
	
	//MARK: JBBarChartView methods
	
	func barChartView(barChartView: JBBarChartView!, didSelectBarAtIndex index: UInt) {
		var value = self.values[Int(index)]
		var date = self.dates[Int(index)]
		self.minValue.text = "Value: \(value)"
		df.timeStyle = .NoStyle
		self.maxValue.text = "Date: \(df.stringFromDate(date))"
	}
	
	func barChartView(barChartView: JBBarChartView!, didSelectBarAtIndex index: UInt, touchPoint: CGPoint) {
		
	}
	
	func didDeselectBarChartView(barChartView: JBBarChartView!) {
		
	}
	
	
}
