//
//  OrderCompleteController.swift
//  chakula
//
//  Created by Agree Ahmed on 8/6/15.
//  Copyright © 2015 org.rhye. All rights reserved.
//

import UIKit

class OrderCompleteController: UIViewController {
    var order: Order?
    var token: String?
    var totalPrice: Double?

    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var truckLabel: UILabel!
    @IBOutlet weak var extrasLabel: UILabel!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var pickUpLabel: UILabel!
    @IBOutlet weak var picker: UIDatePicker!
    var foodTitle: String {
        get {
            return foodLabel.text!
        }
        set {
            foodLabel.text! = newValue
        }
    }
    
    var extras: String {
        get {
            return extrasLabel.text!
        }
        set {
            extrasLabel.text! = newValue
        }
    }

    var truckName: String {
        get {
            return truckLabel.text!
        }
        set {
            truckLabel.text! = newValue
        }
    }
    
    var pickup: String {
        get {
            return pickUpLabel.text!
        }
        set {
            pickUpLabel.text! = newValue
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        orderButton.setTitle("Place Order - $\(totalPrice!)", forState: .Normal)
        if order != nil {
            setOrderTitle()
            setOrderExtras()
            truckName = (order?.foodItem?.truck?.name)!
            setupPickup()
            // set order title [DONE]
            // set order extras (toggleOptions)
            // set truck name
            // set location of truck?
            // set closing time
        } else {
            print("oh shit")
        }
    }
    
    private func setOrderTitle(){
        title = "Order"
        foodTitle = (order?.foodItem?.name)!
        let radioOptions = order!.radioOptions
        if order!.radioOptions.count > 0 {
            var radioSubString = " ("
            for i  in 0...radioOptions.count-1 {
                radioSubString += "\(getRadioOptionNameForId(radioOptions[i]))"
                if (i < radioOptions.count - 1){
                    radioSubString += ", "
                } else {
                    radioSubString += ")"
                }
            }
            print("Radio substring: \(radioSubString)")
            foodTitle += radioSubString
        }
    }
    
    private func getRadioOptionNameForId(radioOptionId: Int) -> String {
        for radioOption in order!.foodItem!.radioOptions {
            for choice in radioOption.choices {
                if radioOptionId == choice.id {
                    return choice.name
                }
            }
        }
        return ""
    }
    
    private func setOrderExtras(){
        var extras = ""
        let toggledIds = order!.toggledOptions
        for i in 0...toggledIds.count - 1 {
            for toggleOption in order!.foodItem!.toggleOptions {
                if toggledIds[i] == toggleOption.id {
                    extras += "\(toggleOption.name)"
                }
                if i < toggledIds.count - 2 {
                    extras += ", "
                }
            }
        }
    }
    
    private func setupPickup(){
        let outputFormatter = NSDateFormatter()
        outputFormatter.dateFormat = "hh':'mm"
        outputFormatter.locale = NSLocale(localeIdentifier: "en_US")
        let open = order?.foodItem?.truck?.open
        let close = order?.foodItem?.truck?.close
        let now = NSDate(timeIntervalSince1970: NSDate().timeIntervalSince1970)
        let openString = outputFormatter.stringFromDate(open!)
        let closeString = outputFormatter.stringFromDate(close!)
        if now > open {
            pickup = "Pickup (open until \(closeString))"
            let nowPlusFifteenMinutes = NSDate().timeIntervalSince1970 + 30 * 60
            picker.minimumDate = NSDate(timeIntervalSince1970: nowPlusFifteenMinutes)
        } else {
            picker.minimumDate = order?.foodItem!.truck!.open
            pickup = "Pickup (\(openString) - \(closeString))"
        }
        picker.maximumDate = order?.foodItem!.truck!.close
    }
    
    @IBAction func placeOrderWasPressed(sender: AnyObject) {
        let orderApi = OrderAPIController()
        let pickupTime = picker.date.timeIntervalSince1970
        let pickupTimeInt = Int(round(pickupTime))
        orderApi.order(self.token!, foodItem: (order?.foodItem)!, toggleOptions: (order?.toggledOptions)!, radioOptions: (order?.radioOptions)!, quantity: (order?.quantity!)!, pickupTime: pickupTimeInt)
        print(pickupTimeInt)
    }
    
    /*
    
    // completeOrderPressed --> placeOrder(order)
    // orderDidPlace
    // orderDidFail { reveal error banner
    
    private func setOrderTitle() {
        title = order.foodItem.name
        if radioSelections > 0 {
            for radioSelection in radioSelections {
                if radioSelection ==
            }
    }
    
    private getRadioSelectionNameForId(id: Int) -> String {
        // go through the radio options
        // if the radioId matches the current id, return the name
        // finally, return ""
    }
    private setExtrasTitle(){
        for toggle in order.toggles {
            //
        }
    }
    */
}