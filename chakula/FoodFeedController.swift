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
    var currentCoords: CLLocationCoordinate2D?
    // Registration and Login interface components
    var userApi: UserAPIController!
    var userData: UserData?
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
        userApi = UserAPIController()
        userData = userApi.getUserData()
        if userData != nil {
            mixPanelProperties[MixKeys.USER_ID] = "\(userData!.id!)"
        } else {
            mixPanelProperties[MixKeys.USER_ID] = "0"
        }
        print("View did load: \(mixpanel)")
        self.navigationItem.setHidesBackButton(true, animated:true)
        setupRefresh()
        locateUserAndFood()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
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
        if #available(iOS 8.0, *) {
            manager.requestWhenInUseAuthorization()
        } else {
            // Fallback on earlier versions
        }
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        if currentCoords == nil {
            manager.startUpdatingLocation()
            print("updating location now")
        } else {
            getAddressFor(currentCoords!){ address -> Void in
                self.title = "Near \(address)"
            }
            feedApi.findFoodNear(currentCoords!)
            mixpanel.track(MixKeys.EVENT.REFRESH, properties: mixPanelProperties)
            print("mixpanel: \(mixpanel)")
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        print("got a location")
        if let location = locations.last {
            print("location was last")
            currentCoords = location.coordinate
            print("Coords have been set")
            feedApi.findFoodNear(currentCoords!)
            print("Called Feed Api")
            manager.stopUpdatingLocation()
            getAddressFor(currentCoords!){ address -> Void in
                self.title = "Near \(address)"
            }
        }
    }
    
    func getAddressFor(coord: CLLocationCoordinate2D, callback: (String) -> Void) {
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            if placemarks!.count > 0 {
                print("got to placemarks")
                let pm = placemarks![0] as CLPlacemark
                if let addressDict = pm.addressDictionary as Dictionary?,
                    streetAddress = addressDict["Street"] as! String?{
                        callback(streetAddress)
                } else {
                    callback(pm.name!)
                }
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    }
    
    func refresh(sender:AnyObject) {
        if currentCoords != nil {
            locateUserAndFood()
        } else {
            // TODO: Show location error
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
                getAddressFor(truckCoord){ address -> Void in
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
        let (cell, imgURL) = setUpCell(tableView, indexPath: indexPath)
        if let img = self.imgCache[imgURL] {
            cell.foodImage!.image = img
        } else if imgURL == "" {
            cell.foodImage!.image = UIImage(named: "no-pic-yet")
        } else if let url = NSURL(string: imgURL){
            let request = NSURLRequest(URL: url)
            let mainQueue = NSOperationQueue.mainQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    let toImage = UIImage(data: data!)
                    self.imgCache[imgURL] = toImage
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? FoodFeedCell {
                            UIView.transitionWithView(cellToUpdate.foodImage!,
                                duration:0.7,
                                options: UIViewAnimationOptions.TransitionCrossDissolve,
                                animations: { cellToUpdate.foodImage!.image = toImage },
                                completion: nil)
                            }
                        })
                    } else {
                        print("Error: \(error!.localizedDescription)")
                    }
                })
            }
        return cell
    }
    
    private func setUpCell(tableView: UITableView, indexPath: NSIndexPath) -> (FoodFeedCell, String) {
        let cell: FoodFeedCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! FoodFeedCell
        let foodItem = self.foodItems[indexPath.row]
        cell.foodTitle?.text = foodItem.name!
        cell.foodPrice?.text = "$\(foodItem.price!)"
        cell.foodImage?.image = UIImage(named: "loading")
        cell.truckName?.text = foodItem.truck!.name
        if foodItem.truck!.dist < 0.1 {
            cell.distance?.text = "here!"
        } else if let truckAddress = truckAddresses[foodItem.truck!.id] {
            cell.distance?.text = truckAddress
        } else {
            let coord = CLLocationCoordinate2D(latitude: foodItem.truck!.lat, longitude: foodItem.truck!.lon)
            getAddressFor(coord){ address -> Void in
                cell.distance?.text = address
                cell.distance?.textColor = UIColor.blackColor()
                cell.distance?.sizeToFit()
            }
        }
        cell.distance?.textColor = UIColor.blackColor()
        let openString = outputFormatter.stringFromDate(foodItem.truck!.open)
        let closeString = outputFormatter.stringFromDate(foodItem.truck!.close)
        cell.pickupRange?.text = "\(openString) - \(closeString)"
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
        if let orderController = segue.destinationViewController as? OrderController {
            let foodItemIndex = foodList!.indexPathForSelectedRow!.row
            orderController.foodItem = foodItems[foodItemIndex]
            print(userData!.sessionToken)
            print(foodItems[foodItemIndex].id!)
            orderController.token = userData!.sessionToken!
            var propCopy = mixPanelProperties
            print(propCopy)
            propCopy[MixKeys.FOOD_ID] = "\(foodItems[foodItemIndex].id!)"
            // TODO: MIX PANEL IS NULL??
            print(mixpanel.description)
            mixpanel.track(MixKeys.EVENT.FEED_CLICK)
            print("logged feed click")
        } else if let locationViewController = segue.destinationViewController as? LocationViewController {
            locationViewController.receivedLocation = currentCoords
        }
    }
}

