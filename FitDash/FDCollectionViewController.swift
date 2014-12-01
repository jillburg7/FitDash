//
//  FDCollectionViewController.swift
//  FitDash
//
//  Created by Jillian Burgess on 11/28/14.
//  Copyright (c) 2014 Jillian Burgess. All rights reserved.
//

import UIKit

class FDCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
	
//	let reuseIdentifier = "Cell"
	var collectionItems = ["Steps", "Distance", "Flights Climbed", "Sleep", "Active Calories"]
	var segueID = ["barChartView", "barChartView", "barChartView", "barChartView", "barChartView"] //bemGraphView
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = true

        // Register cell classes
//        self.collectionView!.registerClass(FDCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
		if segue.identifier == "barChartView" {
			var chartDetails = segue.destinationViewController as FDBarChartViewController
			println("sender: \(sender.description)")
			
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
		let cell = self.collectionView!.dequeueReusableCellWithReuseIdentifier("FDCollectionViewCell", forIndexPath: indexPath) as FDCollectionViewCell
    
        // Configure the cell
		cell.backgroundColor = navyBlue
		cell.label.text = self.collectionItems[indexPath.item]
		
        return cell
	}
	
	override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		println("You selected collectionView cell \(self.collectionItems[indexPath.item])")
	}
	
	/*
	override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
		//1
		switch kind {
		case UICollectionElementKindSectionHeader:
			let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "FDCollectionHeaderView", forIndexPath: indexPath) as FDCollectionHeaderView
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
    
	/*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
	*/

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
	
	private let sectionInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 30.0, right: 20.0)
 
	func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
		return sectionInsets
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
		return 20.0
	}
	
}
