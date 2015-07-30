//
//  API.swift
//  chakula
//
//  Created by Agree Ahmed on 7/25/15.
//  Copyright © 2015 org.rhye. All rights reserved.
//

import Foundation

struct API {
    static let URL = "http://52.2.192.205/api/",
                URL_USER = URL + "user",
                URL_TRUCK = URL + "truck",
                METHOD_REGISTER = "register",
                METHOD_VERIFY = "verify",
                METHOD_LOGIN = "login",
                METHOD_FINDFOOD = "find_food",
                METHOD_FINDTRUCK = "find_truck",
                METHOD_ORDER = "order",
                RESULT_BODY = "Return",
                RESULT_ERROR = "Error",
                RESULT_SUCCESS = "Success"
    
    static func buildRequest(url: String, method: String, postString: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        let composedPost = "method=\(method)&" + postString
        print(composedPost)
        request.HTTPBody = composedPost.dataUsingEncoding(NSUTF8StringEncoding)
        return request
    }
    
    static func newSession() -> NSURLSession{
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
    }
    
    struct USER {
        static let SESSION_TOKEN = "Session_token"
    }
    struct TRUCK {
        static let ID = "Truck_id"
    }
    struct MENU_ITEM {
        static let  MENU_ID = "Id",
                    ORDER_ID = "item_id",
                    NAME = "Name",
                    PIC_URL = "Pic_url",
                    QUANT = "quantity",
                    PRICE = "Price",
                    DESC = "Description",
                    LIST_OPTIONS_MENU = "ListOptions",
                    LIST_OPTIONS_ORDER = "listoptions",
                    TOGGLE_OPTIONS_MENU = "ToggleOptions",
                    TOGGLE_OPTIONS_ORDER = "toggleoptions"
    }
}
