//
//  FDBaseViewController.swift
//  FitDash
//
//  Created by Jillian Burgess on 11/2/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import UIKit
import HealthKit

class FDBaseViewController: UIViewController {
	
	var healthStore: HKHealthStore?
	var tupleData: ([NSDate], [Double]) = ([],[])
	
	var steps = 0.0
	var distance = 0.0
	var flightsClimbed = 0.0
//
	var values: [Double] = []
	var dates: [NSDate] = []
//
	var midnight = NSDate()
	var startTime24HourData = NSDate()
	var now = NSDate()
	var numberOfPoints:Int = 0
//
//	var ready = false
	
	@IBOutlet var ageLabel: UILabel!
	@IBOutlet var dataRefreshLabel: UILabel!
	@IBOutlet var stepsLabel: UILabel!
	@IBOutlet var distanceLabel: UILabel!
	@IBOutlet var flightsClimbedLabel: UILabel!
	@IBOutlet var sleepLabel: UILabel!
	
	@IBAction func refresh(sender: AnyObject) {
		values.removeAll(keepCapacity: false)
		dates.removeAll(keepCapacity: false)
//		getData()
	}
	
	// MARK: - Overrides
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let df = NSDateFormatter()
		df.dateStyle = .ShortStyle
		df.timeStyle = .MediumStyle

		self.dataRefreshLabel.text = "Updated: \(df.stringFromDate(self.now))"
		self.stepsLabel.text = "Step Count:  \(self.steps) steps"
		// Do any additional setup after loading the view.
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
