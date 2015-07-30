//
//  OrderRadioOption.swift
//  chakula
//
//  Created by Agree Ahmed on 7/29/15.
//  Copyright © 2015 org.rhye. All rights reserved.
//

import UIKit

class OrderRadioOption: SSRadioButton {
    var priceDiff: Double?
    var id: Int?
    
    init(name: String, id: Int, priceDiff: Double, frame: CGRect, fontSize: CGFloat){
        super.init(frame: frame)
        setTitle("  " + name + " + $\(priceDiff)", forState: UIControlState.Normal)
        contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        titleLabel!.font =  UIFont(name: titleLabel!.font.fontName,
            size: fontSize)
        setTitleColor(UIColor.blackColor(), forState: .Normal)
        titleLabel!.enabled = true
        self.priceDiff = priceDiff
        self.id = id
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}