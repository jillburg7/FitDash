//
//  FDWeekStatsPerDay.swift
//  FitDash
//
//  Created by Jillian Burgess on 12/7/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import Foundation
import HealthKit

//daily statistics over a week
class FDWeekStatsPerDay: FDHealthData {
	
	// MARK: - class properties
	var startDate: NSDate {
		get {
			return NSCalendar.currentCalendar().dateByAddingUnit(.DayCalendarUnit, value: -7, toDate: endDate, options: nil)!
		}
	}
	var endDate = NSDate()
	var days: [String] = []
	var weekInStepsPerDay: [Double] = []
	var weekInDistancePerDay: [Double] = []
	var weekInFlightsClimbedPerDay: [Double] = []
	var weekInSleepPerDay: [Double] = []
	var weekInActiveCaloriesPerDay: [Double] = []
	var weekInDietaryCaloriesPerDay: [Double] = []
	
	// MARK: - getters for model data
	
	
	// MARK: - Overrides
	
	override init(store: HKHealthStore) {
		super.init(store: store)
	}
	
	// MARK: - class functions
	
	func queryWeekInStepsPerDay() {
		
	}

	func queryWeekInDistancePerDay() {
		
	}

	func queryWeekInFlightsClimbedPerDay() {
		
	}

	func queryWeekInSleepPerDay() {
		
	}

	func queryWeekInActiveCaloriesPerDay() {
		
	}

	func queryWeekInDietaryCaloriesPerDay() {
		
	}

	
	//creates a collection for plotting the past week in step counts
	func queryPastWeekInSteps() {
		let calendar = NSCalendar.currentCalendar()
		
		let interval = NSDateComponents()
		interval.day = 1
		
		// Set the anchor date to Monday at 12:00 a.m.
		let anchorComponents =
		calendar.components(.CalendarUnitDay | .CalendarUnitMonth |
			.CalendarUnitYear | .CalendarUnitWeekday, fromDate: NSDate())
		
		anchorComponents.hour = 0
		
		let anchorDate = calendar.dateFromComponents(anchorComponents)
		let df = NSDateFormatter()
		df.dateStyle = .ShortStyle
		df.timeStyle = .ShortStyle
		
		let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
		
		let endDate = NSDate()
		let startDate = calendar.dateByAddingUnit(.DayCalendarUnit, value: -7, toDate: endDate, options: nil)
		let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
		
		// Create the query
		let query = HKStatisticsCollectionQuery(quantityType: quantityType,
			quantitySamplePredicate: predicate,
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
			
			//			let endDate = NSDate()
			//			let startDate = calendar.dateByAddingUnit(.MonthCalendarUnit, value: -3, toDate: endDate, options: nil)
			
			// Plot the daily step counts over the past 7 days
			results.enumerateStatisticsFromDate(startDate, toDate: endDate) {
				statistics, stop in
				
				if let quantity = statistics.sumQuantity() {
					let date = statistics.startDate
					let value = quantity.doubleValueForUnit(HKUnit.countUnit())
					
					self.addData(value, forDate: date)
				}
			}
		}
		self.healthStore?.executeQuery(query)
	}
	
}