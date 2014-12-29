//
//  HKHealthStoreExtension.swift
//  FitDash
//
//  Created by Jillian Burgess on 10/12/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//
//
//  HKHealthStore+AAPLExtensions.swift
//  HealthKit~Swift
//
//  Created by EdenLi on 2014/9/17.
//  Copyright (c) 2014年 Darktt Personal Company. All rights reserved.
//
//		Abstract:
//
//		Contains shared helper methods on HKHealthStore that are specific to Fit's use cases.

import Foundation
import HealthKit

typealias HKCompletionHandle = ((HKQuantity!, NSError!) -> Void!)

extension HKHealthStore {
	
	func getClassName(obj : AnyObject) -> String {
		let objectClass : AnyClass! = object_getClass(obj)
		let className = objectClass.description()
		
		return className
	}
	
	func mostRecentQuantitySampleOfType(quantityType: HKQuantityType, predicate: NSPredicate!, completion: HKCompletionHandle!) -> Void {
		
		var timeSortDescriptor: NSSortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
		
		// Since we are interested in retrieving the user's latest sample, we sort the samples in descending order, and set the limit to 1. We are not filtering the data, and so the predicate is set to nil.
		let query: HKSampleQuery = HKSampleQuery(sampleType: quantityType, predicate: nil, limit: 1, sortDescriptors: [timeSortDescriptor]) {
			(query, results, error) -> Void in
			
			if results == nil {
				if completion != nil {
					completion(nil, error)
				}
				
				return
			}
			
			if completion != nil {
				
				// If quantity isn't in the database, return nil in the completion block.
				var quantitySample: HKQuantitySample? = results.last as HKQuantitySample?
				var quantity: HKQuantity? = quantitySample?.quantity
				
				completion(quantity, error)
			}
		}
		
		self.executeQuery(query)
	}
	
	
	//MARK: - Private Method
	//MARK: HealthKit Permissions

	func dataTypesToWrite() -> NSSet {
		let dataTypesToWrite = [
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass),
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed),
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned),
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
		]
		return NSSet(array: dataTypesToWrite)
	}
	
	func dataTypesToRead() -> NSSet {
		let dataTypesToRead = [
			//workouts
			HKWorkoutType.workoutType(),
//			HKWorkoutType.quantityTypeForIdentifier(HKWorkoutTypeIdentifier),
			//fitness
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount),
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning),
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed),
			//sleep
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

}
