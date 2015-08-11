//
//  MixpanelKeys.swift
//  chakula
//
//  Created by Agree Ahmed on 8/9/15.
//  Copyright © 2015 org.rhye. All rights reserved.
//

import Foundation

struct MixKeys {
    struct EVENT {
        static let LAUNCH = "app launch",
                    FEED_CLICK = "feed click",
                    VER_LOG = "login/ver",
                    VER_LOG_FAIL = "login/verify failed",
                    REGISTER = "register success",
                    REG_FAIL = "reg failed",
                    COMPLETE_ORDER = "complete order",
                    ORDER_PLACE = "order placed",
                    ORDER_FAIL = "order failed",
                    REFRESH = "refresh",
                    EMPTY_REFRESH = "empty refresh",
                    REFRESH_FAIL = "refresh fail"
    }
    
    static let USER_ID = "user",
                FOOD_ID = "menu_item",
                TRUCK_ID = "truck",
                LAT = "lat",
                LON = "lon",
                PRICE = "price",
                PICKUP_TIME = "pickup",
                TRUCK_COUNT = "trucks",
                ITEM_COUNT = "items"
}