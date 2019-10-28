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
    var result: ListResult = ListResult([:])
    
    init(_ dictionary: [String:Any]) {
        self.result = ListResult(dictionary["data"] as? [String: Any] ?? [:] )
    }
}

struct ListResult {
    var user_id:String           = ""
    var access_token:String     = ""
    
    init(_ dictionary: [String:Any]) {
        self.user_id         = dictionary["user_id"] as? String ?? ""
        self.access_token   = dictionary["access_token"] as? String ?? ""
        print(self.user_id, self.access_token)
        
    }
}
