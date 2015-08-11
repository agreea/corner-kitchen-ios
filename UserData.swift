//
//  UserData.swift
//  chakula
//
//  Created by Agree Ahmed on 7/27/15.
//  Copyright © 2015 org.rhye. All rights reserved.
//

import Foundation
import CoreData

class UserData: NSManagedObject {
    class func newEntry(managedObjectContext: NSManagedObjectContext, firstName: String, lastName: String, sessionToken: String, id: Int) -> UserData{
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("UserData", inManagedObjectContext: managedObjectContext) as! UserData
        newItem.firstName = firstName
        newItem.lastName = lastName
        newItem.sessionToken = sessionToken
        newItem.id = id
        return newItem
    }
    class func save(managedObjectContext: NSManagedObjectContext){
        do {
            try managedObjectContext.save()
        } catch {
            NSLog("Unresolved error: \(error)")
            abort()
        }
    }
}