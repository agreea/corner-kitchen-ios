//
//  APIController.swift
//  chakula
//
//  Created by Agree Ahmed on 7/12/15.
//  Copyright (c) 2015 org.rhye. All rights reserved.
//

import Foundation
import CoreLocation

protocol APIControllerProtocol {
    func didReceiveAPIResults(results: [FoodItem])
}

class APIController {
    
    var delegate: APIControllerProtocol
    var trucks: Dictionary<Int, Truck>
    var foodItems: [FoodItem]
    init(delegate: APIControllerProtocol) {
        self.delegate = delegate
        self.trucks = Dictionary()
        self.foodItems = [FoodItem]()
    }
    
    func findFood(){
        query("truck")
    }

    private func query(lookingFor: String) {
        let task = NSURLSession.sharedSession().dataTaskWithRequest(buildRequest(lookingFor)) {
            data, response, error in
            if error != nil {
                println("error=\(error)")
                return
            }
            var err: NSError?
            if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary {
                if(err != nil) {
                    println("JSON Error \(err!.localizedDescription)")
                }
                if let results: NSArray = jsonResult["Return"] as? NSArray {
                    self.handleResults(results, lookingFor: lookingFor)
                }
            }
        }
        task.resume()
    }
    
    // First get trucks, finally get food
    private func handleResults(results: NSArray, lookingFor: String) {
        if(lookingFor == "food"){
            self.buildFoodList(results)
            self.delegate.didReceiveAPIResults(self.foodItems)
        } else if(lookingFor == "truck"){
            self.buildTruckList(results)
            self.query("food")
        }
    }
    
    private func buildTruckList(results: NSArray) {
        let inputFormatter = NSDateFormatter()
        inputFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        for entry in results {
            if let truck = entry as? NSDictionary,
                let truckId = truck["Id"] as? Int{
                    let lat = truck["Location_lat"] as! NSString
                    let lon = truck["Location_lon"] as! NSString
                    let open: NSDate = inputFormatter.dateFromString(truck["Open_from"] as! String)!
                    let close: NSDate = inputFormatter.dateFromString(truck["Open_until"] as! String)!
                    self.trucks[truckId] = Truck(name: truck["Name"] as! String ?? "   ",
                                                id: truck["Id"] as! Int,
                                                open: open,
                                                close: close,
                                                dist: truck["Distance"] as! Double,
                                                description: truck["Description"] as! String ?? "  ",
                                                lat: lat.doubleValue, lon: lon.doubleValue)
            }
        }

    }
    
    private func buildFoodList(results: NSArray){
        for entry in results {
            if let item = entry as? NSDictionary,
                let truckId = item["Truck_id"] as? Int{
                    foodItems.append(FoodItem(name: item["Name"] as? String,
                        description: item["Description"] as? String,
                        imgURL: item["Pic_url"] as? String,
                        price: item["Price"] as? Double,
                        truck: trucks[truckId]))
            }
        }
    }

    private func buildRequest(looking_for: String) -> NSMutableURLRequest {
        var request = NSMutableURLRequest(URL: NSURL(string: "http://corner.rhye.org/api/truck")!)
        request.HTTPMethod = "POST"
        let (fromTime, untilTime) = getTimeRange()
        let postString = "method=find_\(looking_for)&lat=1.00&lon=2.00&radius=1000000&open_from=\(fromTime)&open_til=\(untilTime)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        return request
    }

    private func getTimeRange() -> (Int, Int) {
        var min_in_seconds = 60
        var hour_in_seconds = min_in_seconds * 60
        var fromTimeRaw = NSDate().timeIntervalSince1970
        var fromTimeSeconds: Int = Int(round(fromTimeRaw))
        var untilTime: Int = fromTimeSeconds + 600 * hour_in_seconds
        // TODO: timestamp bug fixes
        return (0, 1636733735)
    }

}
