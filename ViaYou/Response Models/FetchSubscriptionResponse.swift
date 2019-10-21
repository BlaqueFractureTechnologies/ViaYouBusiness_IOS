//
//  FetchSubscriptionResponse.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 22/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import Foundation
import UIKit

struct FetchSubscriptionResponse {
    var success:Bool = false
    var message:String = ""
    var data:[SubscriptionArrayObject] = []
    
    init(_ dictionary: [String: Any]) {
        self.success    = dictionary["success"] as? Bool ?? false
        self.message    = dictionary["message"] as? String ?? ""
        
        data = []
        let dataArray = dictionary["data"] as? [[String:Any]] ?? []
        for i in 0..<dataArray.count {
            let objectAtIndex = SubscriptionArrayObject(dataArray[i])
            data.append(objectAtIndex)
        }
    }
}

class SubscriptionArrayObject: NSObject {
    var expiry:String = ""
    var _id:String = ""   //Int from API
    var user:String = ""   //Int from API
    var paymentId:String = ""   //Int from API
    var type:String = ""   //Int from API
    var isActive:Bool = false
    var __v:String = ""
    
    init(_ dictionary: [String: Any]) {
        self.isActive  = dictionary["isActive"] as? Bool ?? false
        self.expiry    = dictionary["expiry"] as? String ?? ""
        self._id    = dictionary["_id"] as? String ?? ""
        self.user    = dictionary["user"] as? String ?? ""
        self.paymentId    = dictionary["paymentId"] as? String ?? ""
        self.type    = dictionary["type"] as? String ?? ""
        if let __vValue = dictionary["__v"] as? Int {
            self.__v = "\(__vValue)"
        }else if let __vValue = dictionary["__v"] as? String {
            self.__v = "\(__vValue)"
        }
        
        
        
        
        
        
        
    }
}
