//
//  foodFeedCell.swift
//  chakula
//
//  Created by Agree Ahmed on 7/14/15.
//  Copyright (c) 2015 org.rhye. All rights reserved.
//

import UIKit
import CoreLocation
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
        truckName.backgroundColor = UIColor(red: 0.212, green: 0.212, blue: 0.212, alpha: 0.85)
//        truckName.backgroundColor = UIColor(colorLiteralRed: 0.212, green: 0.212, blue: 0.212, alpha: 0.85)
    }
    
    func setupCell(foodItem: FoodItem, truckAddress: String?, outputFormatter: NSDateFormatter) {
        foodTitle?.text = foodItem.name!
        foodPrice?.text = "$\(foodItem.price!)"
        foodImage?.image = UIImage(named: "loading")
        truckName?.text = foodItem.truck!.name
        if truckAddress != nil {
            distance?.text = truckAddress
        } else {
            setTruckLocation(foodItem.truck!)
        }
        let openString = outputFormatter.stringFromDate(foodItem.truck!.open)
        let closeString = outputFormatter.stringFromDate(foodItem.truck!.close)
        pickupRange?.text = "\(openString) - \(closeString)"

    }
    
    private func setTruckLocation(truck: Truck) {
        let coord = CLLocationCoordinate2D(latitude: truck.lat, longitude: truck.lon)
        CLLocationManager.getAddressFor(coord){ address -> Void in
            self.distance?.text = address
            self.distance?.textColor = UIColor.blackColor()
            self.distance?.sizeToFit()
            self.distance?.textColor = UIColor.blackColor()
        }
    }
    
    func getImage(url: NSURL, callback: (UIImage) -> Void) {
        let request = NSURLRequest(URL: url)
        let mainQueue = NSOperationQueue.mainQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
            if error == nil {
                let toImage = UIImage(data: data!)
                callback(toImage!)
                dispatch_async(dispatch_get_main_queue(), {
                    UIView.transitionWithView(self.foodImage!,
                        duration:0.7,
                        options: UIViewAnimationOptions.TransitionCrossDissolve,
                        animations: { self.foodImage!.image = toImage },
                        completion: nil)
                })
            } else {
                print("Error: \(error!.localizedDescription)")
            }
        })
    }
}