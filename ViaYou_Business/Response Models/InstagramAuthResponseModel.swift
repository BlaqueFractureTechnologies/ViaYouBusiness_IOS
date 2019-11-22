//
//  InstagramAuthResponseModel.swift
//  Promptchu
//
//  Created by Promptchu Pty Ltd on 26/7/19.
//  Copyright © 2019 AryaSreenivasan. All rights reserved.
//

import UIKit

struct InstagramAuthResponseModel {
    // var result:[ListResult] = [:]
    var username:String = ""
    var user_id:String = ""
    
    init(_ dictionary: [String: Any]) {
        self.username    = dictionary["username"] as? String ?? ""
        self.user_id    = dictionary["id"] as? String ?? ""
        if let userIdValue = dictionary["id"] as? Int {
            self.user_id = "\(userIdValue)"
        }else if let userIdValue = dictionary["user_id"] as? String {
            self.user_id = "\(userIdValue)"
        }
    }
}
