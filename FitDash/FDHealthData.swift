//
//  FDHealthData.swift
//  
//
//  Created by Jillian Burgess on 12/6/14.
//
//

import Foundation
import HealthKit

class FDHealthData {
	
	var healthStore: HKHealthStore?
	let df = NSDateFormatter()
	
	var values: [Double] = []
	var dates: [NSDate] = []
	
	
//	var daySteps: [Double] = []
//	var timeInHours: [NSDate] = []
//	var weeklySteps: [Double] = []
//	var weeklyDates: [NSDate] = []
//	var weeklyDistance: [Double] = []
//	var weeklyFlightsClimbed: [Double] = []
	
	// MARK: - Overrides
	
	init(store: HKHealthStore) {
		healthStore = store
	}
	
	func addData(value: Double, forDate: NSDate) {
		let df = NSDateFormatter()
		df.dateStyle = .ShortStyle
		df.timeStyle = .ShortStyle
		println("-----tuple-----")
		println("\(df.stringFromDate(forDate)) : \(value)")
		values.append(value)
		dates.append(forDate)
	}
	
	// MARK: - Misc. HealthKit Queries
	
	//creates a collection for plotting weekly step counts for all step samples collected
	// NOTE: THIS QUERY MAY TAKE A LONGER AMOUNT OF TIME TO COMPLETE THAN OTHER QUERIES!!
	func plotAllStepSamplesPerWeek() {
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
		
		let quantityType =
		HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
		
		let endDate = NSDate()
		let startDate = calendar.dateByAddingUnit(.MonthCalendarUnit, value: -3, toDate: endDate, options: nil)
		let predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
		
		// Create the query
		let query = HKStatisticsCollectionQuery(quantityType: quantityType,
			quantitySamplePredicate: predicate, //nil,
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
			
			// Plot the weekly step counts over the past 3 months
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
