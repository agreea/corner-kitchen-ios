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
    var nextViewOrigin = CGPoint(x: 0, y: 0)
    let radioController = SSRadioButtonsController()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
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
            self.nextViewOrigin = CGPoint(x: quantLabel.frame.minX,
                                     y: quantLabel.frame.maxY + 6)
//             TODO: make scrollview
//            self.scrollView.setContentOffset(CGPointMake(0, self.scrollView.contentOffset.y))
            buildRadioOptions()
            buildToggles()
            buildPickup()
            buildOrderButton()
        }
    }
    
    override func viewDidLayoutSubviews(){
        let scrollViewBounds = scrollView.bounds
        let containerViewBounds = contentView.bounds
        
        var scrollViewInsets = UIEdgeInsetsZero
        scrollViewInsets.top = scrollViewBounds.size.height/2.0;
        scrollViewInsets.top -= contentView.bounds.size.height/2.0;
        
        scrollViewInsets.bottom = scrollViewBounds.size.height/2.0
        scrollViewInsets.bottom -= contentView.bounds.size.height/2.0;
        scrollViewInsets.bottom += 1
        
        scrollView.contentInset = scrollViewInsets

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
                buildSectionLabel(radioOption.familyName)
                buildRadioChoices(radioOption)
            }
        }
    }
    
    private func buildRadioChoices(radioOption: RadioOption){
        for choice in radioOption.choices {
            var (name, priceDiff, _) = choice
            let button = SSRadioButton(frame: CGRectMake(self.nextViewOrigin.x, self.nextViewOrigin.y + 8, 160, 24))
            button.backgroundColor = UIColor.greenColor()
            button.setTitle(name + " + $\(priceDiff)", forState: UIControlState.Normal)
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
            button.titleLabel!.font =  UIFont(name: button.titleLabel!.font.fontName,
                                              size: quantLabel.font.pointSize-2)
            self.addViewToBottom(button)
            self.radioController.addButton(button)
        }
    }
    
    private func buildToggles(){
        for toggleOption in foodItem!.toggleOptions {
            // make a new button with a new associated option
         // let toggleOption: (name: String, priceDiff: Double, id: Int)
            let (name, priceDiff, id) = toggleOption
            let button = CheckBoxLabel(frame:  CGRectMake(self.nextViewOrigin.x, self.nextViewOrigin.y + 8, 160, 24))
            button.backgroundColor = UIColor.blueColor()
            button.setTitle(name + " + $\(priceDiff)", forState: UIControlState.Normal)
            self.addViewToBottom(button)
        }
    }
    
    private func buildPickup(){
        buildSectionLabel("Pickup")
        let pickup = UIDatePicker(frame: CGRect(origin: nextViewOrigin,
            size: CGSize(width: Int(self.contentView.frame.width), height: 100)))
        pickup.minimumDate = foodItem!.truck!.open
        pickup.maximumDate = foodItem!.truck!.close
        pickup.datePickerMode = .Time
        pickup.minuteInterval = 5
        self.addViewToBottom(pickup)
    }
    
    private func buildOrderButton(){
        let order = UIButton(frame: CGRect(origin: nextViewOrigin,
                           size: CGSize(width: Int(self.contentView.frame.width), height: 35)))
        order.backgroundColor = UIColor.greenColor()
        order.titleLabel?.text = "Order"
        self.addViewToBottom(order)
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