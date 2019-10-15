//
//  InstagramUserDetailsResponse.swift
//  Promptchu
//
//  Created by Promptchu Pty Ltd on 29/7/19.
//  Copyright © 2019 AryaSreenivasan. All rights reserved.
//

import UIKit

struct InstagramUserDetailsResponse {
    var success:Bool = false
    var message:String = ""
    var accessToken:String = ""
    
    
    init(_ dictionary: [String: Any]) {
        self.success    = dictionary["success"] as? Bool ?? false
        self.message    = dictionary["message"] as? String ?? "Incorrect Message"
        self.accessToken    = dictionary["accessToken"] as? String ?? "Incorrect Token"
        
    }
}
