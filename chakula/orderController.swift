//
//  orderController.swift
//  chakula
//
//  Created by Agree Ahmed on 7/13/15.
//  Copyright (c) 2015 org.rhye. All rights reserved.
//

import UIKit

class OrderController: UIViewController, OrderRadioControllerProtocol {
    var foodItem: FoodItem?
    var quantity: Int = 1
    var nextViewOrigin = CGPoint(x: 0, y: 0)
    var token: String?
    var unitTotal: Double = 0
    var radioControllers = [OrderRadioController]()
    var totalPrice: Double {
        get {
            return unitTotal * quantStepper.value
        }
        set {
            totalLabel.text = "Total: $\(unitTotal * quantStepper.value)"
        }
    }
    var priceChangers = [String: Double]()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var quantStepper: UIStepper!
    @IBOutlet weak var quantLabel: UILabel!
    @IBOutlet weak var orderTitle: UILabel!
    var totalLabel: UILabel!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    // BUILD-UI CODE
    override func viewDidLoad() {
        super.viewDidLoad()
        if foodItem != nil {
            unitTotal = Double((foodItem?.price)!)
            descriptionLabel?.lineBreakMode = .ByWordWrapping
            descriptionLabel?.numberOfLines = 0
            orderTitle.text = foodItem!.name!
            descriptionLabel?.text = foodItem!.description
            self.nextViewOrigin = CGPoint(x: quantLabel.frame.minX,
                                     y: quantLabel.frame.maxY + 60)
            print("Next view origin after quant: \(nextViewOrigin)")
            priceChangers = [:]
            buildRadioOptions()
            buildToggles()
            buildTotalLabel()
            buildPickup()
//             TODO: make scrollview
//            self.scrollView.setContentOffset(CGPointMake(0, self.scrollView.contentOffset.y))
        }
    }
    
    override func viewDidLayoutSubviews(){
        let scrollViewBounds = scrollView.bounds
        var scrollViewInsets = UIEdgeInsetsZero
        scrollViewInsets.top = scrollViewBounds.size.height/2.0;
        scrollViewInsets.top -= contentView.bounds.size.height/2.0;
        scrollViewInsets.bottom = scrollViewBounds.size.height/2.0
        scrollViewInsets.bottom -= contentView.bounds.size.height/2.0;
        scrollViewInsets.bottom += 1
        scrollView.contentInset = scrollViewInsets
        scrollView.frame = CGRectMake(self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, scrollView.frame.width, scrollView.frame.height - 60)
    }
    
    private func addViewToBottom(view: UIView){
        self.scrollView.addSubview(view)
        nextViewOrigin = CGPoint(x: view.frame.minX, y: view.frame.maxY)
    }

    private func buildSectionLabel(title: String){
        let label = UILabel(frame: CGRectMake(self.nextViewOrigin.x, nextViewOrigin.y + 8, 250, 20))
        label.text = title
        label.font =  UIFont(name: label.font.fontName,
            size: quantLabel.font.pointSize)
        self.addViewToBottom(label)
    }

    private func buildRadioOptions(){
        if(foodItem?.radioOptions != nil){
            for radioOption in foodItem!.radioOptions {
                print(radioOption.familyName)
                buildSectionLabel(radioOption.familyName)
                buildRadioChoices(radioOption)
            }
        }
    }
    
    private func buildRadioChoices(radioOption: RadioOption){
        let radioController = OrderRadioController(delegate: self, name: radioOption.familyName)
        for choice in radioOption.choices {
            let (name, priceDiff, id) = choice
            let button = OrderRadioOption(name: name, id: id, priceDiff: priceDiff, frame: CGRectMake(self.nextViewOrigin.x, self.nextViewOrigin.y + 8, 160, 24), fontSize: quantLabel.font.pointSize)
            addViewToBottom(button)
            radioController.addButton(button)
        }
        radioControllers.append(radioController)
        priceChangers[radioController.id!] = 0.0
    }
    
    private func buildToggles(){
        for toggleOption in foodItem!.toggleOptions {
            // make a new button with a new associated option
         // let toggleOption: (name: String, priceDiff: Double, id: Int)
            let (name, priceDiff, id) = toggleOption
            let button = OrderToggleOption(name: name, id: id, priceDiff: priceDiff, frame:  CGRectMake(self.nextViewOrigin.x, self.nextViewOrigin.y + 8, 160, 24), fontSize: quantLabel.font.pointSize)
            button.setTitle("  " + name + " + $\(priceDiff)", forState: UIControlState.Normal)
            button.sizeToFit()
            button.titleLabel!.enabled = true
            button.setTitleColor(UIColor.blackColor(), forState: .Normal)
            button.addTarget(self, action: "toggleChanged:", forControlEvents: UIControlEvents.TouchUpInside)
            priceChangers["\(button.id!)"] = 0.0
            self.addViewToBottom(button)
        }
    }
    
    private func buildPickup(){
        let outputFormatter = NSDateFormatter()
        outputFormatter.dateFormat = "hh':'mm"
        outputFormatter.locale = NSLocale(localeIdentifier: "en_US")
        // if open data before current time, set string to "(closes \(closeString)"
        // else (open - close)
        let open = foodItem?.truck?.open
        let close = foodItem?.truck?.close
        let now = NSDate(timeIntervalSince1970: NSDate().timeIntervalSince1970)
        let openString = outputFormatter.stringFromDate(open!)
        let closeString = outputFormatter.stringFromDate(close!)
        let pickUpString: String?
        if now > open {
            pickUpString = "Pickup (closes \(closeString))"
        } else {
            pickUpString = "Pickup (\(openString) - \(closeString))"
        }
        buildSectionLabel(pickUpString!)
        let pickup = UIDatePicker(frame: CGRect(origin: nextViewOrigin,
            size: CGSize(width: Int(self.contentView.frame.width), height: 60)))
        pickup.minimumDate = foodItem!.truck!.open
        pickup.maximumDate = foodItem!.truck!.close
        pickup.datePickerMode = .Time
        pickup.minuteInterval = 5
        self.addViewToBottom(pickup)
    }
    
    private func buildTotalLabel(){
        totalLabel = UILabel(frame: CGRectMake(self.nextViewOrigin.x, nextViewOrigin.y + 8, UIScreen.mainScreen().bounds.width - 24, 40))
        totalLabel.text = "Total: $\(unitTotal)"
        totalLabel.font =  UIFont(name: totalLabel.font.fontName,
                             size: quantLabel.font.pointSize + 4)
        totalLabel.textAlignment = .Right
        self.addViewToBottom(totalLabel)
    }
    
    // EVENT LISTENERS
    func toggleChanged(sender: AnyObject) {
        var priceModifier = 0.0
        // TODO: make into switch/case
        if let toggle = sender as? OrderToggleOption {
            if toggle.isChecked {
                print("Toggle wasn't checked when it was pressed!")
                priceModifier = toggle.priceDiff!
            }
            priceChangers["\(toggle.id!)"] = priceModifier
        }
        priceChanged()
    }
    
    func radioSelectionChanged(id: String, priceDiff: Double){
        print("OrderController: Roger roger --- \(id) => \(priceDiff)")
        priceChangers[id] = priceDiff
        priceChanged()
    }
    
    private func priceChanged(){
        unitTotal = (foodItem?.price!)!
        for (id, priceModifier) in priceChangers {
            print("\(id) --> \(priceModifier)")
            unitTotal += priceModifier
        }
//        unitTotal += priceDiff
        totalPrice = unitTotal * quantStepper.value
    }
    private func getRadioSelectionIds() -> [Int]{
        var radioSelectionIds = [Int]()
        for radioController in radioControllers {
            if radioController.selectedButtonId! != -1 {
                radioSelectionIds.append(radioController.selectedButtonId!)
            }
        }
        return radioSelectionIds
    }
    @IBAction func quantityChanged(sender: UIStepper) {

    }
    
    @IBAction func orderpressed(sender: AnyObject) {
        let orderApi = OrderAPIController()
        orderApi.order(self.token!, foodItem: foodItem!, toggleOptions: [2,4], radioOptions: getRadioSelectionIds(), quantity: 3, pickupTime: 44444)
    }
    
    @IBAction func stepperChanged(sender: UIStepper) {
        quantLabel?.text = "Quantity: \(Int(sender.value))"
        priceChanged()
    }    
}