//
//  CollectionViewController.swift
//  FitDash
//
//  Created by Jillian Burgess on 11/28/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import UIKit


class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
	
	// MARK: Class properties
	var healthData: HealthData?
	var selected = ""
	
	var collectionItems = ["Steps", "Distance", "Flights Climbed", "Sleep", "Active Calories", "Dietary Calories"]
	var segueID = ["barChartView", "barChartView", "barChartView", "barChartView", "barChartView", "barChartView"] //bemGraphView
	
	// MARK: - Overrides
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = true

        // Register cell classes
//        self.collectionView!.registerClass(CollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// MARK: - Setup Statistic Collection Queries
	
	// initializes model data depending on the string was passed in denoting the class to use for function calls
	func setup(objType: String) {
		// TODO: add other Model classes
		if objType == "day" {
			(healthData as DayStatsPerHour).startQueries()
		} else if objType == "week" {
			(healthData as WeekStatsPerDay).startQueries()
		}
	}
	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
		if segue.identifier == "barChartView" {
			var chartDetails = segue.destinationViewController as BarChartViewController
			chartDetails.tupleData = ([],[])
			
			if healthData is WeekStatsPerDay {
				if selected == "Steps" {
					chartDetails.tupleData = (self.healthData as WeekStatsPerDay).getWeekInStepsPerDay()
					chartDetails.dataTitle = "Week In Steps"
				} else if selected == "Distance" {
					chartDetails.tupleData = (self.healthData as WeekStatsPerDay).getWeekInDistancePerDay()
					chartDetails.dataTitle = "Week in Distance"
				} else if selected == "Flights Climbed" {
					chartDetails.tupleData = (self.healthData as WeekStatsPerDay).getWeekInFlightsClimbedPerDay()
					chartDetails.dataTitle = "Week in Flights Climbed"
				} else if selected == "Sleep" {
					chartDetails.tupleData = (self.healthData as WeekStatsPerDay).getWeekInSleepPerDay()
					chartDetails.dataTitle = "Week in Sleep"
				} else if selected == "Active Calories" {
					chartDetails.tupleData = (self.healthData as WeekStatsPerDay).getWeekInActiveCaloriesPerDay()
					chartDetails.dataTitle = "Week in Active Calories"
				} else if selected == "Dietary Calories" {
					chartDetails.tupleData = (self.healthData as WeekStatsPerDay).getWeekInDietaryCaloriesPerDay()
					chartDetails.dataTitle = "Week in Dietary Calories"
				}
			} else if healthData is DayStatsPerHour {
				if selected == "Steps" {
					chartDetails.tupleData = (self.healthData as DayStatsPerHour).getDayInStepsPerHour()
					chartDetails.dataTitle = "Day In Steps"
				} else if selected == "Distance" {
					chartDetails.tupleData = (self.healthData as DayStatsPerHour).getDayInDistancePerHour()
					chartDetails.dataTitle = "Day in Distance"
				} else if selected == "Flights Climbed" {
					chartDetails.tupleData = (self.healthData as DayStatsPerHour).getDayInFlightsClimbedPerHour()
					chartDetails.dataTitle = "Day in Flights Climbed"
				} else if selected == "Sleep" {
					chartDetails.tupleData = ([NSDate()],[0.0])
					//				chartDetails.tupleData = (self.healthData as DayStatsPerHour).getDayInSleepPerHour()
					chartDetails.dataTitle = "Day in Sleep"
				} else if selected == "Active Calories" {
					chartDetails.tupleData = (self.healthData as DayStatsPerHour).getDayInActiveCaloriesPerHour()
					chartDetails.dataTitle = "Day in Active Calories"
				} else if selected == "Dietary Calories" {
					chartDetails.tupleData = (self.healthData as DayStatsPerHour).getDayInDietaryCaloriesPerHour()
					chartDetails.dataTitle = "Day in Dietary Calories"
				}
			}
			
			chartDetails.title = selected
		}
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
	
	/*
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
	*/

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
