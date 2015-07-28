//
//  UserData+CoreDataProperties.swift
//  chakula
//
//  Created by Agree Ahmed on 7/27/15.
//  Copyright © 2015 org.rhye. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension UserData {

    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var sessionToken: String?

}
