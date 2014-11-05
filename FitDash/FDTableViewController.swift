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
	
	var healthStore: HKHealthStore?
	var stepSamples = [HKQuantitySample]()
	var steps = 0.0
	var distance = 0.0
	var flightsClimbed = 0.0
	
	var values: [Double] = []
	var dates: [NSDate] = []
	
	var midnight = NSDate()
	var startTime24HourData = NSDate()
	var now = NSDate()
	var numberOfPoints:Int = 0
	var ready = false
	
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
		
		// Set up an HKHealthStore, asking the user for read/write permissions. This view controller is the
		// first view controller that's shown to the user, so all of the desired HealthKit permissions are
		// asked for now. Should consider requesting permissions the first time a user wants to interact with
		// HealthKit data.
		if !HKHealthStore.isHealthDataAvailable() {
			return
		}
		
		var writeDataTypes: NSSet = self.healthStore!.dataTypesToWrite()
		var readDataTypes: NSSet = self.healthStore!.dataTypesToRead()
		
		var completion: ((Bool, NSError!) -> Void)! = {
			(success, error) -> Void in
			
			if !success {
				println("You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: \(error). If you're using a simulator, try it on a device.")
				return
			}
			
			dispatch_async(dispatch_get_main_queue(), {
				() -> Void in
				
				// Update the user interface based on the current user's health information.
				//				self.requestAgeAndUpdate()
//				self.getData()
				self.plotWeeklySteps()
			})
		}
		
		self.healthStore?.requestAuthorizationToShareTypes(writeDataTypes, readTypes: readDataTypes, completion: completion)
	}
	
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
			chartDetails.healthStore = self.healthStore
			chartDetails.tupleData = (dates, values)
			chartDetails.title = destinationTitle
			
		} else if segue.identifier == "jawboneLineChart" {
			let indexPath = self.tableView.indexPathForSelectedRow()!
			let destinationTitle = self.items[indexPath.row]
			
			let chartDetails = segue.destinationViewController as FDJawboneChartViewController
			chartDetails.healthStore = self.healthStore
			chartDetails.tupleData = (dates, values)
			chartDetails.title = destinationTitle
		}
	}
	
	
	//MARK: - Private Method
	//MARK: HealthKit Permissions
	
//	
//	func getData() {
//		self.now = NSDate()
//		self.midnight = NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: now, options: nil)!
//		self.startTime24HourData = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: -1, toDate: now, options: nil)!
//		self.getTodaysCumulativeSteps()
//		self.getTodaysCumulativeDistance()
//		self.getTodaysFlightsClimbed()
//	}
//	
//	// MARK: - Read HealthKit data
//	
//	func requestStepsAndUpdate() {
//		var error: NSError?
//		let desc = self.healthStore?.description
//		println("description of healthStore obj: \(desc)")
//		
//		let endDate = NSDate()
//		let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitMonth, value: -1, toDate: endDate, options: nil)
//		
//		let stepsType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
//		let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
//		
//		let query = HKSampleQuery(sampleType: stepsType, predicate: predicate, limit: 0, sortDescriptors: nil, resultsHandler: {
//			(query, results, error) in
//			if results == nil {
//				println("There was an error running the query: \(error)")
//			}
//			
//			dispatch_async(dispatch_get_main_queue()) {
//				self.stepSamples = results as [HKQuantitySample]
//				println("steps: \(self.stepSamples)")
//			}
//		})
//		
//		self.healthStore?.executeQuery(query)
//	}
//	
//	// MARK: - Today's Stats
//	
//	// gets the cumlative steps taken over the past 24hours
//	func getTodaysCumulativeSteps() {
//		let stepsType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
//		let predicate = HKQuery.predicateForSamplesWithStartDate(midnight, endDate: now, options: .None)
//		
//		let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate,
//			options: .CumulativeSum) {
//				(query, results, error) in
//				if results == nil {
//					println("There was an error running the query: \(error)")
//				}
//				
//				dispatch_async(dispatch_get_main_queue()) {
//					
//					
//					if let quantity = results.sumQuantity() {
//						let unit = HKUnit.countUnit()
//						self.steps = quantity.doubleValueForUnit(unit)
//						
//												
////						self.dataRefreshLabel.text = "Updated: \(df.stringFromDate(self.now))"
////						self.stepsLabel.text = "Step Count:  \(self.steps) steps"
//					}
//				}
//		}
//		self.healthStore?.executeQuery(query)
//	}
//	
//	func getTodaysCumulativeDistance() {
//		let distanceType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
//		let predicate = HKQuery.predicateForSamplesWithStartDate(midnight, endDate: now, options: .None)
//		
//		let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate,
//			options: .CumulativeSum) {
//				(query, results, error) in
//				if results == nil {
//					println("There was an error running the query: \(error)")
//				}
//				
//				dispatch_async(dispatch_get_main_queue()) {
//					
//					if let quantity = results.sumQuantity() {
//						let unit = HKUnit.mileUnit()
//						self.distance = quantity.doubleValueForUnit(unit)
//						
//						var distanceString = String(format:"%.2f", self.distance)
//						self.distanceLabel.text = "Distance: \(distanceString) miles"
//					}
//				}
//		}
//		self.healthStore?.executeQuery(query)
//	}
//	
//	func getTodaysFlightsClimbed() {
//		let flightsClimbedType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)
//		let predicate = HKQuery.predicateForSamplesWithStartDate(midnight, endDate: now, options: .None)
//		
//		let query = HKStatisticsQuery(quantityType: flightsClimbedType, quantitySamplePredicate: predicate,
//			options: .CumulativeSum) {
//				(query, results, error) in
//				if results == nil {
//					println("There was an error running the query: \(error)")
//				}
//				
//				dispatch_async(dispatch_get_main_queue()) {
//					
//					if let quantity = results.sumQuantity() {
//						let unit = HKUnit.countUnit()
//						self.flightsClimbed = quantity.doubleValueForUnit(unit)
//						
//						self.flightsClimbedLabel.text = "Flights Climbed: \(self.flightsClimbed) floors"
//					}
//				}
//		}
//		self.healthStore?.executeQuery(query)
//	}
	
	func getSleepAnalysis() {
		//sleeps
	}
	
	// MARK: - Graphing Functions
	
	//creates a collection for plotting weekly step counts
	func plotWeeklySteps() {
		let calendar = NSCalendar.currentCalendar()
		
		let interval = NSDateComponents()
		interval.day = 7
		
		// Set the anchor date to Monday at 12:00 a.m.
		let anchorComponents =
		calendar.components(.CalendarUnitDay | .CalendarUnitMonth |
			.CalendarUnitYear | .CalendarUnitWeekday, fromDate: NSDate())
		
		let offset = (7 + anchorComponents.weekday - 2) % 7
		anchorComponents.day -= offset
		anchorComponents.hour = 0
		
		let anchorDate = calendar.dateFromComponents(anchorComponents)
		let df = NSDateFormatter()
		df.dateStyle = .ShortStyle
		df.timeStyle = .MediumStyle
		println("anchorDate: \(df.stringFromDate(anchorDate!))")
		
		let quantityType =
		HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
		
		// Create the query
		let query = HKStatisticsCollectionQuery(quantityType: quantityType,
			quantitySamplePredicate: nil,
			options: .CumulativeSum,
			anchorDate: anchorDate,
			intervalComponents: interval)
		
		// Set the results handler
		query.initialResultsHandler = {
			query, results, error in
			
			if error != nil {
				// Perform proper error handling here
				println("*** An error occurred while calculating the statistics: \(error.localizedDescription) ***")
				abort()
			}
			
			let endDate = NSDate()
			let startDate =
			calendar.dateByAddingUnit(.MonthCalendarUnit,
				value: -3, toDate: endDate, options: nil)
			
			// Plot the weekly step counts over the past 3 months
			results.enumerateStatisticsFromDate(startDate, toDate: endDate) {
				statistics, stop in
				
				if let quantity = statistics.sumQuantity() {
					let date = statistics.startDate
					let value = quantity.doubleValueForUnit(HKUnit.countUnit())
					
					self.plotData(value, forDate: date)
				}
			}
			//			self.graphView.reloadGraph()
			println("isReady?? \(self.ready)")
			self.ready = true
		}
		self.healthStore?.executeQuery(query)
	}
	
	func isReady() -> Bool {
		return ready
	}
	
	// MARK: Data Plotting
	
	func plotData(value: Double, forDate: NSDate) {
		let df = NSDateFormatter()
		df.dateStyle = .ShortStyle
		println("\(df.stringFromDate(forDate)) : \(value)")
		values.append(value)
		dates.append(forDate)
		if dates.count == 8 {
			numberOfPoints = 8
			println("numberOfPoints set")
		}
	}
	// MARK - END
}