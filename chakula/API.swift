//
//  API.swift
//  chakula
//
//  Created by Agree Ahmed on 7/25/15.
//  Copyright © 2015 org.rhye. All rights reserved.
//

import Foundation

struct API {
    static let URL = "http://52.2.192.205/api/"
    static let URL_USER = URL + "user"
    static let URL_TRUCK = URL + "truck"
    static let METHOD_REGISTER = "register"
    static let METHOD_VERIFY = "verify"
    static let METHOD_LOGIN = "login"
    static let METHOD_FINDFOOD = "find_food"
    static let METHOD_FINDTRUCK = "find_truck"
    static let RESULT_BODY = "Return"
    static let RESULT_ERROR = "Error"
    static let RESULT_SUCCESS = "Success"
    
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
}
