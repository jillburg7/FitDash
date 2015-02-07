//
//  TableViewController.swift
//  FitDash
//
//  Created by Jillian Burgess on 11/1/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import UIKit
import HealthKit

var weeklyOverview: (name: String, dates: [NSDate], values: [Double]) = ("", [],[])
var dailyOverview: (name: String, dates: [NSDate], values: [Double]) = ("", [],[])

class TableViewController: UITableViewController { //, UITableViewDelegate, UITableViewDataSource {
	
	var items = ["BEMLineGraph", "JawboneChart", "Today's Hourly Statistics", "This Week's Daily Statistics", "workouts", "Profile"]	
	
	let healthManager:HealthManager = HealthManager()
	
	
	var healthStore: HKHealthStore?
	var stepSamples = [HKQuantitySample]()
	
	var values: [Double] = []
	var dates: [NSDate] = []
	
	var midnight = NSDate()
	var startTime24HourData = NSDate()
	var now = NSDate()
	var numberOfPoints:Int = 0
	var ready = false
	var dataDescription = ""
	
	func authorizeHealthKit() {
		healthManager.authorizeHealthKit {
			(authorized,  error) -> Void in
			if authorized {
				println("HealthKit authorization received.")
			} else {
				println("HealthKit authorization denied!")
				if error != nil {
					println("\(error)")
				}
			}
		}
	}
	
	// MARK: init
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		createAndPropagateHealthStore()
	}
	
	private func createAndPropagateHealthStore() {
		if self.healthStore == nil {
			self.healthStore = HKHealthStore()
		}
	}
	// MARK: - Overrides
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		authorizeHealthKit()
//		loader.hidesWhenStopped = true
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
//		self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
	}
	
	// MARK: - TableView

	/*
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.items.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		//		var cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
		let cell = tableView.dequeueReusableCellWithIdentifier("StatisticsCell", forIndexPath: indexPath)
			as UITableViewCell
		
		cell.textLabel?.text = self.items[indexPath.row]
		
		return cell
	}
	
	func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
		println("You selected cell #\(indexPath.row)!")
		self.performSegueWithIdentifier(segueID[indexPath.row], sender: tableView)
	}≥
*/
 
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
		if segue.identifier != nil {
			if segue.identifier == "hourlyCollectionView" {
				let collectionview = segue.destinationViewController as CollectionViewController
				collectionview.title = "Today's Hourly Statistics"
				collectionview.healthManager = healthManager
				collectionview.setup("day")
			
			} else if segue.identifier == "weeklyCollectionView" {
				let collectionview = segue.destinationViewController as CollectionViewController
				collectionview.title = "This Week's Daily Statistics"
				collectionview.healthManager = healthManager
				collectionview.setup("week")
			} else if segue.identifier == "profileSegue" {
				let workoutViewController = segue.destinationViewController as ProfileViewController
				workoutViewController.healthManager = healthManager
			} else if segue.identifier == "workoutSegue" {
				let workoutViewController = segue.destinationViewController as WorkoutsTableViewController
				workoutViewController.healthManager = healthManager
			} else if segue.identifier == "statisticsSegue" {
				
			} else {
				var chartDetails = segue.destinationViewController as BaseViewController
				
				if segue.identifier == "bemGraphView" {
					println("TODO: BEMSimpleGraphViewController")
					chartDetails = segue.destinationViewController as BEMSimpleGraphViewController
				} else if segue.identifier == "jawboneLineChart" {
					println("TODO: JawboneChartViewController")
					chartDetails = segue.destinationViewController as JawboneChartViewController
				}
				dataDescription = dailyOverview.name
				chartDetails.tupleData = ([NSDate(), NSDate()], [0.0, 0.0])
				
				chartDetails.title = segue.identifier
				chartDetails.healthStore = self.healthStore
				chartDetails.dataTitle = dataDescription
			}
		}
	}
	
}