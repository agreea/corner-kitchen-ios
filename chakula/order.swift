//
//  order.swift
//  chakula
//
//  Created by Agree Ahmed on 8/6/15.
//  Copyright © 2015 org.rhye. All rights reserved.
//

import Foundation

struct Order {
    var foodItem: FoodItem?
    var toggledOptions: [Int]
    var radioOptions: [Int]
    var quantity: Int?
    var pickupTime: Int?
    
    init(foodItem: FoodItem, toggledOptions: [Int], radioOptions: [Int], quantity: Int, pickupTime: Int){
        self.foodItem = foodItem
        self.toggledOptions = toggledOptions
        self.radioOptions = radioOptions
        self.pickupTime = pickupTime
        self.quantity = quantity
    }
}