//
//  FDTableViewController.swift
//  FitDash
//
//  Created by Jillian Burgess on 11/1/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import UIKit
import HealthKit

//UICollectionViewController
class FDTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet var tableView: UITableView!
	var items = ["BEMLineGraph", "JawboneChart"]
	var segueID = ["bemGraphView", "jawboneLineChart"]
	
	// MARK: - Overrides
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
	}
	
	// MARK: - TableView
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.items.count;
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
		
		cell.textLabel.text = self.items[indexPath.row]
		
		return cell
	}
	
	func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
		println("You selected cell #\(indexPath.row)!")
		self.performSegueWithIdentifier(segueID[indexPath.row], sender: tableView)
	}
 
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
		if segue.identifier == "bemGraphView" {
			let indexPath = self.tableView.indexPathForSelectedRow()!
			let destinationTitle = self.items[indexPath.row]
			let chartDetails = segue.destinationViewController as FDBEMSimpleGraphViewController
			chartDetails.title = destinationTitle
		} else if segue.identifier == "jawboneLineChart" {
			let indexPath = self.tableView.indexPathForSelectedRow()!
			let destinationTitle = self.items[indexPath.row]
			let chartDetails = segue.destinationViewController as FDJawboneChartViewController
			chartDetails.title = destinationTitle
		}
		
		//		var healthItems: [String: Double] = ["steps":  steps, "distance": distance, "flightsClimbed": flightsClimbed]
		//		var weeklySteps: [NSDate: Double] = [dates: values]
		//		chartView.chartData = weeklySteps
		//		chartView.dailyStats = healthItems
		//		}
	}
}