//
//  OrderToggleOption.swift
//  chakula
//
//  Created by Agree Ahmed on 7/29/15.
//  Copyright © 2015 org.rhye. All rights reserved.
//

import UIKit

class OrderToggleOption: CheckBoxLabel {
    var id: Int?
    var priceDiff: Double?
    
    init(name: String, id: Int, priceDiff: Double, frame: CGRect, fontSize: CGFloat){
        super.init(frame: frame)
        self.id = id
        self.priceDiff = priceDiff
        self.titleLabel!.font =  UIFont(name: self.titleLabel!.font.fontName,
            size: fontSize)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}