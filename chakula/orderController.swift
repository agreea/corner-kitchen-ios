//
//  orderController.swift
//  chakula
//
//  Created by Agree Ahmed on 7/13/15.
//  Copyright (c) 2015 org.rhye. All rights reserved.
//

import UIKit

class OrderController: UIViewController {
    var foodItem: FoodItem?
    var quantity: Int = 1
    
    @IBOutlet weak var pickup: UIDatePicker!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var quantLabel: UILabel!
    @IBOutlet weak var orderTitle: UILabel!
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if foodItem != nil {
            descriptionLabel?.lineBreakMode = .ByWordWrapping
            descriptionLabel?.numberOfLines = 0
            orderTitle.text = foodItem!.name!
            descriptionLabel?.text = foodItem!.description
            pickup.minimumDate = foodItem!.truck!.open
            pickup.maximumDate = foodItem!.truck!.close
        }
    }

    @IBAction func quantityChanged(sender: UIStepper) {

    }

    @IBAction func orderpressed(sender: AnyObject) {
        // TODO: POST order
    }
    
    @IBAction func stepperChanged(sender: UIStepper) {
        quantLabel?.text = "Quantity: \(Int(sender.value))"
    }
}