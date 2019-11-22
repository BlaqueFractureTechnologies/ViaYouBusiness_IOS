//
//  DeleteVideoResponse.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 18/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import Foundation
import UIKit

struct DeleteVideoResponse {
    var success:Bool = false
    var message:String = ""
    
    init(_ dictionary: [String: Any]) {
        self.success    = dictionary["success"] as? Bool ?? false
        self.message    = dictionary["message"] as? String ?? ""
    }
}
