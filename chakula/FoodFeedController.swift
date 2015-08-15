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
    var currentLocation: CLLocation!
    // Registration and Login interface components
    var userData: UserData!
    var refreshControl:UIRefreshControl!
    var mixpanel: Mixpanel!
    var mixPanelProperties = [String : String]()
    var foodItems = [FoodItem]()
    var truckAddresses = [Int : String]()
    let kCellIdentifier: String = "foodCell"
    var feedApi : FeedAPIController!
    @IBOutlet weak var foodList: UITableView!
    var imgCache = [String:UIImage]()
    var labelColor = UIColor.whiteColor()
    let outputFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mixpanel = Mixpanel.sharedInstance()
        feedApi = FeedAPIController(delegate: self)
        userData = UserAPIController().getUserData()
        if userData != nil {
            mixPanelProperties[MixKeys.USER_ID] = "\(userData.id)"
        } else {
            mixPanelProperties[MixKeys.USER_ID] = "0"
        }
        self.navigationItem.setHidesBackButton(true, animated:true)
        setupRefresh()
        println("Set up refresh")
        switch CLLocationManager.authorizationStatus() {
        case CLAuthorizationStatus.AuthorizedAlways,
                CLAuthorizationStatus.AuthorizedWhenInUse:
            locateUserAndFood()
            break
        default:
            CLLocationManager.launchLocationDisabledAlert()
            break
        }
    }
    
    private func setupRefresh() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Refreshing")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl.layer.zPosition = -50
        self.foodList.addSubview(refreshControl)
    }
    
    private func locateUserAndFood(){
        manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        if currentLocation == nil ||
            currentLocation.timestamp.timeIntervalSinceDate(NSDate()) > 3600 {
            manager.startUpdatingLocation()
            print("updating location now")
        } else {
            CLLocationManager.getAddressFor(currentLocation.coordinate){ address -> Void in
                self.title = "Near \(address)"
            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            feedApi.findFoodNear(currentLocation.coordinate)
            mixpanel.track(MixKeys.EVENT.REFRESH, properties: mixPanelProperties)
        }
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
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        print("got a location")
        if let location = locations.last as? CLLocation {
            currentLocation = location
            feedApi.findFoodNear(currentLocation.coordinate)
            manager.stopUpdatingLocation()
            CLLocationManager.getAddressFor(currentLocation.coordinate){ address -> Void in
                self.title = "Near \(address)"
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    }
    
    func refresh(sender:AnyObject) {
        if currentLocation != nil {
            locateUserAndFood()
        } else {
            CLLocationManager.launchLocationUndeterminedAlert()
        }
    }
    
    func didReceiveAPIResults(foodItems: [FoodItem]) {
        print("FOOD ITEMS SIZE: \(foodItems.count)")
        outputFormatter.dateFormat = "hh':'mm"
        outputFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dispatch_async(dispatch_get_main_queue(), {
            self.foodItems = foodItems
            if(self.foodItems.count != 0) {
                self.foodList!.reloadData()
            } else {
                self.setFeedMessage("Couldn't find any food nearby 😔")
            }
            self.buildAddresses()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.refreshControl.endRefreshing()
        })

    }
    
    func buildAddresses() {
        for foodItem in foodItems {
            let truck = foodItem.truck
            if truckAddresses[truck!.id] == nil {
                let truckCoord = CLLocationCoordinate2D(latitude: truck!.lat, longitude: truck!.lon)
                CLLocationManager.getAddressFor(truckCoord){ address -> Void in
                    self.truckAddresses[truck!.id] = address
                }
            }
        }
    }
    func queryFailed(){
        dispatch_async(dispatch_get_main_queue(), {
                // TODO: Show error message on feed
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.setFeedMessage("No network connection :(")
            self.refreshControl.endRefreshing()
            self.mixpanel.track(MixKeys.EVENT.REFRESH_FAIL, properties: self.mixPanelProperties)
        })
    }
    func queryFailedNoLocation(){
        self.setFeedMessage("We couldn't locate you. 😕 Set your location using the map button at the top right")

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
        }
        return foodItems.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: FoodFeedCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! FoodFeedCell
        let foodItem = self.foodItems[indexPath.row]
        let imgURL = foodItem.imgURL!
        cell.setupCell(foodItem, truckAddress: truckAddresses[foodItem.truck!.id],
            outputFormatter: outputFormatter)
        if let img = self.imgCache[imgURL] {
            cell.foodImage!.image = img
        } else if imgURL == "" {
            cell.foodImage!.image = UIImage(named: "no-pic-yet")
        } else if let url = NSURL(string: imgURL){
            cell.getImage(url) { image -> Void in
                self.imgCache[imgURL] = image }
        }
        return cell
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool{
        if identifier == "toOrder" && userData == nil {
            performSegueWithIdentifier("toRegisterLogin", sender: sender)
            return false
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("Segue coming!")
        if let orderController = segue.destinationViewController as? OrderController {
            let foodItemIndex = foodList!.indexPathForSelectedRow()!.row
            orderController.foodItem = foodItems[foodItemIndex]
            orderController.token = userData!.sessionToken
            var propCopy = mixPanelProperties
            propCopy[MixKeys.FOOD_ID] = "\(foodItems[foodItemIndex].id!)"
            mixpanel.track(MixKeys.EVENT.FEED_CLICK)
        } else if let locationViewController = segue.destinationViewController as? LocationViewController {
            locationViewController.receivedLocation = currentLocation.coordinate
        }
    }
}

