//
//  BucketSizeResponse.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 16/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import Foundation
import UIKit

class BucketSizeResponse {
    var success: Bool = false
    var message:String = ""
    var data:BucketDataObject = BucketDataObject([:])
    
    init(_ dictionary: [String: Any]) {
        self.success = dictionary["sucecss"] as? Bool ?? false
        self.message = dictionary["message"] as? String ?? ""
        self.data = BucketDataObject(dictionary["data"] as? [String:Any] ?? [:])
    }
}

class BucketDataObject: NSObject {
    var _id: String = ""
    var storage: String = ""
    var storageExpireDate: String = ""
    init(_ dictionary: [String: Any]) {
        self._id            = dictionary["_id"] as? String ?? ""
        if let storageCountValue = dictionary["storage"] as? Int {
            self.storage = "\(storageCountValue)"
        }else if let storageCountValue = dictionary["storage"] as? String {
            self.storage = "\(storageCountValue)"
        }
        self.storageExpireDate           = dictionary["storageExpireDate"] as? String ?? ""
    }
    
}
