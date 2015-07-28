//
//  food.swift
//  chakula
//
//  Created by Agree Ahmed on 7/13/15.
//  Copyright (c) 2015 org.rhye. All rights reserved.
//

import Foundation

struct FoodItem {
    let name: String?
    let description: String?
    let imgURL: String?
    let price: Double?
    let truck: Truck?
    var radioOptions: [RadioOption]
    var toggleOptions: [(name: String, priceDiff: Double, id: Int)]

    // list options
    // toggle options
    init(name: String?, description: String?, imgURL: String?,
        price: Double?, truck: Truck?, radioOptions: [RadioOption],
        toggleOptions: [(name: String, priceDiff: Double, id: Int)]){
        self.name = name
        self.description = description
        self.imgURL = imgURL
        self.price = price
        self.truck = truck
        self.radioOptions = radioOptions
        self.toggleOptions = toggleOptions
        print("Radios: \(radioOptions)")
        print("Toggles: \(toggleOptions)")
    }
}