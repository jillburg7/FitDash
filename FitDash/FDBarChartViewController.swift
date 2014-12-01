//
//  FDBarChartViewController.swift
//  FitDash
//
//  Created by Jillian Burgess on 11/6/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import UIKit

class FDBarChartViewController: FDBaseViewController, JBBarChartViewDataSource, JBBarChartViewDelegate {
	
	@IBOutlet var chartTitle: UILabel!
	@IBOutlet var minDate: UILabel!
	@IBOutlet var maxDate: UILabel!
	@IBOutlet var minValue: UILabel!
	@IBOutlet var maxValue: UILabel!
	
	@IBOutlet var barChart: JBBarChartView!
	
	let FDBarChartViewControllerChartPadding: CGFloat = 10.0
	let FDBarChartViewControllerChartFooterPadding: CGFloat = 5.0
	let FDBarChartViewControllerChartFooterHeight: CGFloat = 25.0
	
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
		super.viewDidAppear(true)
		self.barChart.backgroundColor = lightTurquoise
		self.barChart.minimumValue = 0
		
		var footerView = FDBarChartFooterView(frame: CGRectMake(FDBarChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(FDBarChartViewControllerChartFooterHeight * 0.5), self.view.bounds.size.width - (FDBarChartViewControllerChartPadding * 2), FDBarChartViewControllerChartFooterHeight))
		
		footerView.padding = FDBarChartViewControllerChartFooterPadding
		df.dateStyle = .ShortStyle
		df.timeStyle = .ShortStyle
		footerView.leftLabel.text = "\(df.stringFromDate(dates.first!))"
		//footerView.leftLabel.textColor = white
		footerView.rightLabel.text = "\(df.stringFromDate(dates.last!))"
		//footerView.rightLabel.textColor = white
		self.barChart.footerView = footerView
		self.view.addSubview(self.barChart)
		
		self.barChart.reloadData()
	}
	
	
	// MARK: - JBBarChartViewDataSource
	
	func numberOfBarsInBarChartView(barChartView: JBBarChartView!) -> UInt {
		return UInt(numberOfPoints)
	}
	
	// MARK: - JBBarChartViewDelegate
	
	func barChartView(barChartView: JBBarChartView!, heightForBarViewAtIndex index: UInt) -> CGFloat {
		if !self.values.isEmpty {
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
		self.minDate.text = ""
		self.maxDate.text = ""
		df.dateStyle = .ShortStyle
		df.timeStyle = .ShortStyle
		self.maxValue.text = "Date: \(df.stringFromDate(date))"
	}
	
	func barChartView(barChartView: JBBarChartView!, didSelectBarAtIndex index: UInt, touchPoint: CGPoint) {
//		barChartView.footerView
	}
	
	func didDeselectBarChartView(barChartView: JBBarChartView!) {
		
	}
	
}
