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
    var id:String           = ""
    var userName:String     = ""
    
    init(_ dictionary: [String:Any]) {
        self.id         = dictionary["id"] as? String ?? ""
        self.userName   = dictionary["username"] as? String ?? ""
        print(self.id, self.userName)
        
    }
}
