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
	
	func saveBMISample(bmi:Double, date:NSDate ) {
		// 1. Create a BMI Sample
		let bmiType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex)
		let bmiQuantity = HKQuantity(unit: HKUnit.countUnit(), doubleValue: bmi)
		let bmiSample = HKQuantitySample(type: bmiType, quantity: bmiQuantity, startDate: date, endDate: date)
		
		// 2. Save the sample in the store
		healthKitStore.saveObject(bmiSample, withCompletion: { (success, error) -> Void in
			if error != nil  {
				println("Error saving BMI sample: \(error.localizedDescription)")
			} else {
				println("BMI sample saved successfully!")
			}
		})
	}
	
	func saveRunningWorkout(startDate:NSDate , endDate:NSDate , distance:Double, distanceUnit:HKUnit , kiloCalories:Double, completion: (
		(Bool, NSError!) -> Void)!) {
			
			// 1. Create quantities for the distance and energy burned
			let distanceQuantity = HKQuantity(unit: distanceUnit, doubleValue: distance)
			let caloriesQuantity = HKQuantity(unit: HKUnit.kilocalorieUnit(), doubleValue: kiloCalories)
			
			// 2. Save Running Workout
			let workout = HKWorkout(activityType: HKWorkoutActivityType.Running, startDate: startDate, endDate: endDate, duration: abs(endDate.timeIntervalSinceDate(startDate)), totalEnergyBurned: caloriesQuantity, totalDistance: distanceQuantity, metadata: nil)
			
			healthKitStore.saveObject(workout, withCompletion: {
				(success, error) -> Void in
				
				if( error != nil  ) {
					// Error saving the workout
					completion(success,error)
				}
				else {
					// if success, then save the associated samples so that they appear in the HealthKit
					let distanceSample = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning), quantity: distanceQuantity, startDate: startDate, endDate: endDate)
					let caloriesSample = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned), quantity: caloriesQuantity, startDate: startDate, endDate: endDate)
					
					self.healthKitStore.addSamples([distanceSample,caloriesSample], toWorkout: workout, completion: {
						(success, error ) -> Void in
						completion(success, error)
					})
				}
				
			})
	}
	
	
	func readRunningWorkouts(completion: (([AnyObject]!, NSError!) -> Void)!) {
		// 1. Predicate to read only running workouts
		let predicate =  HKQuery.predicateForWorkoutsWithWorkoutActivityType(HKWorkoutActivityType.Running)
		// 2. Order the workouts by date
		let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
		// 3. Create the query
		let sampleQuery = HKSampleQuery(sampleType: HKWorkoutType.workoutType(), predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor])
			{ (sampleQuery, results, error ) -> Void in
				
				if let queryError = error {
					println( "There was an error while reading the samples: \(queryError.localizedDescription)")
				}
				completion(results,error)
		}
		// 4. Execute the query
		healthKitStore.executeQuery(sampleQuery)
	}
}