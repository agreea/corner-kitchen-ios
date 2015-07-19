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
    
    init(name: String?, description: String?, imgURL: String?, price: Double?, truck: Truck?){
        self.name = name
        self.description = description
        self.imgURL = imgURL
        self.price = price
        self.truck = truck
    }
}