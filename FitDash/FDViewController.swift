//
//  ViewController.swift
//  FitDash
//
//  Created by Jillian Burgess on 10/12/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import UIKit
import HealthKit

class FDViewController: UIViewController, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate {
	
	var healthStore: HKHealthStore?
	var stepSamples = [HKQuantitySample]()
	
	var values: [Double] = []
	var dates: [NSDate] = []
	
	var midnight = NSDate()
	var startTime24HourData = NSDate()
	var now = NSDate()
	var numberOfPoints:Int = 0
	let labelColor = UIColor.whiteColor()
	
	@IBOutlet var ageLabel: UILabel!
	@IBOutlet var dataRefreshLabel: UILabel!
	@IBOutlet var stepsLabel: UILabel!
	@IBOutlet var distanceLabel: UILabel!
	@IBOutlet var flightsClimbedLabel: UILabel!
	@IBOutlet var sleepLabel: UILabel!
	
	@IBAction func refresh(sender: AnyObject) {
		values.removeAll(keepCapacity: false)
		dates.removeAll(keepCapacity: false)
		getData()
	}
	
	@IBOutlet var graphView: BEMSimpleLineGraphView!
	
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
	
	override func viewWillAppear(animated: Bool) {
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		// Set up an HKHealthStore, asking the user for read/write permissions. This view controller is the
		// first view controller that's shown to the user, so all of the desired HealthKit permissions are
		// asked for now. Should consider requesting permissions the first time a user wants to interact with
		// HealthKit data.
		if !HKHealthStore.isHealthDataAvailable() {
			return
		}
		
		var writeDataTypes: NSSet = self.dataTypesToWrite()
		var readDataTypes: NSSet = self.dataTypesToRead()
		
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
				self.getData()
				self.plotWeeklySteps()
			})
		}
		
		self.healthStore?.requestAuthorizationToShareTypes(writeDataTypes, readTypes: readDataTypes, completion: completion)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.graphView.enableBezierCurve = true
		self.graphView.enableYAxisLabel = true
		self.graphView.autoScaleYAxis = true
		self.graphView.alwaysDisplayDots = true
		self.graphView.alphaLine = 1.0
		self.graphView.colorXaxisLabel = labelColor
		self.graphView.colorYaxisLabel = labelColor
		self.graphView.colorTouchInputLine = UIColor.whiteColor()
		self.graphView.alphaTouchInputLine = 1.0
//		self.graphView.widthLine = 3.0;
		self.graphView.enableTouchReport = true
		self.graphView.enablePopUpReport = true
		self.graphView.enableReferenceAxisLines = true
		self.graphView.enableReferenceAxisFrame = true
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//MARK: - Private Method
	//MARK: HealthKit Permissions
	
	private func dataTypesToWrite() -> NSSet {
		let dataTypesToWrite = [
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass),
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed),
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned),
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
		]
		return NSSet(array: dataTypesToWrite)
	}
	
	private func dataTypesToRead() -> NSSet {
		let dataTypesToRead = [
			//fitness
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount),
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning),
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed),
			HKCategoryType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis),
			//calories
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed),
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned),
			//body
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass),
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight),
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex),
			//personal info
			HKCharacteristicType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth),
			HKCharacteristicType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)
		]
		return NSSet(array: dataTypesToRead)
	}
	
	func getData() {
		self.now = NSDate()
		self.midnight = NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: now, options: nil)!
		self.startTime24HourData = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: -1, toDate: now, options: nil)!
		self.getTodaysCumulativeSteps()
		self.getTodaysCumulativeDistance()
		self.getTodaysFlightsClimbed()
	}
	
	// MARK: - Read HealthKit data
	
	func requestAgeAndUpdate() {
		var error: NSError?
		let dob = self.healthStore?.dateOfBirthWithError(&error)
		
		if error != nil {
			println("There was an error requesting the date of birth: \(error)")
			return
		}
		
		// Calculate the age
		let now = NSDate()
		let age = NSCalendar.currentCalendar().components(.YearCalendarUnit, fromDate: dob!, toDate: now, options: .WrapComponents)
		self.ageLabel.text = "Age: \(age.year)"
	}
	
	func requestStepsAndUpdate() {
		var error: NSError?
		let desc = self.healthStore?.description
		println("description of healthStore obj: \(desc)")
		
		let endDate = NSDate()
		let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitMonth, value: -1, toDate: endDate, options: nil)
		
		let stepsType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
		let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
		
		let query = HKSampleQuery(sampleType: stepsType, predicate: predicate, limit: 0, sortDescriptors: nil, resultsHandler: {
			(query, results, error) in
			if results == nil {
				println("There was an error running the query: \(error)")
			}
			
			dispatch_async(dispatch_get_main_queue()) {
				self.stepSamples = results as [HKQuantitySample]
				self.stepsLabel.text = "steps: \(self.stepSamples)"
				println("steps: \(self.stepSamples)")
			}
		})
		
		self.healthStore?.executeQuery(query)
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
					var steps = 0.0
					
					if let quantity = results.sumQuantity() {
						let unit = HKUnit.countUnit()
						steps = quantity.doubleValueForUnit(unit)
						
						let df = NSDateFormatter()
						df.dateStyle = .ShortStyle
						df.timeStyle = .MediumStyle
						
						self.dataRefreshLabel.text = "Updated: \(df.stringFromDate(self.now))"
						self.stepsLabel.text = "Step Count:  \(steps) steps"
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
					var distance = 0.0
					
					if let quantity = results.sumQuantity() {
						let unit = HKUnit.mileUnit()
						distance = quantity.doubleValueForUnit(unit)
						
						var distanceString = String(format:"%.2f", distance)
						self.distanceLabel.text = "Distance: \(distanceString) miles"
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
					var flightsClimbed = 0.0
					
					if let quantity = results.sumQuantity() {
						let unit = HKUnit.countUnit()
						flightsClimbed = quantity.doubleValueForUnit(unit)
						
						self.flightsClimbedLabel.text = "Flights Climbed: \(flightsClimbed) floors"
					}
				}
		}
		self.healthStore?.executeQuery(query)
	}
	
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
			self.graphView.reloadGraph()
		}
		self.healthStore?.executeQuery(query)
	}
	
	// MARK: Data Plotting
	
	func plotData(value: Double, forDate: NSDate) {
		let df = NSDateFormatter()
		df.dateStyle = .ShortStyle
		println("\(df.stringFromDate(forDate)) : \(value)")
		values.append(value)
		dates.append(forDate)
		if dates.count == 7 {
			numberOfPoints = 7
			println("numberOfPoints set")
//			self.graphView.reloadGraph()
		}
	}
	
	// MARK: - Required Data Source Methods
	
	// REQUIRED FUNCTION:
	// Specify the number of points on the graph. BEMSimpleLineGraph will pass the
	//	graph of interest in the graph parameter. The line graph gets the value
	//	returned by this method from its data source and caches it.
	// RETURNS: Number of points in the graph.
	func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView!) -> Int {
		return numberOfPoints
	}
	
	// REQUIRED FUNCTION:
	// Informs the position of each point on the Y-Axis at a given index. This method is
	//	called for every point specified in the numberOfPointsInLineGraph: method. The
	//	parameter index is the position from left to right of the point on the X-Axis.
	// RETURNS: The value of the point on the Y-Axis for the index.
	func lineGraph(graph: BEMSimpleLineGraphView!, valueForPointAtIndex index: Int) -> CGFloat {
		if !values.isEmpty {
			return CGFloat(values[index])
		}
		else {
			return 0.0
		}
	}
	
	// MARK: BEMSimpleLineGraph Methods
	
	func lineGraph(graph: BEMSimpleLineGraphView!, labelOnXAxisForIndex index: Int) -> String! {
		if !dates.isEmpty {      //(index % 2) == 1 &&
			let df = NSDateFormatter()
			df.dateStyle = .ShortStyle
			return df.stringFromDate(dates[index])
		} else { return "" }
	}
	
	func lineGraphDidBeginLoading(graph: BEMSimpleLineGraphView!) {
		println("-----------------------")
		println("graph did begin loading")
	}
	
	func lineGraphDidFinishLoading(graph: BEMSimpleLineGraphView!) {
		println("dates: \(self.graphView.graphValuesForXAxis())")
		println("values: \(self.graphView.graphValuesForDataPoints())")
		println("graph did finish loading")
		println("------------------------")
	}
	
}

