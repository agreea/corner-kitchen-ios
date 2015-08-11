//
//  OrderAPIController.swift
//  chakula
//
//  Created by Agree Ahmed on 7/29/15.
//  Copyright © 2015 org.rhye. All rights reserved.
//

import Foundation
protocol OrderAPIProtocol {
    func orderDidSucceed()
    func orderDidFail()
}
class OrderAPIController: APICallback {
    // order
    // handle order results
    // delegate: orderSuccess, orderFailure
    var delegate: OrderAPIProtocol
    
    init(delegate: OrderAPIProtocol){
        self.delegate = delegate
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
            let postString = "session=\(token)&truck_id=\(foodItem.truck!.id)&method=order&pickup_time=\(pickupTime)&items=[\(jsonText!)]"
            API().post(API.buildRequest(API.URL_TRUCK, method: API.METHOD_ORDER, postString: postString), callback: self, method: API.METHOD_ORDER)
        } catch {
            print("Not even in handler")
        }
    }
    
    func resultDidReturn(jsonResult: NSDictionary, method: String) {
        print(jsonResult)
        delegate.orderDidSucceed()
    }
    
    func errorDidReturn(error: ErrorType, method: String) {
        delegate.orderDidFail()
    }

    
    private func buildItemDictionary(foodItem: FoodItem, toggleOptions:[Int], radioOptions:[Int], quantity: Int) -> NSDictionary {
        var orderBody: Dictionary<String, AnyObject> = [:]
        orderBody[API.MENU_ITEM.ORDER_ID] = foodItem.id
        orderBody[API.MENU_ITEM.QUANT] = quantity
        orderBody[API.MENU_ITEM.TOGGLE_OPTIONS_ORDER] = toggleOptions
        orderBody[API.MENU_ITEM.LIST_OPTIONS_ORDER] = radioOptions
        return orderBody
    }
}