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
	@IBOutlet var selectedValue: UILabel!
	@IBOutlet weak var selectedDateForValue: UILabel!
	var min: CGFloat?
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
		self.source.text = "Source: com.Apple.Health"
		
		self.barChart.dataSource = self
		self.barChart.delegate = self
		self.view.addSubview(barChart)
		self.minValue.text = ""
		self.maxValue.text = ""
		self.minDate.text = ""
		self.maxDate.text = ""
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.barChart.reloadData()
		selectedValue.text = ""
		selectedDateForValue.text = ""
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.barChart.backgroundColor = lightTurquoise
		
		footer = BarChartFooterView(frame: CGRectMake(FDBarChartViewControllerChartPadding, ceil(self.view.bounds.size.height * 0.5) - ceil(FDBarChartViewControllerChartFooterHeight * 0.5), self.view.bounds.size.width - (FDBarChartViewControllerChartPadding * 2), FDBarChartViewControllerChartFooterHeight))
		
		footer!.padding = FDBarChartViewControllerChartFooterPadding
		df.dateStyle = .ShortStyle
		df.timeStyle = .ShortStyle
		
		footer!.sectionCount = Int(numberOfBarsInBarChartView(barChart) + 1)
		footer!.setFooterSeparatorColor(navyBlue)
		
		self.barChart.footerView = footer!
		self.view.addSubview(self.barChart)
		updateFooterTextLabels(footer!)
		self.barChart.reloadData()
		
		min = barChart.minimumValue
		barChart.minimumValue = 0
		
		displayStatistics()
	}
	
	
	
	func updateFooterTextLabels(footer: BarChartFooterView) {
		if !dates.isEmpty {
			footer.leftLabel.text = "\(df.stringFromDate(dates.first!))"
			footer.rightLabel.text = "\(df.stringFromDate(dates.last!))"
		}
	}
	
	func displayStatistics() {
		if !values.isEmpty {
			barChart.reloadData()
			self.maxValue.text = "Max: " + String(format:"%.2f", barChart.maximumValue) //\(barChart.maximumValue)"
			self.minValue.text = "Min: " + String(format:"%.2f", min!) // \(barChart.minimumValue)"
			var i = chartTitle.text?.startIndex.successor()
			
			if let format = chartTitle.text?.substringToIndex(i!) {
				if format == "D" {
					df.dateStyle = .NoStyle
					df.timeStyle = .ShortStyle
				} else {
					df.timeStyle = .NoStyle
					df.dateStyle = .ShortStyle
				}
			}
			
			for var i=0; i<values.count; i++ {
				println("\(CGFloat(values[i])) == \(barChart.minimumValue)  ?")
				println("\(CGFloat(values[i])) == \(barChart.maximumValue)  ?")
				println()
				if CGFloat(values[i]) == barChart.minimumValue {
					minDate.text = "Date: \(df.stringFromDate(dates[i]))"
				} else if CGFloat(values[i]) == barChart.maximumValue {
					maxDate.text = "Date: \(df.stringFromDate(dates[i]))"
				}
			}
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
	
	//touchPoint is where the user touched on the bar that was selected.
	func barChartView(barChartView: JBBarChartView!, didSelectBarAtIndex index: UInt, touchPoint: CGPoint) {
		var selection = touchPoint.x
		var value = values[Int(index)]
		var valueString = String(format:"%.2f", value)
		selectedValue.text = "\(valueString)"
		
		selectedDateForValue.text = "\(df.stringFromDate(dates[Int(index)]))"
		
		view.layoutIfNeeded()
		
		if (selectedValue.frame.width + selection) > view.frame.width {
			selectedValue.center.x = selection - (selectedValue.frame.width/4)
			selectedDateForValue.center.x = selection - (selectedValue.frame.width/4)
		}
		else if selectedDateForValue.frame.origin.x < 0 {
			selectedDateForValue.frame.origin.x = selection
			selectedValue.frame.origin.x = selection
		}
		else {
			selectedValue.center.x = selection
			selectedDateForValue.center.x = selection
		}
	}
}
