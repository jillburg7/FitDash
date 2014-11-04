//
//  FDHealthStats.swift
//  FitDash
//
//  Created by Jillian Burgess on 11/3/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import Foundation
import HealthKit

class FDHealthStats {
	
/*
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
					
					
					if let quantity = results.sumQuantity() {
						let unit = HKUnit.countUnit()
						self.steps = quantity.doubleValueForUnit(unit)
						
						let df = NSDateFormatter()
						df.dateStyle = .ShortStyle
						df.timeStyle = .MediumStyle
						
						//						self.dataRefreshLabel.text = "Updated: \(df.stringFromDate(self.now))"
						//						self.stepsLabel.text = "Step Count:  \(steps) steps"
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
						
						//						var distanceString = String(format:"%.2f", distance)
						//						self.distanceLabel.text = "Distance: \(distanceString) miles"
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
						
						//						self.flightsClimbedLabel.text = "Flights Climbed: \(flightsClimbed) floors"
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
			//			self.graphView.reloadGraph()
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
		if dates.count == 8 {
			numberOfPoints = 8
			println("numberOfPoints set")
		}
	}
	// MARK - END
*/
}