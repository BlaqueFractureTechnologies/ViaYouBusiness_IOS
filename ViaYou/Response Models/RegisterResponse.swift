//
//  RegisterResponse.swift
//  Promptchu
//
//  Created by Promptchu Pty Ltd on 24/7/19.
//  Copyright © 2019 AryaSreenivasan. All rights reserved.
//

import UIKit

struct RegisterResponse {
    var success:Bool = false
    var message:String = ""
    
    init(_ dictionary: [String: Any]) {
        self.success    = dictionary["success"] as? Bool ?? false
        self.message    = dictionary["message"] as? String ?? ""
    }
}
