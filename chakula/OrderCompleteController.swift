//
//  OrderCompleteController.swift
//  chakula
//
//  Created by Agree Ahmed on 8/6/15.
//  Copyright © 2015 org.rhye. All rights reserved.
//

import UIKit
import CoreLocation

class OrderCompleteController: UIViewController, OrderAPIProtocol {
    var order: Order?
    var token: String?
    var totalPrice: Double?

    @IBOutlet weak var errorBar: UILabel!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var truckLabel: UILabel!
    @IBOutlet weak var extrasLabel: UILabel!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var pickUpLabel: UILabel!
    @IBOutlet weak var picker: UIDatePicker!
    var error: String {
        get {
            return errorBar.text!
        }
        set {
            errorBar.text! = newValue
        }
    }
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
    var location: String {
        get {
            return locationLabel.text!
        }
        set {
            locationLabel.text! = newValue
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
    
    var orderApi: OrderAPIController?
    override func viewDidLoad(){
        super.viewDidLoad()
        orderButton.setTitle("Place Order - $\(totalPrice!)", forState: .Normal)
        orderApi = OrderAPIController(delegate: self)
        print("viewDidLoad")
        if order != nil {
            setOrderTitle()
            setOrderExtras()
            truckName = (order?.foodItem?.truck?.name)!
            setupPickup()
            setLocation()
            // set order title [DONE]
            // set order extras (toggleOptions)
            // set truck name
            // set location of truck?
        } else {
            print("oh shit")
        }
    }
    
    private func setOrderTitle(){
        title = "Order"
        foodTitle = (order?.foodItem?.name)!
        let radioOptions = order!.radioOptions
        if radioOptions.count < 1 {
            return
        }
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
        extras = ""
        let toggledIds = order!.toggledOptions
        if toggledIds.count < 1 {
            return
        }
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
    private func setLocation(){
        let location = CLLocation(latitude: (order?.foodItem?.truck?.lat)!,
                                    longitude: (order?.foodItem?.truck?.lon)!)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            if placemarks!.count > 0,
                let pm = placemarks![0] as? CLPlacemark {
                print("got to placemarks")
                if let addressDict = pm.addressDictionary as Dictionary?,
                    streetAddress = addressDict["Street"] as! String?{
                        self.location = streetAddress
                } else {
                    self.location = pm.name!
                }
            } else {
                print("Problem with the data received from geocoder")
            }
        })

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
        if picker.date > order!.foodItem!.truck!.close {
            error = "Your pickup time is after the truck closes. Please choose an earler time"
            errorBar.hidden = false
        }
        else {
            let pickupTime = picker.date.timeIntervalSince1970
            let pickupTimeInt = Int(round(pickupTime))
            orderApi!.order(self.token!, foodItem: (order?.foodItem)!, toggleOptions: (order?.toggledOptions)!, radioOptions: (order?.radioOptions)!, quantity: (order?.quantity!)!, pickupTime: pickupTimeInt)
            errorBar.hidden = true
            print(pickupTimeInt)
        }
    }
    
    func orderDidSucceed() {
        // start segue to orderComplete
        var mixProps = [String : String]()
        mixProps[MixKeys.USER_ID] = "\(UserAPIController().getUserData()!.id)"
        mixProps[MixKeys.FOOD_ID] = "\(order!.foodItem!.id)"
        Mixpanel.sharedInstance().track(MixKeys.EVENT.ORDER_PLACE, properties: mixProps)
        performSegueWithIdentifier("orderComplete", sender: nil)
    }
    
    func orderDidFail() {
        error = "We couldn't process your order. Please try again"
        errorBar.hidden = false
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