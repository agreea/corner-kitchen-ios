//
//  ViewController.swift
//  chakula
//
//  Created by Agree Ahmed on 7/11/15.
//  Copyright (c) 2015 org.rhye. All rights reserved.
//

import UIKit
import CoreLocation

class FoodFeedController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol, CLLocationManagerDelegate {

    var manager: CLLocationManager!

    var foodItems = [FoodItem]()
    let kCellIdentifier: String = "foodCell"
    var api : APIController!
    @IBOutlet weak var foodList: UITableView!
    var imgCache = [String:UIImage]()
    var labelColor = UIColor.whiteColor()
    let outputFormatter = NSDateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        outputFormatter.dateFormat = "hh':'mm"
        outputFormatter.locale = NSLocale(localeIdentifier: "en_US")
        api = APIController(delegate: self)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        api.findFood()
    }
    
    func locationManager(manager: CLLocationManager!,
        didUpdateLocations locations: [AnyObject]!){
        let location = locations.last as! CLLocation
        println("Lat: \(location.coordinate.latitude)")
        println("Lon: \(location.coordinate.longitude)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let foodItem = self.foodItems[indexPath.row]
    }
    func didReceiveAPIResults(results: [FoodItem]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.foodItems = results
            self.foodList!.reloadData()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodItems.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var (cell, imgURL) = setUpCell(tableView, indexPath: indexPath)
        
        if let img = self.imgCache[imgURL] {
            cell.foodImage!.image = img
        } else {
            let request: NSURLRequest = NSURLRequest(URL: NSURL(string: imgURL)!)
            let mainQueue = NSOperationQueue.mainQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    println("Got to the async request completion!")
                    let image = UIImage(data: data)
                    self.imgCache[imgURL] = image
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? FoodFeedCell {
                            println("Got 'Cell to update!'")
                                cellToUpdate.foodImage!.image = image
                            }
                        })
                    } else {
                        println("Error: \(error.localizedDescription)")
                    }
                })
            }
        return cell
    }
    
    private func setUpCell(tableView: UITableView, indexPath: NSIndexPath) -> (FoodFeedCell, String) {
        let cell: FoodFeedCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! FoodFeedCell
        let foodItem = self.foodItems[indexPath.row]
        cell.foodTitle?.text = foodItem.name!
        cell.foodDescription?.text = foodItem.description!        
        cell.foodPrice?.text = "$\(foodItem.price!)"
        cell.foodImage?.image = UIImage(named: "pacman.png")
        cell.truckName.text = foodItem.truck!.name
        cell.distance?.text = "\(foodItem.truck!.dist)mi"
        
        let openString = outputFormatter.stringFromDate(foodItem.truck!.open)
        let closeString = outputFormatter.stringFromDate(foodItem.truck!.close)
        
        cell.pickupRange?.text = "\(openString) - \(closeString)"
        return (cell, foodItem.imgURL!)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("Segue coming!")
        if let orderController: OrderController = segue.destinationViewController as? OrderController {
            var foodItemIndex = foodList!.indexPathForSelectedRow()!.row
            println("About to add a food item!")
            orderController.foodItem = foodItems[foodItemIndex]
            println("Added food item!")
        }
    }
}

