//
//  EateriesGridViewController.swift
//  Eatery
//
//  Created by Eric Appel on 11/18/15.
//  Copyright © 2015 CUAppDev. All rights reserved.
//

import UIKit

//enum Section {
//    case North
//    case West
//    case Central
//    
//    func generate(eatery: Eatery) -> Section {
//        switch eatery {
//            
//        }
//    }
//}

class EateriesGridViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var collectionView: UICollectionView!
    private var eateries: [Eatery] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // -- Nav bar
        // TODO: make this a proxy and put it in another file
        navigationController?.view.backgroundColor = UIColor.whiteColor()
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.barTintColor = UIColor.eateryBlue()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 20)!]
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        var collectionViewFrame = view.frame
        collectionViewFrame.size = CGSize(width: collectionViewFrame.width - 20, height: collectionViewFrame.height - 64)
        collectionViewFrame.offsetInPlace(dx: 10, dy: 0)
        
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.registerNib(UINib(nibName: "EateryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        
        view.addSubview(collectionView)
        
        view.backgroundColor = UIColor(white: 0.93, alpha: 1)
        collectionView.backgroundColor = UIColor(white: 0.93, alpha: 1)
        
        loadData()
    }
    
    func loadData() {
        DATA.fetchEateries(false) { (error) -> (Void) in
            print("Fetched data\n")
            dispatch_async(dispatch_get_main_queue(), { [unowned self] () -> Void in
                self.eateries = DATA.eateries
                self.collectionView.reloadData()
                })
        }
    }
    
    // MARK: -
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eateries.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! EateryCollectionViewCell
        
        let eatery = eateries[indexPath.row]
        
        cell.setEatery(eatery)
        
        var displayText = "Closed"
        let now = NSDate()
        if let nextEvent = eatery.activeEventForDate(now) {
            displayText = "Open " + displayTextForEvent(nextEvent)
        }
        cell.statusLabel.text = displayText
        
        return cell
    }
    
    // MARK: -
    // MARK: UICollectionViewDelegate
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("did select")
        
        let eatery = eateries[indexPath.row]
        
        let detailViewController = MenuViewController()
        detailViewController.eatery = eatery
        self.navigationController?.pushViewController(detailViewController, animated: true)

    }
    
    // MARK: -
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.frame.width / 2
        return CGSize(width: width - 2, height: 190)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }

}
