//
//  WeekStatsPerDay.swift
//  FitDash
//
//  Created by Jillian Burgess on 12/7/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import Foundation
import HealthKit

//daily statistics over a week
class WeekStatsPerDay: HealthData {
	
	// MARK: - class properties
	var startDate: NSDate {
		get {
			return NSCalendar.currentCalendar().dateByAddingUnit(.DayCalendarUnit, value: -7, toDate: endDate, options: nil)!
		}
	}
	var endDate = NSDate()
	var days: [String] = []
	var timeInDays: [NSDate] = []
	
	var weekInStepsPerDay: [Double] = []
	var weekInDistancePerDay: [Double] = []
	var weekInFlightsClimbedPerDay: [Double] = []
	var weekInSleepPerDay: [Double] = []
	var weekInActiveCaloriesPerDay: [Double] = []
	var weekInDietaryCaloriesPerDay: [Double] = []
	
	// MARK: - Query Params
	
	let calendar = NSCalendar.currentCalendar()
	let interval = NSDateComponents()
	// Set the anchor date to Monday at 12:00 a.m.
	var anchorComponents = NSDateComponents()
	var anchorDate = NSDate()
	var predicate: NSPredicate!
	
	// MARK: - getters for model data
	
	func getWeekStepData() -> ([String], [Double]) {
		return (days, weekInStepsPerDay)
	}
	
	func getWeekInStepsPerDay() -> ([NSDate], [Double]) {
		return (timeInDays, weekInStepsPerDay)
	}
	
	func getWeekInDistancePerDay() -> ([NSDate], [Double]) {
		return (timeInDays, weekInDistancePerDay)
	}
	
	func getWeekInFlightsClimbedPerDay() -> ([NSDate], [Double]) {
		return (timeInDays, weekInFlightsClimbedPerDay)
	}
	
	func getWeekInSleepPerDay() -> ([NSDate], [Double]) {
		return (timeInDays, weekInSleepPerDay)
	}
	
	func getWeekInActiveCaloriesPerDay() -> ([NSDate], [Double]) {
		return (timeInDays, weekInActiveCaloriesPerDay)
	}
	
	func getWeekInDietaryCaloriesPerDay() -> ([NSDate], [Double]) {
		return (timeInDays, weekInDietaryCaloriesPerDay)
	}
	
	
	// MARK: - Overrides
	
	override init(store: HKHealthStore) {
		super.init(store: store)
		setup()
	}
	
	// MARK: - Initialize Query Params
	
	func setup() {
		interval.day = 1
		// Set the anchor date to Monday at 12:00 a.m.
		anchorComponents = calendar.components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitWeekday, fromDate: NSDate())
		anchorComponents.hour = 0
		anchorDate = calendar.dateFromComponents(anchorComponents)!
		predicate = HKQuery.predicateForSamplesWithStartDate(startDate, endDate: endDate, options: .None)
	}
	
	func startQueries() {
		queryWeekInStepsPerDay()
		queryWeekInDistancePerDay()
		queryWeekInFlightsClimbedPerDay()
		queryWeekInSleepPerDay()
		queryWeekInActiveCaloriesPerDay()
		queryWeekInDietaryCaloriesPerDay()
//		queryDayInWorkouts()
	}
	
	// MARK: - class functions
	
	//query the past week in workouts
	func queryDayInWorkouts() {
		let quantityType = HKSampleType.workoutType() //HKSampleType.quantityTypeForIdentifier(HKWorkoutTypeIdentifier)
		
		let startDateSort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
		
		let query = HKSampleQuery(sampleType: quantityType, predicate: predicate, limit: 0, sortDescriptors: [startDateSort]) {
			(sampleQuery, results, error) -> Void in
			
			if let workoutSamples = results as?  [HKWorkout] {
				println()
				println("~~~~~~~~~~~~~~~~~~ workoutSamples ~~~~~~~~~~~~~~~~~~")
				for workout in workoutSamples {
					println(workout)
					println()
					
					let workoutType = workout.workoutActivityType
					switch workoutType {
					case .Running:
						println("Activity Type: Running")
					default:
						println("Activity Type: n/a, enum numeric value = \(workoutType.rawValue)")
					}
					println("Duration: \(workout.duration)")
					println("Total Distance: \(workout.totalDistance)")
					println("Total Energy Burned: \(workout.totalEnergyBurned)")
					println("Workout Events:")
					println(workout.workoutEvents)
					println("--------------------------")
					println()
				}
				println("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
				println()
			}
			else if error != nil {
				//// Perform proper error handling here...
				println("*** An error occurred while querying workouts: \(error.localizedDescription) ***")
				abort()
			}
		}
		self.healthStore?.executeQuery(query)
	}
	
	func queryWeekInStepsPerDay() {
		let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
		
		// Create the query
		let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .CumulativeSum,
			anchorDate: anchorDate, intervalComponents: interval)
		
		// Set the results handler
		query.initialResultsHandler = {
			query, results, error in
			
			if error != nil {
				// Perform proper error handling here
				println("*** An error occurred while calculating the statistics: \(error.localizedDescription) ***")
				abort()
			}
			
			// Plot the daily step counts over the past 7 days
			results.enumerateStatisticsFromDate(self.startDate, toDate: self.endDate) {
				statistics, stop in
				
				if let quantity = statistics.sumQuantity() {
					let date = statistics.startDate
					let value = quantity.doubleValueForUnit(HKUnit.countUnit())
					
					self.addWeekStepData(value, forDate: date)
				}
			}
		}
		self.healthStore?.executeQuery(query)
	}

	func queryWeekInDistancePerDay() {
		let quantityType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
		
		// Create the query
		let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .CumulativeSum,
			anchorDate: anchorDate, intervalComponents: interval)
		
		// Set the results handler
		query.initialResultsHandler = {
			query, results, error in
			
			if error != nil {
				// Perform proper error handling here
				println("*** An error occurred while calculating the statistics: \(error.localizedDescription) ***")
				abort()
			}
			
			// Plot the daily step counts over the past 7 days
			results.enumerateStatisticsFromDate(self.startDate, toDate: self.endDate) {
				statistics, stop in
				
				if let quantity = statistics.sumQuantity() {
					let date = statistics.startDate
					let value = quantity.doubleValueForUnit(HKUnit.mileUnit())
					
					self.addWeekDistanceData(value, forDate: date)
				}
			}
		}
		self.healthStore?.executeQuery(query)
	}

	func queryWeekInFlightsClimbedPerDay() {
		let quantityType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)
		
		// Create the query
		let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .CumulativeSum,
			anchorDate: anchorDate, intervalComponents: interval)
		
		// Set the results handler
		query.initialResultsHandler = {
			query, results, error in
			
			if error != nil {
				// Perform proper error handling here
				println("*** An error occurred while calculating the statistics: \(error.localizedDescription) ***")
				abort()
			}
			
			// Plot the daily step counts over the past 7 days
			results.enumerateStatisticsFromDate(self.startDate, toDate: self.endDate) {
				statistics, stop in
				
				if let quantity = statistics.sumQuantity() {
					let date = statistics.startDate
					let value = quantity.doubleValueForUnit(HKUnit.countUnit())
					
					self.addWeekFlightsClimbedData(value, forDate: date)
				}
			}
		}
		self.healthStore?.executeQuery(query)
	}

	func queryWeekInSleepPerDay() {
		let sleepSamples = HKSampleType.categoryTypeForIdentifier(HKCategoryTypeIdentifierSleepAnalysis)
		
		// Create the query
		let query = HKSampleQuery(sampleType: sleepSamples, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: nil) {
			(query, results, error) in
			
			if results == nil {
				println("There was an error running the query: \(error)")
			}
			
			dispatch_async(dispatch_get_main_queue()) {
				println("=================================")
				println("Samples: \(results.count)")
				
				for sleeps in results.generate() {
					let sleepValue = sleeps as? HKCategorySample
					var sleepDate = sleepValue?.startDate
					var sleepEndDate = sleepValue?.endDate
					let timeAsleep = sleepValue?.endDate.timeIntervalSinceDate(sleepDate!)
					
					let bundleID = sleeps.source as HKSource
					if bundleID.bundleIdentifier == "com.lark.Meadowlark" {
//						println("source added: \(bundleID.bundleIdentifier)")
						
						let hours = self.durationInHours(seconds: timeAsleep!)
						self.addWeekSleepData(hours, forDate: sleepEndDate!)
					}
					
//					let (h,m,s) = self.durationsBySecond(seconds: timeAsleep!)
//					self.addWeekSleepData("\(h) hr \(m) min", forDate: sleepDate!)
//					self.addWeekSleepData(Double(timeAsleep!), forDate: sleepEndDate!)
				}
			}
		}
		self.healthStore?.executeQuery(query)
	}
	
	func durationsBySecond(seconds s: Double) -> (hours:Int,minutes:Int,seconds:Double) {
		return (Int((s % (24 * 3600)) / 3600), Int(s % 3600 / 60), s % 60)
	}
	
	func durationInHours (seconds s: Double) -> Double {
		return (s % (24 * 3600)) / 3600
	}

	func queryWeekInActiveCaloriesPerDay() {
		let quantityType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)
		
		// Create the query
		let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .CumulativeSum,
			anchorDate: anchorDate, intervalComponents: interval)
		
		// Set the results handler
		query.initialResultsHandler = {
			query, results, error in
			
			if error != nil {
				// Perform proper error handling here
				println("*** An error occurred while calculating the statistics: \(error.localizedDescription) ***")
				abort()
			}
			
			// Plot the daily step counts over the past 7 days
			results.enumerateStatisticsFromDate(self.startDate, toDate: self.endDate) {
				statistics, stop in
				
				if let quantity = statistics.sumQuantity() {
					let date = statistics.startDate
					let value = quantity.doubleValueForUnit(HKUnit.calorieUnit())
					
					self.addWeekActiveCaloriesData(value, forDate: date)
				} else if statistics.sumQuantity() == nil {
					// if statistics collection returns no samples for a particular time interval
					let date = statistics.startDate
					let value = 0.0
					self.addWeekActiveCaloriesData(value, forDate: date)
				}
			}
		}
		self.healthStore?.executeQuery(query)
	}

	func queryWeekInDietaryCaloriesPerDay() {
		let quantityType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed)
		
		// Create the query
		let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .CumulativeSum,
			anchorDate: anchorDate, intervalComponents: interval)
		
		// Set the results handler
		query.initialResultsHandler = {
			query, results, error in
			
			if error != nil {
				// Perform proper error handling here
				println("*** An error occurred while calculating the statistics: \(error.localizedDescription) ***")
				abort()
			}
			
			// Plot the daily step counts over the past 7 days
			results.enumerateStatisticsFromDate(self.startDate, toDate: self.endDate) {
				statistics, stop in
				
				if let quantity = statistics.sumQuantity() {
					let date = statistics.startDate
					let value = quantity.doubleValueForUnit(HKUnit.calorieUnit())
					
					self.addWeekDietaryCaloriesData(value, forDate: date)
				} else if statistics.sumQuantity() == nil {
					// if statistics collection returns no samples for a particular time interval
					let date = statistics.startDate
					let value = 0.0
					self.addWeekDietaryCaloriesData(value, forDate: date)
				}
			}
		}
		self.healthStore?.executeQuery(query)
	}

	
	//creates a collection for plotting the past week in step counts
	func queryPastWeekInSteps() {
//		let calendar = NSCalendar.currentCalendar()
		
//		let interval = NSDateComponents()
//		interval.day = 1
		
		// Set the anchor date to Monday at 12:00 a.m.
//		let anchorComponents = calendar.components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitWeekday, fromDate: NSDate())
//		anchorComponents.hour = 0
		
//		let anchorDate = calendar.dateFromComponents(anchorComponents)
		
		let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
		
		// Create the query
		let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .CumulativeSum,
			anchorDate: anchorDate, intervalComponents: interval)
		
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
			results.enumerateStatisticsFromDate(self.startDate, toDate: self.endDate) {
				statistics, stop in
				
				if let quantity = statistics.sumQuantity() {
					let date = statistics.startDate
					let value = quantity.doubleValueForUnit(HKUnit.countUnit())
					
					self.addWeekStepData(value, forDate: date)
				}
			}
		}
		self.healthStore?.executeQuery(query)
	}
	
	// MARK: Add data points to data structure
	
	func addWeekStepData(value: Double, forDate: NSDate) {
		df.dateStyle = .ShortStyle
		df.timeStyle = .ShortStyle
		weekInStepsPerDay.append(value)
		timeInDays.append(forDate)
		days.append(df.stringFromDate(forDate))
		println("\(df.stringFromDate(forDate)) : \(value)")
	}
	
	func addWeekDistanceData(value: Double, forDate: NSDate) {
		df.dateStyle = .ShortStyle
		df.timeStyle = .ShortStyle
		weekInDistancePerDay.append(value)
		timeInDays.append(forDate)
		println("\(df.stringFromDate(forDate)) : \(value)")
	}
	
	func addWeekFlightsClimbedData(value: Double, forDate: NSDate) {
		df.dateStyle = .ShortStyle
		df.timeStyle = .ShortStyle
		weekInFlightsClimbedPerDay.append(value)
		timeInDays.append(forDate)
		println("\(df.stringFromDate(forDate)) : \(value)")
	}
	
	func addWeekSleepData(value: Double, forDate: NSDate) {
		df.dateStyle = .ShortStyle
		df.timeStyle = .ShortStyle
		weekInSleepPerDay.append(value)
		timeInDays.append(forDate)
		println("\(df.stringFromDate(forDate)) : \(value)")
	}
	
	func addWeekActiveCaloriesData(value: Double, forDate: NSDate) {
		df.dateStyle = .ShortStyle
		df.timeStyle = .ShortStyle
		weekInActiveCaloriesPerDay.append(value)
		timeInDays.append(forDate)
		println("\(df.stringFromDate(forDate)) : \(value)")
	}
	
	func addWeekDietaryCaloriesData(value: Double, forDate: NSDate) {
		df.dateStyle = .ShortStyle
		df.timeStyle = .ShortStyle
		weekInDietaryCaloriesPerDay.append(value)
		timeInDays.append(forDate)
		println("\(df.stringFromDate(forDate)) : \(value)")
	}
	
}