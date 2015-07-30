//
//  OrderRadioController.swift
//  chakula
//
//  Created by Agree Ahmed on 7/29/15.
//  Copyright © 2015 org.rhye. All rights reserved.
//

import UIKit
protocol OrderRadioControllerProtocol {
    func radioSelectionChanged(id: String, priceDiff: Double)
}
class OrderRadioController: SSRadioButtonsController {
    var orderDelegate: OrderRadioControllerProtocol?
    var id: String?
    var selectedButtonId: Int?
    init(delegate: OrderRadioControllerProtocol, name: String){
        super.init()
        self.id = OrderRadioController.idFromName(name)
        self.orderDelegate = delegate
        self.selectedButtonId = -1
    }
    
    override func pressed(sender: UIButton) {
        super.pressed(sender)
        print("RadioController pressed")
        if let orderRadioOption = sender as? OrderRadioOption {
            orderDelegate?.radioSelectionChanged(id!, priceDiff: orderRadioOption.priceDiff!)
            selectedButtonId = orderRadioOption.id!
        }
    }
    class func idFromName(name: String) -> String{
        return "RADIO_OPTION_\(name)"
    }
}
