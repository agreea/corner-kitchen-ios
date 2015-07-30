//
//  UserAPIController.swift
//  chakula
//
//  Created by Agree Ahmed on 7/25/15.
//  Copyright © 2015 org.rhye. All rights reserved.
//

import UIKit
import CoreData

protocol UserAPIProtocol {
    func registerResult(result: String, didSucceed: Bool)
    func verifyResult(result: String, didSucceed: Bool)
    // func loginResult(result: String, didSucceed: Bool)
}


class UserAPIController {
    var phone: Int?
    var firstName: String?
    var lastName: String?
    var password: String?
    var sessionToken: String?
    var delegate: UserAPIProtocol
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    init(delegate: UserAPIProtocol){
        self.delegate = delegate
    }
    
    func register(phone: Int, pass: String, first: String, last: String){
        self.phone = phone
        self.firstName = first
        self.lastName = last
        let postString = "phone=\(phone)&pass=\(pass)&firstname=\(first)&lastname=\(last)"
        let task = API.newSession().dataTaskWithRequest(API.buildRequest(API.URL_USER,
                                    method: API.METHOD_REGISTER, postString: postString)) {
            data, response, error in
            if error != nil {
                print("error=\(error)")
                self.delegate.registerResult("Uh-oh... Couldn't register. Try again?", didSucceed: false)
                return
            }
            do {
                if let jsonResult =  try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                    self.handleRegisterResults(jsonResult, phoneNumber: phone)
                }
            } catch {
                self.delegate.registerResult("Connection failure. Try again?", didSucceed: false)
            }
        }
        task!.resume()
    }
    
    func verify(code: String){
        let postString = "phone=\(self.phone!)&code=\(code)"
        let task = API.newSession().dataTaskWithRequest(API.buildRequest(API.URL_USER,
                                    method: API.METHOD_VERIFY, postString: postString)) {
            data, response, error in
            if error != nil {
                print("error=\(error)")
                self.delegate.verifyResult("Uh-oh. Something went wrong. Try again?", didSucceed: false)
                return
            }
            do {
                if let jsonResult =  try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary {
                    self.handleVerifyResults(jsonResult)
                }
            } catch {
                self.delegate.verifyResult("Connection failure. Try again?", didSucceed: false)
            }
        }
        task!.resume()
    }
    
    func handleRegisterResults(result: NSDictionary, phoneNumber: Int){
        if result[API.RESULT_SUCCESS] as! Int == 1 {
            delegate.registerResult("\(result[API.RESULT_BODY]!)", didSucceed: true)
        } else {
            delegate.registerResult("\(result[API.RESULT_ERROR]!)", didSucceed: false)
        }
    }
    
    func handleVerifyResults(result: NSDictionary){
        if result[API.RESULT_SUCCESS] as! Int == 1 {
            let resultBody = result[API.RESULT_BODY] as! NSDictionary
            sessionToken = resultBody[API.USER.SESSION_TOKEN] as! String
            print(sessionToken)
            UserData.newEntry(managedObjectContext,
                firstName: firstName!, lastName: lastName!,
                sessionToken: sessionToken!)
            UserData.save(managedObjectContext)
            delegate.verifyResult("Success!", didSucceed: true)
        } else {
            delegate.verifyResult("\(result[API.RESULT_ERROR]!)", didSucceed: false)
        }
    }
    
    func getUserData() -> UserData? {
        let request = NSFetchRequest(entityName: "UserData")
        do {
            let fetchedEntities = try managedObjectContext.executeFetchRequest(request) as! [UserData]
            if fetchedEntities.count != 0 {
                return fetchedEntities[0]
            }
        } catch {
            print(error)
        }
        return nil
    }
}