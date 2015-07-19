//
//  truck.swift
//  chakula
//
//  Created by Agree Ahmed on 7/13/15.
//  Copyright (c) 2015 org.rhye. All rights reserved.
//

import Foundation

struct Truck {
    let name: String
    let id: Int
    let dist: Double
    let lat: Double
    let lon: Double
    let description: String
    let open: NSDate
    let close: NSDate

    // takes rfc339 Date format for opemFrom, openTil
    init(name:String, id: Int, open: NSDate, close: NSDate, dist:Double, description: String, lat: Double, lon: Double){
        self.name = name
        self.dist = dist
        self.lat = lat
        self.lon = lon
        self.description = description
        self.id = id
        self.open = open
        self.close = close
    }    
}