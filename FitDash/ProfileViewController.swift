//
//  ProfileViewController.swift
//  FitDash
//
//  Created by Jillian Burgess on 1/19/15.
//  Copyright (c) 2015 Jillian Burgess. All rights reserved.
//

import UIKit
import HealthKit

class ProfileViewController: UITableViewController {
	
	let UpdateProfileInfoSection = 2
	let SaveBMISection = 3
	let kUnknownString   = "Unknown"
	
	@IBOutlet var ageLabel:UILabel!
	@IBOutlet var bloodTypeLabel:UILabel!
	@IBOutlet var biologicalSexLabel:UILabel!
	@IBOutlet var weightLabel:UILabel!
	@IBOutlet var heightLabel:UILabel!
	@IBOutlet var bmiLabel:UILabel!
	
	var healthManager:HealthManager?
	var bmi:Double?
	var height, weight:HKQuantitySample?
	
	
	// MARK: - Formatters
	lazy var dateFormatter:NSDateFormatter = {
		
		let formatter = NSDateFormatter()
		formatter.timeStyle = .ShortStyle
		formatter.dateStyle = .MediumStyle
		return formatter
		
		}()
	
	let durationFormatter = NSDateComponentsFormatter()
	let energyFormatter = NSEnergyFormatter()
	let distanceFormatter = NSLengthFormatter()

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		updateHealthInfo()
	}
	
	func updateHealthInfo() {
		updateProfileInfo()
		updateWeight()
		updateHeight()
	}
	
	
	func updateProfileInfo() {
		let profile = healthManager?.readProfile()
		
		ageLabel.text = profile?.age == nil ? kUnknownString : String(profile!.age!)
		biologicalSexLabel.text = biologicalSexLiteral(profile?.biologicalsex?.biologicalSex)
		bloodTypeLabel.text = bloodTypeLiteral(profile?.bloodtype?.bloodType)
	}
	
	func updateHeight() {
		// 1. Construct an HKSampleType for Height
		let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight)
		
		// 2. Call the method to read the most recent Height sample
		self.healthManager?.readMostRecentSample(sampleType, completion: {
			(mostRecentHeight, error) -> Void in
			
			if error != nil {
				println("Error reading height from HealthKit Store: \(error.localizedDescription)")
				return
			}
			
			var heightLocalizedString = self.kUnknownString
			self.height = mostRecentHeight as? HKQuantitySample
			// 3. Format the height to display it on the screen
			if let meters = self.height?.quantity.doubleValueForUnit(HKUnit.meterUnit()) {
				let heightFormatter = NSLengthFormatter()
				heightFormatter.forPersonHeightUse = true
				heightLocalizedString = heightFormatter.stringFromMeters(meters)
			}
			
			
			// 4. Update UI. HealthKit use an internal queue. We make sure that we interact with the UI in the main thread
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.heightLabel.text = heightLocalizedString
				self.updateBMI()
			})
		})
	}
	
	func updateWeight() {
		// 1. Construct an HKSampleType for weight
		let sampleType = HKSampleType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass)
		
		// 2. Call the method to read the most recent weight sample
		self.healthManager?.readMostRecentSample(sampleType, completion: {
			(mostRecentWeight, error) -> Void in
			
			if error != nil {
				println("Error reading weight from HealthKit Store: \(error.localizedDescription)")
				return
			}
			
			var weightLocalizedString = self.kUnknownString
			// 3. Format the weight to display it on the screen
			self.weight = mostRecentWeight as? HKQuantitySample
			if let kilograms = self.weight?.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo)) {
				let weightFormatter = NSMassFormatter()
				weightFormatter.forPersonMassUse = true
				weightLocalizedString = weightFormatter.stringFromKilograms(kilograms)
			}
			
			// 4. Update UI in the main thread
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.weightLabel.text = weightLocalizedString
				self.updateBMI()
			})
		})
	}
	
	func updateBMI() {
		if weight != nil && height != nil {
			// 1. Get the weight and height values from the samples read from HealthKit
			let weightInKilograms = weight!.quantity.doubleValueForUnit(HKUnit.gramUnitWithMetricPrefix(.Kilo))
			let heightInMeters = height!.quantity.doubleValueForUnit(HKUnit.meterUnit())
			// 2. Call the method to calculate the BMI
			bmi  = calculateBMIWithWeightInKilograms(weightInKilograms, heightInMeters: heightInMeters)
		}
		// 3. Show the calculated BMI
		var bmiString = kUnknownString
		if bmi != nil {
			bmiLabel.text =  NSString(format: "%.02f", bmi!)
		}
	}
	
	func saveBMI() {
		// Save BMI value with current BMI value
		if bmi != nil {
			healthManager?.saveBMISample(bmi!, date: NSDate())
		}
		else {
			println("There is no BMI data to save")
		}
	}
	
	// MARK: - utility methods
	func calculateBMIWithWeightInKilograms(weightInKilograms:Double, heightInMeters:Double) -> Double? {
		if heightInMeters == 0 {
			return nil
		}
		return (weightInKilograms/(heightInMeters*heightInMeters))
	}
	
	
	func biologicalSexLiteral(biologicalSex:HKBiologicalSex?) -> String {
		var biologicalSexText = kUnknownString
		
		if  biologicalSex != nil {
			switch( biologicalSex! ) {
			case .Female:
				biologicalSexText = "Female"
			case .Male:
				biologicalSexText = "Male"
			default:
				break
			}
		}
		return biologicalSexText
	}
	
	func bloodTypeLiteral(bloodType:HKBloodType?) -> String {
		var bloodTypeText = kUnknownString
		
		if bloodType != nil {
			switch( bloodType! ) {
			case .APositive:
				bloodTypeText = "A+"
			case .ANegative:
				bloodTypeText = "A-"
			case .BPositive:
				bloodTypeText = "B+"
			case .BNegative:
				bloodTypeText = "B-"
			case .ABPositive:
				bloodTypeText = "AB+"
			case .ABNegative:
				bloodTypeText = "AB-"
			case .OPositive:
				bloodTypeText = "O+"
			case .ONegative:
				bloodTypeText = "O-"
			default:
				break
			}
		}
		return bloodTypeText
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath , animated: true)
		
		switch (indexPath.section, indexPath.row) {
		case (UpdateProfileInfoSection,0):
			updateHealthInfo()
		case (SaveBMISection,0):
			saveBMI()
		default:
			break
		}
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false
		
		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		// self.navigationItem.rightBarButtonItem = self.editButtonItem()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Table view data source
	
	/*
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		// #warning Potentially incomplete method implementation.
		// Return the number of sections.
		return 0
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete method implementation.
		// Return the number of rows in the section.
		return 0
	}
	*/
	
	/*
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
	let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell
	
	// Configure the cell...
	
	return cell
	}
	*/
	
	/*
	// Override to support conditional editing of the table view.
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
	// Return NO if you do not want the specified item to be editable.
	return true
	}
	*/
	
	/*
	// Override to support editing the table view.
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
	if editingStyle == .Delete {
	// Delete the row from the data source
	tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
	} else if editingStyle == .Insert {
	// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
	}
	}
	*/
	
	/*
	// Override to support rearranging the table view.
	override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
	
	}
	*/
	
	/*
	// Override to support conditional rearranging of the table view.
	override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
	// Return NO if you do not want the item to be re-orderable.
	return true
	}
	*/
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	// Get the new view controller using [segue destinationViewController].
	// Pass the selected object to the new view controller.
	}
	*/
	
}
