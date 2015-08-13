//
//  UserData.swift
//  
//
//  Created by Agree Ahmed on 8/11/15.
//
//

import Foundation
import CoreData

class UserData: NSManagedObject {

    @NSManaged var firstName: String
    @NSManaged var id: NSNumber
    @NSManaged var lastName: String
    @NSManaged var sessionToken: String
    
    class func newEntry(managedObjectContext: NSManagedObjectContext, firstName: String, lastName: String, sessionToken: String, id: Int) -> UserData {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("UserData", inManagedObjectContext: managedObjectContext) as! UserData
        newItem.firstName = firstName
        newItem.lastName = lastName
        newItem.sessionToken = sessionToken
        newItem.id = id
        return newItem
    }
    class func save(managedObjectContext: NSManagedObjectContext){
        var error : NSError?
        if(managedObjectContext.save(&error) ) {
            println(error?.localizedDescription)
        }
    }

}
