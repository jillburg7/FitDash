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
	
	@IBOutlet var ageLabel: UILabel!
	@IBOutlet var stepsLabel: UILabel!
	@IBOutlet var startDateLabel: UILabel!
	@IBOutlet var endDateLabel: UILabel!
	
	@IBOutlet var graphView: BEMSimpleLineGraphView!
	@IBOutlet var maximumLabel: UILabel!
	
	var dataPoints: [Double] = []
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		createAndPropagateHealthStore()
	}
	
	private func createAndPropagateHealthStore() {
		if self.healthStore == nil {
			self.healthStore = HKHealthStore()
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		
		self.graphView.enableBezierCurve = true
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		// Set up an HKHealthStore, asking the user for read/write permissions. The profile view controller is the
		// first view controller that's shown to the user, so we'll ask for all of the desired HealthKit permissions now.
		// In your own app, you should consider requesting permissions the first time a user wants to interact with
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
//				self.updateUserAge()
//				self.updateUsersHeight()
//				self.updateUsersWeight()
				self.requestAgeAndUpdate()
				self.getCumulativeSteps()
				self.plotWeeklySteps()
			})
		}
		
		self.healthStore?.requestAuthorizationToShareTypes(writeDataTypes, readTypes: readDataTypes, completion: completion)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
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
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount),
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass),
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight),
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex),
			HKCharacteristicType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth),
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed),
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned),
			HKCharacteristicType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex)
		]
		return NSSet(array: dataTypesToRead)
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
	
	// gets the cumlative steps taken over the past 24hours
	func getCumulativeSteps() {
		let endDate = NSDate()
		let startDate = NSCalendar.currentCalendar().dateByAddingUnit(.CalendarUnitDay, value: -1, toDate: endDate, options: nil)
		
		let stepsType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
		let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
		
		let query = HKStatisticsQuery(quantityType: stepsType, 	quantitySamplePredicate: predicate,
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
						df.dateStyle = .FullStyle
						
						println("Start Date: \(df.stringFromDate(startDate))")
						println("End Date: \(df.stringFromDate(endDate))")
						self.stepsLabel.text = "Steps Taken: \(steps)"
						self.startDateLabel.text = "Start Date: \(df.stringFromDate(startDate))"
						self.endDateLabel.text = "End Date: \(df.stringFromDate(endDate))"
					}
				}
		}
		
		self.healthStore?.executeQuery(query)
	}
	
	//creates a collection for plotting weekly step counts
	func plotWeeklySteps() {
		let calendar = NSCalendar.currentCalendar()
		
		let interval = NSDateComponents()
		interval.day = 7
		
		// Set the anchor date to Monday at 3:00 a.m.
		let anchorComponents =
		calendar.components(.CalendarUnitDay | .CalendarUnitMonth |
			.CalendarUnitYear | .CalendarUnitWeekday, fromDate: NSDate())
		
		let offset = (7 + anchorComponents.weekday - 2) % 7
		anchorComponents.day -= offset
		anchorComponents.hour = 3
		
		let anchorDate = calendar.dateFromComponents(anchorComponents)
		
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
	
	
	func plotData(data: Double, forDate: NSDate) {
		println("data: \(data)")
		dataPoints.append(data)
	}

	func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView!) -> Int {
		return 5;
	}
	
	func lineGraph(graph: BEMSimpleLineGraphView!, valueForPointAtIndex index: Int) -> CGFloat {
		if !dataPoints.isEmpty {
			return CGFloat(dataPoints[index])
		}
		else {
			return 0.0
		}
	}

}

