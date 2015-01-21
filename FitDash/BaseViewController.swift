//
//  BaseViewController.swift
//  FitDash
//
//  Created by Jillian Burgess on 11/2/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import UIKit
import HealthKit

class BaseViewController: UIViewController {
	
	// MARK: properties
	
	
	var healthStore: HKHealthStore?
	
//	    var tupleData: ([NSDate], [Double]) = ([],[])
	var tupleData = ([NSDate](), [Double]())
	
	var steps = 0.0
	var distance = 0.0
	var flightsClimbed = 0.0
	var sleeps = "n/a"
	
	var values: [Double] = []
	var dates: [NSDate] = []
	
	var midnight = NSDate()
	var startTime24HourData = NSDate()
	var now = NSDate()
	var numberOfPoints:Int = 0
	
	let df = NSDateFormatter()
	var dataTitle = ""
	
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
		self.sleepLabel.text = "Sleep: \(sleeps)"
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
		self.getSleepAnalysis()
		self.getTodaysActiveCalories()
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
	
	func getTodaysActiveCalories() {
		let activeCal = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)
		let threeDaysAgo = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: -7, toDate: now, options: nil)!
		let predicate = HKQuery.predicateForSamplesWithStartDate(threeDaysAgo, endDate: now, options: .StrictStartDate)
		
		let query = HKStatisticsQuery(quantityType: activeCal, quantitySamplePredicate: predicate, options: .CumulativeSum) {
				(query, results, error) in
			if results == nil {
				println("There was an error running the query: \(error)")
			}
			
			dispatch_async(dispatch_get_main_queue()) {
				println("Sample Description: \(results.description)")
//				println("Active Calories Source: \(results.sources)")
				
				if let quantity = results.sumQuantity() {
					let unit = HKUnit.calorieUnit()
					println("Active Calories: \(quantity.doubleValueForUnit(unit))")
				}
			}
		}
		self.healthStore?.executeQuery(query)
	}
	
	//By comparing the start and end times of these samples, apps can calculate a number of secondary statistics: 
	//	- the amount of time it took for the user to fall asleep,
	//	- the percentage of time in bed that the user actually spent sleeping,
	//	- the number of times the user woke while in bed, and
	//	- the total amount of time spent both in bed and asleep.
	func getSleepAnalysis() {
		let sleptHours = HKSampleType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)
		let predicate = HKQuery.predicateForSamplesWithStartDate(startTime24HourData, endDate: now, options: .None)
		
		let query = HKSampleQuery(sampleType: sleptHours, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) {
			(query, results, error) in
			if results == nil {
				println("There was an error running the query: \(error)")
			}
			
			dispatch_async(dispatch_get_main_queue()) {
				println("=================================")
				
				println("Samples: \(results.count)")
				
				if let quantity = results.first as? HKCategorySample {
					println("Sleep Description: \(quantity.description)")
					println(quantity.source.description)
					println()
					
					if let sleepValue = HKCategoryValueSleepAnalysis(rawValue: quantity.value) {
						println("is InBed? \(sleepValue == .InBed)")
						println("is Asleep? \(sleepValue == .Asleep)")
					}
					
					println("\(self.df.stringFromDate(quantity.startDate))")
					println("\(self.df.stringFromDate(quantity.endDate))")
					let timeAsleep = quantity.endDate.timeIntervalSinceDate(quantity.startDate)
					
					let (h,m,s) = self.durationsBySecond(seconds: timeAsleep)
					self.sleeps = "\(h) hr \(m) min"
				}
				
				println("=================================")
			}
		}
		self.healthStore?.executeQuery(query)
	}
	
	func durationsBySecond(seconds s: Double) -> (hours:Int,minutes:Int,seconds:Double) {
		return (Int((s % (24 * 3600)) / 3600), Int(s % 3600 / 60), s % 60)
	}
}
