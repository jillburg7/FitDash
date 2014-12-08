//
//  FDDayStats.swift
//  FitDash
//
//  Created by Jillian Burgess on 12/7/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import Foundation
import HealthKit

//day statistics
class FDDayStats: FDHealthData {
	
	// MARK: - class properties
	
	var startTime: NSDate {
		get {
			return NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: endTime, options: nil)!
		}
	}
	var endTime = NSDate()
	var lastUpdatedTime = ""
	
	var dayInSteps = 0.0
	var dayInDistance = 0.0
	var dayInFlightsClimbed = 0.0
	var dayInSleep = ""
	var dayInActiveCalories = 0.0
	var dayInDietaryCalories = 0.0
	
	// MARK: - getters for model data
	
	func getSteps() -> Double {
		return dayInSteps
	}
	func getDistance() -> Double {
		return dayInDistance
	}
	func getFlightsClimbed() -> Double {
		return dayInFlightsClimbed
	}
	func getSleep() -> String {
		return dayInSleep
	}
	func getActiveCalories() -> Double {
		return dayInActiveCalories
	}
	func getDietaryCalories() -> Double {
		return dayInDietaryCalories
	}

	// MARK: - Overrides
	
	override init(store: HKHealthStore) {
		super.init(store: store)
	}
	
	// MARK: - class functions
	
	func queryDayInSteps() {
		
	}
	func queryDayInDistance() {
	
	}
	func queryDayInFlightsClimbed() {
	
	}
	func queryDayInSleep() {
	
	}
	func queryDayInActiveCalories() {
	
	}
	func queryDayInDietaryCalories() {
	
	}
}