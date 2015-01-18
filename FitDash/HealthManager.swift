//
//  HealthManager.swift
//  FitDash
//
//  Created by Jillian Burgess on 1/17/15.
//  Copyright (c) 2015 Jillian Burgess. All rights reserved.
//

import HealthKit
import Foundation

class HealthManager {
	
	let healthKitStore:HKHealthStore = HKHealthStore()
	
	//MARK: HealthKit Permissions
	
	func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!) {
		let healthKitTypesToWrite =  NSSet(array: [
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass),
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed),
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned),
			HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
		])
	
	
		let healthKitTypesToRead =  NSSet(array: [
			//workouts
			HKWorkoutType.workoutType(),
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
		])
		
		// 3. If the store is not available (for instance, iPad) return an error and don't go on.
		if !HKHealthStore.isHealthDataAvailable() {
			let error = NSError(domain: "com.raywenderlich.tutorials.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
			if completion != nil {
				completion(success:false, error:error)
			}
			return;
		}
		
		// 4.  Request HealthKit authorization
		healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: healthKitTypesToRead) {
			(success, error) -> Void in
			if completion != nil {
				completion(success:success,error:error)
			}
		}
	}

}