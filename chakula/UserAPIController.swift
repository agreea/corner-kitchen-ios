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
    func loginResult(result: String, didSucceed: Bool)
    func callDidFail(message: String)
}


class UserAPIController: APICallback{
    var phone: Int?
    var firstName: String?
    var lastName: String?
    var password: String?
    var sessionToken: String?
    var delegate: UserAPIProtocol?
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    init(){}
    init(delegate: UserAPIProtocol){
        self.delegate = delegate
    }
    func resultDidReturn(result: NSDictionary, method: String){
        print("Result DID return!: \(result)")
        print("Method result: \(method)")
        switch method {
        case API.METHOD_REGISTER:
            handleRegisterResult(result)
            break
        case API.METHOD_VERIFY:
            handleVerifyResult(result)
            break
        case API.METHOD_LOGIN:
            handleLoginResult(result)
            break
        default:
            break
        }
    }
    
    func errorDidReturn(error: ErrorType, method: String){
        delegate?.callDidFail("\(error)")
    }

    func register(phone: Int, pass: String, first: String, last: String){
        self.phone = phone
        self.firstName = first
        self.lastName = last
        let postString = "phone=\(phone)&pass=\(pass)&firstname=\(first)&lastname=\(last)"
        API().post(API.buildRequest(API.URL_USER, method: API.METHOD_REGISTER, postString: postString), callback: self, method: API.METHOD_REGISTER)
    }
    
    func verify(code: String){
        let postString = "phone=\(self.phone!)&code=\(code)"
        API().post(API.buildRequest(API.URL_USER, method: API.METHOD_VERIFY, postString: postString), callback: self, method: API.METHOD_VERIFY)
    }
    private func handleVerifyResult(result: NSDictionary){
        handleTokenResult(result)
        // do extra logic for new verify
    }
    
    func login(phoneNumber: String, pass: String) {
        let postString = "phone=\(phoneNumber)&pass=\(pass)"
        API().post(API.buildRequest(API.URL_USER, method: API.METHOD_LOGIN, postString: postString), callback: self, method: API.METHOD_LOGIN)
    }
    
    private func handleLoginResult(result: NSDictionary) {
        handleTokenResult(result)
        // do extra logic for login
    }

    private func handleRegisterResult(result: NSDictionary){
        if result[API.RESULT_SUCCESS] as! Int == 1 {
            delegate?.registerResult("\(result[API.RESULT_BODY]!)", didSucceed: true)
        } else {
            delegate?.registerResult("\(result[API.RESULT_ERROR]!)", didSucceed: false)
        }
    }
    
    private func handleTokenResult(result: NSDictionary){
        if result[API.RESULT_SUCCESS] as! Int == 1 {
            if let resultBody = result[API.RESULT_BODY] as? NSDictionary,
                sessionToken = resultBody[API.USER.SESSION_TOKEN] as? String,
                firstName = resultBody[API.USER.FIRST_NAME] as? String,
                lastName = resultBody[API.USER.LAST_NAME] as? String {
                writeUserEntity(firstName, lastName: lastName, sessionToken: sessionToken)
            }
            print(sessionToken)
        } else {
            delegate?.verifyResult("\(result[API.RESULT_ERROR]!)", didSucceed: false)
        }
    }
    
    private func writeUserEntity(firstName: String, lastName: String, sessionToken: String){
        UserData.newEntry(managedObjectContext,
            firstName: firstName, lastName: lastName,
            sessionToken: sessionToken)
        UserData.save(managedObjectContext)
        delegate?.verifyResult("Success!", didSucceed: true)
    }
    
    func getUserData() -> UserData? {
        let request = NSFetchRequest(entityName: "UserData")
        do {
            let fetchedEntities = try managedObjectContext.executeFetchRequest(request) as! [UserData]
            if fetchedEntities.count != 0 {
                print(fetchedEntities[0])
                return fetchedEntities[0]
            }
        } catch {
            print(error)
        }
        return nil
    }
    
}