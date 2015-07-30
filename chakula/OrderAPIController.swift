//
//  OrderAPIController.swift
//  chakula
//
//  Created by Agree Ahmed on 7/29/15.
//  Copyright © 2015 org.rhye. All rights reserved.
//

import Foundation

class OrderAPIController {
    // order
    // handle order results
    // delegate: orderSuccess, orderFailure
    init(){
        
    }
    func order(token: String, foodItem: FoodItem, toggleOptions:[Int], radioOptions:[Int], quantity: Int, pickupTime: Int) {
        print("TOKEN: \(token)")
        let itemDictionary = buildItemDictionary(foodItem,
                                            toggleOptions: toggleOptions, radioOptions: radioOptions,
                                            quantity: quantity)
        print("itemData: \(itemDictionary)")
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(itemDictionary, options: NSJSONWritingOptions(rawValue: 0))
            let jsonText = NSString(data: jsonData, encoding: NSASCIIStringEncoding)
            let orderBody = "session=\(token)&truck_id=\(foodItem.truck!.id)&method=order&pickup_time=\(pickupTime)&items=[\(jsonText!)]"
            let task = API.newSession().dataTaskWithRequest(API.buildRequest(API.URL_TRUCK, method: API.METHOD_ORDER, postString: orderBody)) {
                data, response, error in
                if error != nil {
                    print("error=\(error)")
//                    self.delegate.queryFailed()
                    return
                }
                do {
                    if let jsonResult =  try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                        if let results = jsonResult[API.RESULT_BODY] as? String {
                            print("Landed: \(results)")
//                            self.handleQueryResults(results, method: method)
                        }
                    }
                } catch { // TODO: catch error
//                    self.delegate.queryFailed()
                    print("UH OH! But in handler")
                }
            }
            task!.resume()
        } catch {
            print("Not even in handler")
        }
    }
    
    func buildItemDictionary(foodItem: FoodItem, toggleOptions:[Int], radioOptions:[Int], quantity: Int) -> NSDictionary {
        var orderBody: Dictionary<String, AnyObject> = [:]
        orderBody[API.MENU_ITEM.ORDER_ID] = foodItem.id
        orderBody[API.MENU_ITEM.QUANT] = quantity
        orderBody[API.MENU_ITEM.TOGGLE_OPTIONS_ORDER] = toggleOptions
        orderBody[API.MENU_ITEM.LIST_OPTIONS_ORDER] = radioOptions
        return orderBody
    }
}