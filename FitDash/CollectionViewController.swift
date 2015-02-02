//
//  CollectionViewController.swift
//  FitDash
//
//  Created by Jillian Burgess on 11/28/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import UIKit
import HealthKit

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
	
	// MARK: Class properties
	var selected = ""
	var timePeriod: String?
	
	var collectionItems = ["Steps", "Distance", "Flights Climbed", "Sleep", "Active Calories", "Dietary Calories"]
	var segueID = ["barChartView", "barChartView", "barChartView", "barChartView", "barChartView", "barChartView"]
	
	var healthManager:HealthManager?
	
	var endDate = NSDate()
	let calendar = NSCalendar.currentCalendar()
	var queryParams: (startDate:NSDate?, predicate:NSPredicate?, anchorDate:NSDate?, interval:NSDateComponents?)
	
	var steps = ([NSDate](), [Double]())
	//	var steps = ([NSDate](), [HKQuantity]())
	var distance = ([NSDate](), [Double]())
	var flightsClimbed = ([NSDate](), [Double]())
	var sleep = ([NSDate](), [Double]())
	var activeCal = ([NSDate](), [Double]())
	var dietaryCal = ([NSDate](), [Double]())
	
	// MARK: - Overrides
	
    override func viewDidLoad() {
        super.viewDidLoad()
         self.clearsSelectionOnViewWillAppear = true
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	

	// MARK: - Setup Statistic Collection Queries
	
	// initializes model data depending on the string was passed in denoting the class to use for function calls
	func setup(objType: String) {
		var components: (NSDateComponents, NSDate)
		if objType == "day" {
			timePeriod = "hourly"
			queryParams.startDate = NSCalendar.currentCalendar().dateBySettingHour(0, minute: 0, second: 0, ofDate: endDate, options: nil)!
			components = setQueryDateComponents(1, intervalDay: 0,anchorHour: 0)
		} else {
			timePeriod = "weekly"
			queryParams.startDate = NSCalendar.currentCalendar().dateByAddingUnit(.DayCalendarUnit, value: -7, toDate: endDate, options: nil)!
			components = setQueryDateComponents(0, intervalDay: 1, anchorHour: 0)
		}
		queryParams.interval = components.0
		queryParams.anchorDate = components.1
		queryParams.predicate =  HKQuery.predicateForSamplesWithStartDate(queryParams.startDate, endDate: endDate, options: .None)
		updateStepQuery()
		updateDistance()
		updateFlightsClimbed()
		updateActiveCalories()
		updateDietaryCalories()
		updateSleep()
	}
	
	private func setQueryDateComponents(intervalHour:Int, intervalDay:Int, anchorHour:Int) -> (NSDateComponents, NSDate) {
		let interval = NSDateComponents()
		interval.hour = intervalHour //1
		interval.day = intervalDay //1
		
		var anchorComponents = calendar.components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitWeekday, fromDate: endDate)
		anchorComponents.hour = anchorHour //0
		let anchorDate = calendar.dateFromComponents(anchorComponents)!
		return (interval, anchorDate)
	}
	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
		if segue.identifier == "barChartView" {
			var chartDetails = segue.destinationViewController as BarChartViewController
			chartDetails.tupleData = ([],[])
			
			if timePeriod == "weekly" {
				if selected == "Steps" {
					chartDetails.tupleData = self.steps
					chartDetails.dataTitle = "Week In Steps"
				} else if selected == "Distance" {
					chartDetails.tupleData = self.distance
					chartDetails.dataTitle = "Week in Distance"
				} else if selected == "Flights Climbed" {
					chartDetails.tupleData = self.flightsClimbed
					chartDetails.dataTitle = "Week in Flights Climbed"
				} else if selected == "Sleep" {
//					chartDetails.tupleData = self.sleep
//					chartDetails.tupleData = (self.healthData as WeekStatsPerDay).getWeekInSleepPerDay()
					chartDetails.dataTitle = "Week in Sleep"
				} else if selected == "Active Calories" {
					chartDetails.tupleData = self.activeCal
					chartDetails.dataTitle = "Week in Active Calories"
				} else if selected == "Dietary Calories" {
					chartDetails.tupleData = self.dietaryCal
					chartDetails.dataTitle = "Week in Dietary Calories"
				}
			} else if timePeriod == "hourly" {
				if selected == "Steps" {
					chartDetails.tupleData = self.steps
					chartDetails.dataTitle = "Day In Steps"
				} else if selected == "Distance" {
					chartDetails.tupleData = self.distance
					chartDetails.dataTitle = "Day in Distance"
				} else if selected == "Flights Climbed" {
				chartDetails.tupleData = self.flightsClimbed
					chartDetails.dataTitle = "Day in Flights Climbed"
				} else if selected == "Sleep" {
				//					chartDetails.tupleData = self.sleep
					//				chartDetails.tupleData = (self.healthData as DayStatsPerHour).getDayInSleepPerHour()
					chartDetails.dataTitle = "Day in Sleep"
				} else if selected == "Active Calories" {
					chartDetails.tupleData = self.activeCal
					chartDetails.dataTitle = "Day in Active Calories"
				} else if selected == "Dietary Calories" {
					chartDetails.tupleData = self.dietaryCal
					chartDetails.dataTitle = "Day in Dietary Calories"
				}
			}
			chartDetails.title = selected
		}
	}
	
	
	// MARK: - Query Setup & breakdown
	
	func updateStepQuery() {
		let quantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
	
		self.healthManager?.queryWeekInSamples(quantityType, startDate: self.queryParams.startDate, predicate: self.queryParams.predicate, anchorDate: self.queryParams.anchorDate, interval: self.queryParams.interval, completion: {
			(results, error) in
			
			if error != nil {
				println("Error reading steps from HealthKit Store: \(error.localizedDescription)")
				return
			}
			
			// Keep data and update in main thread
			dispatch_async(dispatch_get_main_queue(), {
				() -> Void in
				var statisticObj = results as? HKStatistics
				self.steps.0.append(statisticObj!.startDate)
				if let quantity = statisticObj!.sumQuantity() {
					self.steps.1.append(quantity.doubleValueForUnit(HKUnit.countUnit()))
				} else if statisticObj!.sumQuantity() == nil {
					self.steps.1.append(0.0)
				}
			})
		})
	}
	
	func updateDistance() {
		// Construct an HKQuantityType for Distance Walking Running
		let quantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)
		
		self.healthManager?.queryWeekInSamples(quantityType, startDate: self.queryParams.startDate, predicate: self.queryParams.predicate, anchorDate: self.queryParams.anchorDate, interval: self.queryParams.interval, completion: {
			(results, error) in
			
			if error != nil {
				println("Error reading steps from HealthKit Store: \(error.localizedDescription)")
				return
			}
			
			// Keep data and update in main thread
			dispatch_async(dispatch_get_main_queue(), {
				() -> Void in
				var statisticObj = results as? HKStatistics
				self.distance.0.append(statisticObj!.startDate)
				if let quantity = statisticObj!.sumQuantity() {
					self.distance.1.append(quantity.doubleValueForUnit(HKUnit.mileUnit()))
				} else if statisticObj!.sumQuantity() == nil {
					self.distance.1.append(0.0)
				}
			})
		})
	}

	func updateFlightsClimbed() {
		// Construct an HKQuantityType for Flights Climbed
		let quantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)
		
		self.healthManager?.queryWeekInSamples(quantityType, startDate: self.queryParams.startDate, predicate: self.queryParams.predicate, anchorDate: self.queryParams.anchorDate, interval: self.queryParams.interval, completion: {
			(results, error) in
			
			if error != nil {
				println("Error reading steps from HealthKit Store: \(error.localizedDescription)")
				return
			}
			
			// Keep data and update in main thread
			dispatch_async(dispatch_get_main_queue(), {
				() -> Void in
				var statisticObj = results as? HKStatistics
				self.flightsClimbed.0.append(statisticObj!.startDate)
				if let quantity = statisticObj!.sumQuantity() {
					self.flightsClimbed.1.append(quantity.doubleValueForUnit(HKUnit.countUnit()))
				} else if statisticObj!.sumQuantity() == nil {
					self.flightsClimbed.1.append(0.0)
				}
			})
		})
	}
	
	func updateActiveCalories() {
		// Construct an HKQuantityType for Active Calories
		let quantityType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)
		
		self.healthManager?.queryWeekInSamples(quantityType, startDate: self.queryParams.startDate, predicate: self.queryParams.predicate, anchorDate: self.queryParams.anchorDate, interval: self.queryParams.interval, completion: {
			(results, error) in
			
			if error != nil {
				println("Error reading steps from HealthKit Store: \(error.localizedDescription)")
				return
			}
			
			// Keep data and update in main thread
			dispatch_async(dispatch_get_main_queue(), {
				() -> Void in
				var statisticObj = results as? HKStatistics
				self.activeCal.0.append(statisticObj!.startDate)
				if let quantity = statisticObj!.sumQuantity() {
					self.activeCal.1.append(quantity.doubleValueForUnit(HKUnit.calorieUnit()))
				} else if statisticObj!.sumQuantity() == nil {
					self.activeCal.1.append(0.0)
				}
			})
		})
	}
	
	func updateDietaryCalories() {
		// Construct an HKQuantityType for Dietary Calories
		let quantityType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDietaryEnergyConsumed)
		
		self.healthManager?.queryWeekInSamples(quantityType, startDate: self.queryParams.startDate, predicate: self.queryParams.predicate, anchorDate: self.queryParams.anchorDate, interval: self.queryParams.interval, completion: {
			(results, error) in
			
			if error != nil {
				println("Error reading steps from HealthKit Store: \(error.localizedDescription)")
				return
			}
			
			// Keep data and update in main thread
			dispatch_async(dispatch_get_main_queue(), {
				() -> Void in
				var statisticObj = results as? HKStatistics
				self.dietaryCal.0.append(statisticObj!.startDate)
				if let quantity = statisticObj!.sumQuantity() {
					self.dietaryCal.1.append(quantity.doubleValueForUnit(HKUnit.calorieUnit()))
				} else if statisticObj!.sumQuantity() == nil {
					self.dietaryCal.1.append(0.0)
				}
			})
		})
	}
	
	func updateSleep() {
		// 1. Construct an HKQuantityType for Flights Climbed
		/*
		let quantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierFlightsClimbed)
		
		self.healthManager?.queryWeekInSamples(quantityType, startDate: self.queryParams.startDate, predicate: self.queryParams.predicate, anchorDate: self.queryParams.anchorDate, interval: self.queryParams.interval, completion: {
		(results, error) in
		
		if error != nil {
		println("Error reading steps from HealthKit Store: \(error.localizedDescription)")
		return
		}
		
		//Keep steps and refresh tableview in main thread
		dispatch_async(dispatch_get_main_queue(), {
		() -> Void in
		var statisticObj = results as? HKStatistics
		// Keep the daily step counts over the past 7 days
		if let quantity = statisticObj!.sumQuantity() {
		self.flightsClimbed.0.append(statisticObj!.startDate)
		self.flightsClimbed.1.append(quantity.doubleValueForUnit(HKUnit.countUnit()))
		}
		})
		})
		*/
	}
	
	
    // MARK: UICollectionViewDataSource

	// Return the number of sections
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

	//Return the number of items in the section
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionItems.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = self.collectionView!.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as CollectionViewCell
    
        // Configure the cell
		cell.backgroundColor = navyBlue
		cell.label.text = self.collectionItems[indexPath.item]
		
        return cell
	}
	
	/*
	override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		println("You selected collectionView cell \(self.collectionItems[indexPath.item])")
	}
	*/
	
	
	override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
		//1
		switch kind {
		case UICollectionElementKindSectionHeader:
			let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "CollectionHeaderView", forIndexPath: indexPath) as CollectionHeaderView
			headerView.label.text = "header text"
			return headerView
		default:
			assert(false, "Unexpected element kind")
		}
	}
	

    // MARK: UICollectionViewDelegate

    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
	
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
		println("You selected collectionView cell \(self.collectionItems[indexPath.item])")
		selected = self.collectionItems[indexPath.item]
		return true
    }

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
	
	
	// MARK: UICollectionViewDelegateFlowLayout
 
	func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
		let square = (view.frame.size.width / 2) - 30
		return CGSize(width: square, height: square)
	}
	
	func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 10.0, left: 20.0, bottom: 30.0, right: 20.0)
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
		return 20.0
	}
	
}
