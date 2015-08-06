//
//  urlsession.swift
//  chakula
//
//  Created by Agree Ahmed on 8/4/15.
//  Copyright © 2015 org.rhye. All rights reserved.
//

import Foundation

class LearnNSURLSession: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate {
    typealias CallbackBlock = (result: String, error: String?) -> ()
    var callback: CallbackBlock = {
        (resultString, error) -> Void in
        if error == nil {
            print(resultString)
        } else {
            print(error)
        }
    }
    
    func httpGet(request: NSMutableURLRequest!, callback: (String,
        String?) -> Void) {
            let configuration =
            NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: configuration,
                delegate: self,
                delegateQueue:NSOperationQueue.mainQueue())
            let task = session.dataTaskWithRequest(request){
                data, response, error in
                if error != nil {
                    callback("", error!.localizedDescription)
                } else {
                    let result = NSString(data: data!, encoding:
                        NSASCIIStringEncoding)!
                    callback(result as String, nil)
                }
            }
//                if error != nil {
//                    print("error=\(error)")
//                    //                    self.delegate.queryFailed()
//                    return
//                }
//                do {
//                    if let jsonResult =  try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
//                        print(jsonResult[API.RESULT_BODY])
//                    }
//                } catch { // TODO: catch error
//                    //                    self.delegate.queryFailed()
//                }
//            }
            task!.resume()
    }
    
    func URLSession(session: NSURLSession,
                    task: NSURLSessionTask,
                    didReceiveChallenge challenge: NSURLAuthenticationChallenge,
                    completionHandler: (NSURLSessionAuthChallengeDisposition,
                    NSURLCredential?) -> Void) {
            completionHandler(
                NSURLSessionAuthChallengeDisposition.UseCredential,
                NSURLCredential(forTrust:
                    challenge.protectionSpace.serverTrust!))
    }

    
    func URLSession(session: NSURLSession,
        task: NSURLSessionTask,
        willPerformHTTPRedirection response: NSHTTPURLResponse,
        newRequest request: NSURLRequest,
        completionHandler: (NSURLRequest?) -> Void) {
            let newRequest : NSURLRequest? = request
            print(newRequest?.description);
            completionHandler(newRequest)
    }
}