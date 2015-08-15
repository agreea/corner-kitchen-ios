//
//  CLLocationManagerExtension.swift
//  chakula
//
//  Created by Agree Ahmed on 8/15/15.
//  Copyright (c) 2015 org.rhye. All rights reserved.
//

import UIKit
import CoreLocation

extension CLLocationManager {
    class func launchLocationDisabledAlert(){
        let title = "Location Disabled"
        let message = "Chakula can't access your location. Enable location services for Chakula in Settings -> Privacy -> Location Services -> Chak Truck"
        let okayText = "Okay"
        launchAlert(title, message: message, okayText: okayText)
    }
    
    class func launchLocationUndeterminedAlert(){
        let title = "Couldn't Find You!"
        let message = "Chakula can't tell where you are. Make sure location services are enabled, or set your location manually by pressing the pin at the top right."
        let okayText = "Okay"
        launchAlert(title, message: message, okayText: okayText)
    }

    private class func launchAlert(title: String, message: String, okayText: String){
        let ios7Alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: okayText)
        ios7Alert.show()
    }

    class func getAddressFor(coord: CLLocationCoordinate2D, callback: (String) -> Void) {
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
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
                            callback(streetAddress)
                    } else {
                        callback(pm.name!)
                    }
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }

}