//
//  APIController.swift
//  chakula
//
//  Created by Agree Ahmed on 7/12/15.
//  Copyright (c) 2015 org.rhye. All rights reserved.
//

import Foundation
import CoreLocation

protocol FeedAPIProtocol {
    func didReceiveAPIResults(results: [FoodItem])
    func queryFailed()
}

class FeedAPIController {
    
    var delegate: FeedAPIProtocol
    var trucks: Dictionary<Int, Truck>
    var foodItems: [FoodItem]

    init(delegate: FeedAPIProtocol) {
        self.trucks = Dictionary()
        self.foodItems = [FoodItem]()
        self.delegate = delegate
    }
    
    func findFood(){
        query(API.METHOD_FINDTRUCK)
    }

    private func query(method: String) {
        let (fromTime, untilTime) = getTimeRange()
        let postString = "lat=1.00&lon=2.00&radius=1000000&open_from=\(fromTime)&open_til=\(untilTime)"
        let task = API.newSession().dataTaskWithRequest(API.buildRequest(API.URL_TRUCK, method: method, postString: postString)) {
            data, response, error in
            if error != nil {
                print("error=\(error)")
                self.delegate.queryFailed()
                return
            }
            do {
                if let jsonResult =  try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                    if let results: NSArray = jsonResult[API.RESULT_BODY] as? NSArray {
                        print("Landed")
                        self.handleQueryResults(results, method: method)
                    }
                }
            } catch { // TODO: catch error
                self.delegate.queryFailed()
            }
        }
        task!.resume()
    }

    /*
    ============ TRUCK SERVLET ============
    */

    private func handleQueryResults(results: NSArray, method: String) {
        if(method == API.METHOD_FINDFOOD){
            self.buildFoodList(results)
            print(self.foodItems.count)
            self.delegate.didReceiveAPIResults(self.foodItems)
        } else if(method == API.METHOD_FINDTRUCK){
            self.buildTruckList(results)
            self.query(API.METHOD_FINDFOOD)
        }
    }
    
    private func buildTruckList(results: NSArray) {
        print(results)
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
                let truckId = item[API.TRUCK.ID] as? Int{
                    foodItems.append(FoodItem(id: item[API.MENU_ITEM.MENU_ID] as? Int,
                        name: item[API.MENU_ITEM.NAME] as? String,
                        description: item[API.MENU_ITEM.DESC] as? String,
                        imgURL: item[API.MENU_ITEM.PIC_URL] as? String,
                        price: item[API.MENU_ITEM.PRICE] as? Double,
                        truck: trucks[truckId],
                        radioOptions: self.getRadioOptions(item[API.MENU_ITEM.LIST_OPTIONS_MENU] as! NSArray),
                        toggleOptions: self.getToggleOptions(item[API.MENU_ITEM.TOGGLE_OPTIONS_MENU] as! NSArray)))
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
    
    private func getTimeRange() -> (Int, Int) {
        let min_in_seconds = 60
        let hour_in_seconds = min_in_seconds * 60
        let fromTimeRaw = NSDate().timeIntervalSince1970
        print(round(fromTimeRaw))
        let fromTimeSeconds: Int = Int(round(fromTimeRaw))
        let untilTime = Int(fromTimeSeconds + 3 * hour_in_seconds)
        print(untilTime)
        return (fromTimeSeconds, untilTime)
    }
    
    /* 
    ============ USER SERVLET ============
    */
    
    /*
    ============ SERVER REQUESTS ============
    */
}
