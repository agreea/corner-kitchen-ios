//
//  foodFeedCell.swift
//  chakula
//
//  Created by Agree Ahmed on 7/14/15.
//  Copyright (c) 2015 org.rhye. All rights reserved.
//

import UIKit

class FoodFeedCell: UITableViewCell {
    @IBOutlet weak var truckName: UILabel!
    @IBOutlet weak var foodTitle: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var pickupRange: UILabel!
    @IBOutlet weak var foodPrice: UILabel!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var foodItemLabel: UIView!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        foodItemLabel.backgroundColor = UIColor.whiteColor()
        truckName.sizeToFit()
    }

}