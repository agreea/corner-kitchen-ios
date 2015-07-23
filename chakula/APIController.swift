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
    func queryFailed()
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
        query("find_truck")
    }

    private func query(method: String) {
        let task = NSURLSession.sharedSession().dataTaskWithRequest(buildRequest(method)) {
            data, response, error in
            if error != nil {
                println("error=\(error)")
                self.delegate.queryFailed()
                return
            }
            var err: NSError?
            if let jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary {
                if(err != nil) {
                    println("JSON Error \(err!.localizedDescription)")
                    self.delegate.queryFailed()
                }
                if let results: NSArray = jsonResult["Return"] as? NSArray {
                    self.handleResults(results, method: method)
                }
            }
        }
        task.resume()
    }
    
    // First get trucks, finally get food
    private func handleResults(results: NSArray, method: String) {
        if(method == "find_food"){
            self.buildFoodList(results)
            self.delegate.didReceiveAPIResults(self.foodItems)
        } else if(method == "find_truck"){
            self.buildTruckList(results)
            self.query("find_food")
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
                        truck: trucks[truckId],
                        radioOptions: self.getRadioOptions(item["ListOptions"] as! NSArray),
                        toggleOptions: self.getToggleOptions(item["ToggleOptions"] as! NSArray)))
            }
        }
    }
    
    // TODO: Clean up the nested loops
    private func getRadioOptions(optionSets: NSArray) -> [RadioOption]{
        var radioOptions = [RadioOption]()
        for optionSet in optionSets {
            if let optionGroup = optionSet as? NSDictionary {
                var choices: [(name: String, priceDiff: Double, id: Int)] = []
                if let values = optionGroup["Values"] as? NSArray {
                    for value in values {
                        choices.append((name: value["Option_name"] as! String,
                                        priceDiff: value["Price_modifier"] as! Double,
                                        id: value["Id"] as! Int))
                    }
                }
                radioOptions.append(RadioOption(name: optionGroup["Name"] as! String, choices: choices))
            }
        }
        return radioOptions
    }

    private func getToggleOptions(toggles: NSArray) -> [(name: String, priceDiff: Double, id: Int)]{
        var toggleOptions: [(name: String, priceDiff: Double, id: Int)] = []
        for toggle in toggles {
            toggleOptions.append((name: toggle["Name"] as! String,
                                  priceDiff: toggle["Price_modifier"] as! Double,
                                  id: toggle["Id"] as! Int))
        }
        return toggleOptions
    }
    private func buildRequest(method: String) -> NSMutableURLRequest {
        var request = NSMutableURLRequest(URL: NSURL(string: "http://corner.rhye.org/api/truck")!)
        request.HTTPMethod = "POST"
        let (fromTime, untilTime) = getTimeRange()
        let postString = "method=\(method)&lat=1.00&lon=2.00&radius=1000000&open_from=\(fromTime)&open_til=\(untilTime)"
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
