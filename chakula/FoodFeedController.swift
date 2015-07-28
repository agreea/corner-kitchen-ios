//
//  ViewController.swift
//  chakula
//
//  Created by Agree Ahmed on 7/11/15.
//  Copyright (c) 2015 org.rhye. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class FoodFeedController: UIViewController, UITableViewDataSource, UITableViewDelegate, FeedAPIProtocol, UserAPIProtocol, CLLocationManagerDelegate,
    UITextFieldDelegate {
    // TODO: figure out flow based off of location availability
    /*
        open app
        try to get location
        if you don't have lovarion, load the last known location (?)
        if you don't have the last known location, show an error message (?)
    */
    var manager: CLLocationManager!

    // Registration and Login interface components
    var userApi: UserAPIController!
    var userData: UserData?
    @IBOutlet weak var errorBanner: UILabel!
    @IBOutlet weak var registerLogin: UIView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var phoneNumberVerifyCode: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var registerVerifyButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var setUpSubTitle: UILabel!
    @IBOutlet weak var setUpFirstTitle: UILabel!
    
    var foodItems = [FoodItem]()
    let kCellIdentifier: String = "foodCell"
    var feedApi : FeedAPIController!
    @IBOutlet weak var foodList: UITableView!
    var imgCache = [String:UIImage]()
    var labelColor = UIColor.whiteColor()
    let outputFormatter = NSDateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("About to invoke feedAPI")
        feedApi = FeedAPIController(delegate: self)
        print("About to invoke userAPI")
        userApi = UserAPIController(delegate: self)
        print("About to invoke location manager")

        manager = CLLocationManager()
        if #available(iOS 8.0, *) {
            manager.requestWhenInUseAuthorization()
        } else {
            // Fallback on earlier versions
        }
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        phoneNumberVerifyCode.placeholder = "Phone #"
        password.placeholder = "Password"
        password.delegate = self
        phoneNumberVerifyCode.delegate = self
        outputFormatter.dateFormat = "hh':'mm"
        outputFormatter.locale = NSLocale(localeIdentifier: "en_US")
        setUpFirstTitle.lineBreakMode = .ByWordWrapping
        setUpFirstTitle.numberOfLines = 0
        setUpSubTitle.numberOfLines = 0
        setUpSubTitle.lineBreakMode = .ByWordWrapping
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        feedApi.findFood()
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
//        for cell in self.foodList.visibleCells as! [FoodFeedCell] {
//            cell.truckName.sizeToFit()
//            let oldFrame = cell.truckName.frame
//            let newWidth = oldFrame.size.width + 40
//            let newOrigin = CGPoint(x: oldFrame.origin.x + 40, y: oldFrame.origin.y)
//            var newSize = CGSize(width: newWidth,height: cell.truckName.frame.size.height)
//            cell.truckName.sizeToFit()
//            // TODO: Get frame right
////            cell.truckName.frame = CGRect(origin: newOrigin, size: newSize)
//        }
    }
    
    func locationManager(manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]){
        let location = locations.last as CLLocation!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func didReceiveAPIResults(results: [FoodItem]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.foodItems = results
            if(self.foodItems.count == 0) {
            } else {
                self.foodList!.reloadData()
            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    func queryFailed(){
        dispatch_async(dispatch_get_main_queue(), {
                // TODO: Show error message on feed
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            self.setFeedMessage("No network connection :(")
        })
    }
    
    func setFeedMessage(message: String){
        let messageLabel = UILabel(frame: CGRectMake(0, 0, self.foodList.bounds.size.width, self.foodList.bounds.size.height))
        messageLabel.text = message
        messageLabel.sizeToFit()
        self.foodList.backgroundView = messageLabel
        self.foodList.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodItems.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let (cell, imgURL) = setUpCell(tableView, indexPath: indexPath)
        print("Entered TableView")
        if let img = self.imgCache[imgURL] {
            print("adding image to cache")
            cell.foodImage!.image = img
        } else if let url = NSURL(string: imgURL){
            let request = NSURLRequest(URL: url)
            print("Entered TableView first else")
            print("imgURL: \(imgURL)")
            let mainQueue = NSOperationQueue.mainQueue()
            print("About to enter the asnc request")
            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                if error == nil {
                    print("Got to the async request completion!")
                    let image = UIImage(data: data!)
                    self.imgCache[imgURL] = image
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? FoodFeedCell {
                            print("Got 'Cell to update!'")
                                cellToUpdate.foodImage!.image = image
                                cellToUpdate.truckName?.sizeToFit()
                            }
                        })
                    } else {
                        print("found error")
                        print("Error: \(error!.localizedDescription)")
                    }
                })
            }
        return cell
    }
    
    private func setUpCell(tableView: UITableView, indexPath: NSIndexPath) -> (FoodFeedCell, String) {
        print("In set up cell")
        let cell: FoodFeedCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as! FoodFeedCell
        let foodItem = self.foodItems[indexPath.row]
        cell.foodTitle?.text = foodItem.name!
        cell.foodPrice?.text = "$\(foodItem.price!)"
        cell.foodImage?.image = UIImage(named: "pacman.png")
        cell.truckName?.text = foodItem.truck!.name
        cell.truckName?.sizeToFit()
        cell.distance?.text = "\(foodItem.truck!.dist)mi"
        cell.truckName?.translatesAutoresizingMaskIntoConstraints
        cell.truckName?.sizeToFit()
        print("width: \(cell.truckName.frame.width)")
        print("size: \(cell.truckName.frame.size)")
        print("origin: \(cell.truckName.frame.origin)")
        let openString = outputFormatter.stringFromDate(foodItem.truck!.open)
        let closeString = outputFormatter.stringFromDate(foodItem.truck!.close)
        cell.pickupRange?.text = "\(openString) - \(closeString)"
        print("Leaving set up cell")
        return (cell, foodItem.imgURL!)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool{
        if userData == nil {
            userData = userApi.getUserData()
        }
        if userData != nil  {
            return true
        } else {
            registerLogin.hidden = false
            return false
        }
    }

    @IBAction func cancelRegistrationPressed(sender: AnyObject) {
        registerLogin.hidden = true
    }
    
    @IBAction func registerPressed(sender: UIButton) {
        if sender.titleLabel?.text! == "Register" {
            attemptRegister()
        } else if sender.titleLabel?.text! == "Verify" {
            userApi.verify(phoneNumberVerifyCode.text!)
            errorBanner.hidden = true
        } else if sender.titleLabel?.text! == "Place My First Order" {
            performSegueWithIdentifier("toOrder", sender: nil)
            registerLogin.hidden = true
        }
    }
    
    private func attemptRegister() {
        if phoneNumberVerifyCode.text!.characters.count != 10 {
            revealErrorBanner("We need a 10-digit phone number!")
        } else if password.text?.characters.count < 4 {
            revealErrorBanner("Please enter a longer password")
        } else if firstName.text!.characters.count < 2 {
            revealErrorBanner("Please enter your full first name")
        } else if lastName.text!.characters.count < 2 {
            revealErrorBanner("Please enter your full last name")
        } else {
            userApi.register(Int(phoneNumberVerifyCode.text!)!, pass: password.text!, first: firstName.text!, last: lastName.text!)
            showRegisterInProgress()
        }
    }
    
    
    func registerResult(message: String, didSucceed: Bool) {
        registerVerifyButton.userInteractionEnabled = true
        loginButton.userInteractionEnabled = true
        if didSucceed {
            showVerifyInterface(message)
        } else {
            revealErrorBanner(message)
        }
    }
    
    func verifyResult(message: String, didSucceed: Bool) {
        if didSucceed {
            showVerifyCompleteInterface()
        } else {
            revealErrorBanner(message)
        }
    }
    
    private func revealErrorBanner(message: String) {
        errorBanner.text = message
        errorBanner.hidden = false
    }
    
    private func showRegisterInProgress(){
        registerVerifyButton.titleLabel?.text = "Registering..."
        registerVerifyButton.userInteractionEnabled = false
        loginButton.userInteractionEnabled = false
        errorBanner.hidden = true
    }
    
    private func showVerifyInterface(message: String){
        loginButton.hidden = true
        firstName.hidden = true
        lastName.hidden = true
        password.hidden = true
        errorBanner.hidden = true
        backButton.hidden = false
        phoneNumberVerifyCode.text = ""
        phoneNumberVerifyCode.placeholder = "Verification code"
        phoneNumberVerifyCode.keyboardType = .Default
        setUpFirstTitle.text = message
        setUpSubTitle.text = "A text should come any second now..."
        registerVerifyButton.setTitle("Verify", forState: .Normal)
    }
    
    private func showVerifyCompleteInterface() {
        password.hidden = true
        phoneNumberVerifyCode.hidden = true
        firstName.hidden = true
        errorBanner.hidden = true
        lastName.hidden = true
        let buttonText = "Place My First Order"
        let stringsize = buttonText.sizeWithFont(UIFont.SystemSize)
        registerVerifyButton.setTitle("Place My First Order", forState: UIControlState.Normal)
        setUpFirstTitle.text! = "Success!"
        setUpSubTitle.text! = "You're all set up. Now let's order some food."
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }

    @IBAction func setUpBackButtonPressed(sender: AnyObject) {
        print("Setup back button pressed")
        loginButton.hidden = false
        password.hidden = false
        phoneNumberVerifyCode.text = ""
        phoneNumberVerifyCode.placeholder = "Phone #"
        phoneNumberVerifyCode.keyboardType = .NumberPad
        firstName.hidden = false
        lastName.hidden = false
        setUpFirstTitle.text = "Before you order..."
        setUpSubTitle.text = "Set up your Chakula account :)"
        registerVerifyButton.setTitle("Register", forState: UIControlState.Normal)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("Segue coming!")
        if let orderController: OrderController = segue.destinationViewController as? OrderController {
            let foodItemIndex = foodList!.indexPathForSelectedRow!.row
            orderController.foodItem = foodItems[foodItemIndex]
        }
    }
}

