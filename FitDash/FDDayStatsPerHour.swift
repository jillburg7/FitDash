//
//  FDDayStatsPerHour.swift
//  FitDash
//
//  Created by Jillian Burgess on 12/7/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import Foundation
import HealthKit

//hourly statistics
class FDDayStatsPerHour: FDHealthData {
	
	// MARK: - class properties
	var startTime: NSDate {
		get {
			return NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: endTime, options: nil)!
		}
	}
	var endTime = NSDate()
	var hours: [String] = []
	var timeInHours: [NSDate] = []
	
	var dayInStepsPerHour: [Double] = []
	var dayInDistancePerHour: [Double] = []
	var dayInFlightsClimbedPerHour: [Double] = []
	var dayInActiveCaloriesPerHour: [Double] = []
	var dayInDietaryCaloriesPerHour: [Double] = []
	
	// MARK: - Query Params
	
	let calendar = NSCalendar.currentCalendar()
	let interval = NSDateComponents()
	// Set the anchor date to Monday at 12:00 a.m.
	var anchorComponents = NSDateComponents()
	var anchorDate = NSDate()
	var predicate: NSPredicate!
	
	// MARK: - Overrides

	override init(store: HKHealthStore) {
		super.init(store: store)
		setup()
	}
	
	func setup() {
		interval.hour = 1
		anchorComponents = calendar.components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitWeekday, fromDate: NSDate())
		anchorComponents.hour = 0
		anchorDate = calendar.dateFromComponents(anchorComponents)!
		predicate = HKQuery.predicateForSamplesWithStartDate(startTime, endDate: endTime, options: .None)
	}
	
	func startQueries() {
		queryDayInStepsPerHour()
		queryDayInDistancePerHour()
		queryDayInFlightsClimbedPerHour()
		queryDayInActiveCaloriesPerHour()
		queryDayInDietaryCaloriesPerHour()
	}
	
	// MARK: - getters for model data
	
	func getDayInStepsPerHour() -> ([NSDate], [Double]) {
		return (timeInHours, dayInStepsPerHour)
	}
	
	func getDayStepData() -> ([String], [Double]) {
		return (hours, dayInStepsPerHour)
	}
	
	func getDayInDistancePerHour() -> ([NSDate], [Double]) {
		return (timeInHours, dayInDistancePerHour)
	}
	
	func getDayInFlightsClimbedPerHour() -> ([NSDate], [Double]) {
		return (timeInHours, dayInFlightsClimbedPerHour)
	}
	
	func getDayInActiveCaloriesPerHour() -> ([NSDate], [Double]) {
		return (timeInHours, dayInActiveCaloriesPerHour)
	}
	
	func getDayInDietaryCaloriesPerHour() -> ([NSDate], [Double]) {
		return (timeInHours, dayInDietaryCaloriesPerHour)
	}
	
	// MARK: - class functions
	
	//creates a collection for plotting the past week in step counts
	func queryDayInStepsPerHour() {
		let quantityType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
		
		// Create the query
		let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .CumulativeSum, anchorDate: anchorDate, intervalComponents: interval)
		
		// Set the results handler
		query.initialResultsHandler = {
			query, results, error in
			
			if error != nil {
				// Perform proper error handling here
				println("*** An error occurred while calculating the statistics: \(error.localizedDescription) ***")
				abort()
			}
			
			// Plot todays step counts on the hour every hour until current time
			results.enumerateStatisticsFromDate(self.startTime, toDate: self.endTime) {
				statistics, stop in
				
				if let quantity = statistics.sumQuantity() {
					let date = statistics.startDate
					let value = quantity.doubleValueForUnit(HKUnit.countUnit())
					self.addDayStepData(value, forDate: date)
				} else if statistics.sumQuantity() == nil {
					// if statistics collection returns no samples for a particular time interval
					let date = statistics.startDate
					let value = 0.0
					self.addDayStepData(value, forDate: date)
				}
			}
		}
		self.healthStore?.executeQuery(query)
	}

	func queryDayInDistancePerHour() {
		let quantityType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
		
		// Create the query
		let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .CumulativeSum, anchorDate: anchorDate, intervalComponents: interval)
		
		// Set the results handler
		query.initialResultsHandler = {
			query, results, error in
			
			if error != nil {
				// Perform proper error handling here
				println("*** An error occurred while calculating the statistics: \(error.localizedDescription) ***")
				abort()
			}
			
			// Plot todays step counts on the hour every hour until current time
			results.enumerateStatisticsFromDate(self.startTime, toDate: self.endTime) {
				statistics, stop in
				
				if let quantity = statistics.sumQuantity() {
					let date = statistics.startDate
					let value = quantity.doubleValueForUnit(HKUnit.mileUnit())
					self.addDayDistanceData(value, forDate: date)
				} else if statistics.sumQuantity() == nil {
					// if statistics collection returns no samples for a particular time interval
					let date = statistics.startDate
					let value = 0.0
					self.addDayDistanceData(value, forDate: date)
				}
			}
		}
		self.healthStore?.executeQuery(query)
	}

	func queryDayInFlightsClimbedPerHour() {
		let quantityType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)
		
		// Create the query
		let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .CumulativeSum, anchorDate: anchorDate, intervalComponents: interval)
		
		// Set the results handler
		query.initialResultsHandler = {
			query, results, error in
			
			if error != nil {
				// Perform proper error handling here
				println("*** An error occurred while calculating the statistics: \(error.localizedDescription) ***")
				abort()
			}
			
			// Plot todays step counts on the hour every hour until current time
			results.enumerateStatisticsFromDate(self.startTime, toDate: self.endTime) {
				statistics, stop in
				
				if let quantity = statistics.sumQuantity() {
					let date = statistics.startDate
					let value = quantity.doubleValueForUnit(HKUnit.countUnit())
					self.addDayFlightsClimbedData(value, forDate: date)
				} else if statistics.sumQuantity() == nil {
					// if statistics collection returns no samples for a particular time interval
					let date = statistics.startDate
					let value = 0.0
					self.addDayFlightsClimbedData(value, forDate: date)
				}
			}
		}
		self.healthStore?.executeQuery(query)
	}
	
	func queryDayInSleepPerHour() {
		
	}

	func queryDayInActiveCaloriesPerHour() {
		let quantityType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)
		
		// Create the query
		let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .CumulativeSum, anchorDate: anchorDate, intervalComponents: interval)
		
		// Set the results handler
		query.initialResultsHandler = {
			query, results, error in
			
			if error != nil {
				// Perform proper error handling here
				println("*** An error occurred while calculating the statistics: \(error.localizedDescription) ***")
				abort()
			}
			
			// Plot todays step counts on the hour every hour until current time
			results.enumerateStatisticsFromDate(self.startTime, toDate: self.endTime) {
				statistics, stop in
				
				if let quantity = statistics.sumQuantity() {
					let date = statistics.startDate
					let value = quantity.doubleValueForUnit(HKUnit.calorieUnit())
					self.addDayActiveCaloriesData(value, forDate: date)
				} else if statistics.sumQuantity() == nil {
					// if statistics collection returns no samples for a particular time interval
					let date = statistics.startDate
					let value = 0.0
					self.addDayActiveCaloriesData(value, forDate: date)
				}
			}
		}
		self.healthStore?.executeQuery(query)
	}

	func queryDayInDietaryCaloriesPerHour() {
		let quantityType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed)
		
		// Create the query
		let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .CumulativeSum, anchorDate: anchorDate, intervalComponents: interval)
		
		// Set the results handler
		query.initialResultsHandler = {
			query, results, error in
			
			if error != nil {
				// Perform proper error handling here
				println("*** An error occurred while calculating the statistics: \(error.localizedDescription) ***")
				abort()
			}
			
			// Plot todays step counts on the hour every hour until current time
			results.enumerateStatisticsFromDate(self.startTime, toDate: self.endTime) {
				statistics, stop in
				
				if let quantity = statistics.sumQuantity() {
					let date = statistics.startDate
					let value = quantity.doubleValueForUnit(HKUnit.calorieUnit())
					self.addDayDietaryCaloriesData(value, forDate: date)
				} else if statistics.sumQuantity() == nil {
					// if statistics collection returns no samples for a particular time interval
					let date = statistics.startDate
					let value = 0.0
					self.addDayDietaryCaloriesData(value, forDate: date)
				}
			}
		}
		self.healthStore?.executeQuery(query)
	}

	// MARK: Add data points to data structure
	
	func addDayStepData(value: Double, forDate: NSDate) {
		df.dateStyle = .NoStyle
		df.timeStyle = .ShortStyle
		dayInStepsPerHour.append(value)
		timeInHours.append(forDate)
		hours.append(df.stringFromDate(forDate))
		println("\(df.stringFromDate(forDate)) : \(value)")
	}
	
	func addDayDistanceData(value: Double, forDate: NSDate) {
		df.dateStyle = .NoStyle
		df.timeStyle = .ShortStyle
		dayInDistancePerHour.append(value)
		timeInHours.append(forDate)
		println("\(df.stringFromDate(forDate)) : \(value)")
	}
	
	func addDayFlightsClimbedData(value: Double, forDate: NSDate) {
		df.dateStyle = .NoStyle
		df.timeStyle = .ShortStyle
		dayInFlightsClimbedPerHour.append(value)
		timeInHours.append(forDate)
		println("\(df.stringFromDate(forDate)) : \(value)")
	}
	
	func addDayActiveCaloriesData(value: Double, forDate: NSDate) {
		df.dateStyle = .NoStyle
		df.timeStyle = .ShortStyle
		dayInActiveCaloriesPerHour.append(value)
		timeInHours.append(forDate)
		println("\(df.stringFromDate(forDate)) : \(value)")
	}
	
	func addDayDietaryCaloriesData(value: Double, forDate: NSDate) {
		df.dateStyle = .NoStyle
		df.timeStyle = .ShortStyle
		dayInDietaryCaloriesPerHour.append(value)
		timeInHours.append(forDate)
		println("\(df.stringFromDate(forDate)) : \(value)")
	}
}