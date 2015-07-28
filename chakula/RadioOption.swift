//
//  RadioOption.swift
//  chakula
//
//  Created by Agree Ahmed on 7/19/15.
//  Copyright (c) 2015 org.rhye. All rights reserved.
//

import Foundation

struct RadioOption {
    // id -> faimily id
    // value_id -> selected value id
    let familyName: String
    let choices: [(name: String, priceDiff: Double, id: Int)]
    
    init(name: String, choices: [(name: String, priceDiff: Double, id: Int)]){
        self.familyName = name
        self.choices = choices
        print("Radio created! Contents: \(choices)")
    }
}