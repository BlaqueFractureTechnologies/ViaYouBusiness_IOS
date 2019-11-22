//
//  InstaUserResponse.swift
//  ViaYou
//
//  Created by Arya S on 18/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class InstagramUserResponse: NSObject {
    var data: InstaDataDict = InstaDataDict([:])
    
    init(_ dictionary: [String:Any]) {
        self.data = InstaDataDict(dictionary["data"] as? [String: Any] ?? [:] )
    }
}

class InstaDataDict: NSObject {
    var id:String           = ""
    var username:String     = ""
    var full_name:String     = ""
    var profile_picture:String     = ""
    
    init(_ dictionary: [String:Any]) {
        self.id         = dictionary["id"] as? String ?? ""
        self.username   = dictionary["username"] as? String ?? ""
        self.full_name   = dictionary["full_name"] as? String ?? ""
        self.profile_picture   = dictionary["profile_picture"] as? String ?? ""
    }
}
