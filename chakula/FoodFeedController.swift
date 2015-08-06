//
//  ViewController.swift
//  chakula
//
//  Created by Agree Ahmed on 7/11/15.
//  Copyright (c) 2015 org.rhye. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class FoodFeedController: UIViewController, UITableViewDataSource, UITableViewDelegate, FeedAPIProtocol, CLLocationManagerDelegate {
    // TODO: figure out flow based off of location availability
    /*
        open app
        try to get location
        if you don't have lovarion, load the last known location (?)
        if you don't have the last known location, show an error message (?)
    */
    var manager: CLLocationManager!
    var currentCoord: CLLocationCoordinate2D!
    // Registration and Login interface components
    var userApi: UserAPIController!
    var userData: UserData?
    var refreshControl:UIRefreshControl!
    
    var foodItems = [FoodItem]()
    let kCellIdentifier: String = "foodCell"
    var feedApi : FeedAPIController!
    @IBOutlet weak var foodList: UITableView!
    var imgCache = [String:UIImage]()
    var labelColor = UIColor.whiteColor()
    let outputFormatter = NSDateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("About to invoke feedAPI")
        feedApi = FeedAPIController(delegate: self)
        print("About to invoke userAPI")
        userApi = UserAPIController()
        userData = userApi.getUserData()
        print("About to invoke location manager")
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Refreshing")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.foodList.addSubview(refreshControl)
        manager = CLLocationManager()
        if #available(iOS 8.0, *) {
            manager.requestWhenInUseAuthorization()
        } else {
            // Fallback on earlier versions
        }
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        print("session manager handled")

        print("firstname lastname password handled")

        outputFormatter.dateFormat = "hh':'mm"
        outputFormatter.locale = NSLocale(localeIdentifier: "en_US")
        print("setup titles handled")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        feedApi.findFood()
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
//        for cell in self.foodList.visibleCells as! [FoodFeedCell] {
//            cell.truckName.sizeToFit()
//            let oldFrame = cell.truckName.frame
//            let newWidth = oldFrame.size.width + 40
//            let newOrigin = CGPoint(x: oldFrame.origin.x + 40, y: oldFrame.origin.y)
//            var newSize = CGSize(width: newWidth,height: cell.truckName.frame.size.height)
//            cell.truckName.sizeToFit()
//            // TODO: Get frame right
////            cell.truckName.frame = CGRect(origin: newOrigin, size: newSize)
//        }
    }
    
    func locationManager(manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]){
        let location = locations.last as CLLocation!
        feedApi.updateLocation(location.coordinate)
        print(location)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    }
    
    func refresh(sender:AnyObject) {
        feedApi.findFood()
    }
    
    func didReceiveAPIResults(foodItems: [FoodItem]) {
        print("FOOD ITEMS SIZE: \(foodItems.count)")
        dispatch_async(dispatch_get_main_queue(), {
            self.foodItems = foodItems
            if(self.foodItems.count != 0) {
                self.foodList!.reloadData()
            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.refreshControl.endRefreshing()
        })

    }
    
    func queryFailed(){
        dispatch_async(dispatch_get_main_queue(), {
                // TODO: Show error message on feed
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.setFeedMessage("No network connection :(")
            self.refreshControl.endRefreshing()
        })
    }
    
    func setFeedMessage(message: String){
        let messageLabel = UILabel(frame: CGRectMake(30, 0, self.foodList.bounds.size.width - 30, self.foodList.bounds.size.height))
        messageLabel.text = message
        messageLabel.sizeToFit()
        messageLabel.textAlignment = .Center
        foodList.backgroundView = messageLabel
        foodList.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (foodItems.count != 0) {
            foodList.separatorStyle = UITableViewCellSeparatorStyle.SingleLine;
        } else {
            setFeedMessage("Couldn't find any food nearby :/")
        }
        
        return foodItems.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let (cell, imgURL) = setUpCell(tableView, indexPath: indexPath)
        print("Entered TableView")
        if let img = self.imgCache[imgURL] {
            print("adding image to cache")
            cell.foodImage!.image = img
        } else if let url = NSURL(string: imgURL){
            let request = NSURLRequest(URL: url)
            print("Entered TableView first else")
            print("imgURL: \(imgURL)")
            let mainQueue = NSOperationQueue.mainQueue()
            print("About to enter the asnc request")
            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    print("Got to the async request completion!")
                    let image = UIImage(data: data!)
                    self.imgCache[imgURL] = image
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? FoodFeedCell {
                            print("Got 'Cell to update!'")
                                cellToUpdate.foodImage!.image = image
                            }
                        })
                    } else {
                        print("found error")
                        print("Error: \(error!.localizedDescription)")
                    }
                })
            }
        return cell
    }
    
    private func setUpCell(tableView: UITableView, indexPath: NSIndexPath) -> (FoodFeedCell, String) {
        print("In set up cell")
        let cell: FoodFeedCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! FoodFeedCell
        let foodItem = self.foodItems[indexPath.row]
        cell.foodTitle?.text = foodItem.name!
        cell.foodPrice?.text = "$\(foodItem.price!)"
        cell.foodImage?.image = UIImage(named: "pacman.png")
        cell.truckName?.text = foodItem.truck!.name
        if foodItem.truck!.dist < 0.1 {
            cell.distance?.text = "here!"
        } else {
            cell.distance?.text = "\(foodItem.truck!.dist)mi"
        }
//        cell.truckName?.translatesAutoresizingMaskIntoConstraints
//        cell.truckName?.sizeToFit()
        print("width: \(cell.truckName.frame.width)")
        print("size: \(cell.truckName.frame.size)")
        print("origin: \(cell.truckName.frame.origin)")
        let openString = outputFormatter.stringFromDate(foodItem.truck!.open)
        let closeString = outputFormatter.stringFromDate(foodItem.truck!.close)
        cell.pickupRange?.text = "\(openString) - \(closeString)"
        print("Leaving set up cell")
        return (cell, foodItem.imgURL!)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool{
        if identifier == "toOrder" && userData == nil {
            performSegueWithIdentifier("toRegisterLogin", sender: sender)
            return false
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("Segue coming!")
        if let orderController: OrderController = segue.destinationViewController as? OrderController {
            let foodItemIndex = foodList!.indexPathForSelectedRow!.row
            orderController.foodItem = foodItems[foodItemIndex]
            print(userData!.sessionToken)
            orderController.token = userData!.sessionToken!
        }
    }
}

