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
	@IBOutlet weak var source: UILabel!
	@IBOutlet var minDate: UILabel!
	@IBOutlet var maxDate: UILabel!
	@IBOutlet var minValue: UILabel!
	@IBOutlet var maxValue: UILabel!
	var selectedValue = UILabel()
	
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
		self.source.text = "Source: com.Apple.Health..."
		
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
		updateFooterTextLabels(footer!)
		displayStatistics()
		self.barChart.reloadData()
	}
	
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.barChart.reloadData()
		selectedValue.contentMode = .ScaleAspectFill
		selectedValue.frame = CGRect(x: 0, y: 130, width: 100, height: 20)
		selectedValue.text = ""
		self.view.addSubview(selectedValue)
	}
	
	
	func updateFooterTextLabels(footer: BarChartFooterView) {
		if !dates.isEmpty {
			footer.leftLabel.text = "\(df.stringFromDate(dates.first!))"
			footer.rightLabel.text = "\(df.stringFromDate(dates.last!))"
		}
	}
	
	func displayStatistics() {
		if !values.isEmpty {
			self.minValue.text = "Min: \(barChart.minimumValue)"
			self.maxValue.text = "Max: \(barChart.maximumValue)"
//			self.minDate.text = "Date: \(barChart.m)"
//			self.maxDate.text = "Date: \()"
		}
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
	
	var selection: CGPoint?
	
	// a bar is selected (user touched)
	func barChartView(barChartView: JBBarChartView!, didSelectBarAtIndex index: UInt) {
		var value = self.values[Int(index)]
		var valueString = String(format:"%.2f", value)
		self.selectedValue.text = "\(valueString)"
		
		if selection != nil {
			self.selectedValue.frame = CGRect(x: selection!.x, y: CGFloat(130), width: CGFloat(100), height: CGFloat(20))
		}
	}
	
	//touchPoint is where the user touched on the bar that was selected.
	func barChartView(barChartView: JBBarChartView!, didSelectBarAtIndex index: UInt, touchPoint: CGPoint) {
		selection = touchPoint
	}
}
