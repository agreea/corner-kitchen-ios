//
//  CheckBoxLabel.swift
//  chakula
//
//  Created by Agree Ahmed on 7/21/15.
//  Copyright (c) 2015 org.rhye. All rights reserved.
//

import UIKit

class CheckBoxLabel: UIButton {
    let checkedImage = UIImage(named: "checked")
    let uncheckedImage = UIImage(named: "unchecked")
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                self.setImage(checkedImage, forState: .Normal)
            } else {
                self.setImage(uncheckedImage, forState: .Normal)
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect){
        super.init(frame: frame)
        self.setImage(uncheckedImage, forState: .Normal)
        self.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        self.isChecked = false
    }
    
    func buttonClicked(sender: UIButton){
        if(sender == self){
            if self.isChecked == true {
                self.isChecked = false
            } else {
                self.isChecked = true
            }
        }
    }
}
