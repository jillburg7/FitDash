//
//  FDBaseViewController.swift
//  FitDash
//
//  Created by Jillian Burgess on 11/2/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import UIKit
import HealthKit

class FDBaseViewController: UIViewController {
	
	var healthStore: HKHealthStore?
	var tupleData: ([NSDate], [Double]) = ([],[])
	
	var steps = 0.0
	var distance = 0.0
	var flightsClimbed = 0.0
	var sleeps = 0.0
	
	var values: [Double] = []
	var dates: [NSDate] = []

	var midnight = NSDate()
	var startTime24HourData = NSDate()
	var now = NSDate()
	var numberOfPoints:Int = 0
	
	let df = NSDateFormatter()
	
	@IBOutlet var ageLabel: UILabel!
	@IBOutlet var dataRefreshLabel: UILabel!
	@IBOutlet var stepsLabel: UILabel!
	@IBOutlet var distanceLabel: UILabel!
	@IBOutlet var flightsClimbedLabel: UILabel!
	@IBOutlet var sleepLabel: UILabel!
	
	@IBAction func refresh(sender: AnyObject) {
		//update the refresh time
		df.dateStyle = .ShortStyle
		df.timeStyle = .MediumStyle
		self.now = NSDate()
		self.dataRefreshLabel.text = "Updated: \(df.stringFromDate(self.now))"
	}
	
	// MARK: - Overrides
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		df.dateStyle = .ShortStyle
		df.timeStyle = .MediumStyle
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		self.getTodaysCumulativeSteps()
		self.getTodaysCumulativeDistance()
		self.getTodaysFlightsClimbed()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.dates = self.tupleData.0
		self.values = self.tupleData.1
		self.numberOfPoints = values.count
		println("numberOfPoints is currently @ \(numberOfPoints)")
		//update the refresh time
		self.dataRefreshLabel.text = "Updated: \(df.stringFromDate(self.now))"
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
	*/
	
	func displayTodaysStats() {
		//update the refresh time
		self.dataRefreshLabel.text = "Updated: \(df.stringFromDate(self.now))"
		
		self.stepsLabel.text = "Step Count:  \(self.steps) steps"
		self.flightsClimbedLabel.text = "Flights Climbed: \(self.flightsClimbed) floors"
		var distanceString = String(format:"%.2f", self.distance)
		self.distanceLabel.text = "Distance: \(distanceString) miles"
	}
	
	// MARK: - Read HealthKit data
	
	func getData() {
		println("please wait while I update the data you requested...")
		self.now = NSDate()
		self.midnight = NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: now, options: nil)!
		self.startTime24HourData = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: -1, toDate: now, options: nil)!
		self.getTodaysCumulativeSteps()
		self.getTodaysCumulativeDistance()
		self.getTodaysFlightsClimbed()
	}
	
	// MARK: - Today's Stats
	
	// gets the cumlative steps taken over the past 24hours
	func getTodaysCumulativeSteps() {
		let stepsType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
		let predicate = HKQuery.predicateForSamplesWithStartDate(midnight, endDate: now, options: .None)
		
		let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate,
			options: .CumulativeSum) {
				(query, results, error) in
				if results == nil {
					println("There was an error running the query: \(error)")
				}
				
				dispatch_async(dispatch_get_main_queue()) {
					if let quantity = results.sumQuantity() {
						let unit = HKUnit.countUnit()
						self.steps = quantity.doubleValueForUnit(unit)
					}
				}
		}
		self.healthStore?.executeQuery(query)
	}
	
	func getTodaysCumulativeDistance() {
		let distanceType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
		let predicate = HKQuery.predicateForSamplesWithStartDate(midnight, endDate: now, options: .None)
		
		let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate,
			options: .CumulativeSum) {
				(query, results, error) in
				if results == nil {
					println("There was an error running the query: \(error)")
				}
				
				dispatch_async(dispatch_get_main_queue()) {
					
					if let quantity = results.sumQuantity() {
						let unit = HKUnit.mileUnit()
						self.distance = quantity.doubleValueForUnit(unit)
					}
				}
		}
		self.healthStore?.executeQuery(query)
	}
	
	func getTodaysFlightsClimbed() {
		let flightsClimbedType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)
		let predicate = HKQuery.predicateForSamplesWithStartDate(midnight, endDate: now, options: .None)
		
		let query = HKStatisticsQuery(quantityType: flightsClimbedType, quantitySamplePredicate: predicate,
			options: .CumulativeSum) {
				(query, results, error) in
				if results == nil {
					println("There was an error running the query: \(error)")
				}
				
				dispatch_async(dispatch_get_main_queue()) {
					
					if let quantity = results.sumQuantity() {
						let unit = HKUnit.countUnit()
						self.flightsClimbed = quantity.doubleValueForUnit(unit)
					}
				}
		}
		self.healthStore?.executeQuery(query)
	}
	
	func getSleepAnalysis() {
		//sleeps
	}
}
