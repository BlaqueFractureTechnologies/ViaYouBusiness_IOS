//
//  InstagramAccessResponse.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 28/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

struct InstagramAccessResponse {
    var access_token:String = ""
    var user_id:String = ""
    
    init(_ dictionary: [String: Any]) {
        self.access_token    = dictionary["access_token"] as? String ?? ""
        self.user_id    = dictionary["user_id"] as? String ?? ""
        if let userIdValue = dictionary["user_id"] as? Int {
            self.user_id = "\(userIdValue)"
        }else if let userIdValue = dictionary["user_id"] as? String {
            self.user_id = "\(userIdValue)"
        }
    }
}
