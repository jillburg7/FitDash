//
//  BarChartViewController.swift
//  FitDash
//
//  Created by Jillian Burgess on 11/6/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import UIKit

class BarChartViewController: BaseViewController, JBBarChartViewDataSource, JBBarChartViewDelegate {
	
	@IBOutlet var chartTitle: UILabel!
	@IBOutlet var minDate: UILabel!
	@IBOutlet var maxDate: UILabel!
	@IBOutlet var minValue: UILabel!
	@IBOutlet var maxValue: UILabel!
	
	@IBOutlet var barChart: JBBarChartView!
	var footer: BarChartFooterView?
	
	let FDBarChartViewControllerChartPadding: CGFloat = 10.0
	let FDBarChartViewControllerChartFooterPadding: CGFloat = 5.0
	let FDBarChartViewControllerChartFooterHeight: CGFloat = 25.0
	
	
	@IBAction override func refresh(sender: AnyObject) {
		self.barChart.reloadData()
	}
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.chartTitle.textAlignment = .Center
		self.chartTitle.text = dataTitle
		
		self.barChart.dataSource = self
		self.barChart.delegate = self
		self.view.addSubview(barChart)
		self.minValue.text = ""
		self.maxValue.text = ""
		self.minDate.text = ""
		self.maxDate.text = ""
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.barChart.backgroundColor = lightTurquoise
		self.barChart.minimumValue = 0
		
		footer = BarChartFooterView(frame: CGRectMake(FDBarChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(FDBarChartViewControllerChartFooterHeight * 0.5), self.view.bounds.size.width - (FDBarChartViewControllerChartPadding * 2), FDBarChartViewControllerChartFooterHeight))
		
		footer!.padding = FDBarChartViewControllerChartFooterPadding
		df.dateStyle = .ShortStyle
		df.timeStyle = .ShortStyle
		
		footer!.sectionCount = values.count - 2
		footer!.setFooterSeparatorColor(navyBlue)
		
		self.barChart.footerView = footer!
		self.view.addSubview(self.barChart)
//		updateFooterTextLabels(footer!)
		self.barChart.reloadData()
	}
	
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.barChart.reloadData()
	}
	
	
	func updateFooterTextLabels(footer: BarChartFooterView) {
		footer.leftLabel.text = "\(df.stringFromDate(tupleData.0.first!))"
		footer.rightLabel.text = "\(df.stringFromDate(tupleData.0.last!))"
	}
	
	
	// MARK: - JBBarChartViewDataSource
	
	// number of values/bars to plot
	func numberOfBarsInBarChartView(barChartView: JBBarChartView!) -> UInt {
		return UInt(numberOfPoints)
	}
	
	// MARK: - JBBarChartViewDelegate
	
	//value of bar, also the height
	func barChartView(barChartView: JBBarChartView!, heightForBarViewAtIndex index: UInt) -> CGFloat {
		if !values.isEmpty {
			return CGFloat(values[Int(index)])
		}
		else {
			return 0.0
		}
	}
	
	//MARK: JBBarChartView methods
	
	// a bar is selected (user touched)
	func barChartView(barChartView: JBBarChartView!, didSelectBarAtIndex index: UInt) {
		var value = self.values[Int(index)]
		var date = self.dates[Int(index)]
//		self.minValue.text = "Value: \(value)"
		var valueString = String(format:"%.2f", value)
		self.minValue.text = "Value: \(valueString)"
		self.minDate.text = ""
		self.maxDate.text = ""
		df.dateStyle = .ShortStyle
		df.timeStyle = .ShortStyle
		self.maxValue.text = "Date: \(df.stringFromDate(date))"
	}
	
	//touchPoint is where the user touched on the bar that was selected.
	func barChartView(barChartView: JBBarChartView!, didSelectBarAtIndex index: UInt, touchPoint: CGPoint) {
//		println("user touchPoint: (\(touchPoint.x), \(touchPoint.y))")
	}
	
	func didDeselectBarChartView(barChartView: JBBarChartView!) {
		
	}
	
}
