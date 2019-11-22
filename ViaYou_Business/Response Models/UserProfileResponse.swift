//
//  UserProfileResponse.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 18/11/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class UserProfileResponse: NSObject {
    
    var success:Bool = false
    var message:String = ""
    var data:UserDataDictionary = UserDataDictionary([:])
    
    
    init(_ dictionary: [String: Any]) {
        self.success    = dictionary["success"] as? Bool ?? false
        self.message    = dictionary["message"] as? String ?? ""
        
        
        // print("dictionary====> \(dictionary)")
        //  print("dictionary.data ====> \(String(describing: dictionary["data"]) )")
        self.data    = UserDataDictionary(dictionary["data"] as? [String:Any] ?? [:])
        
    }
}

class UserDataDictionary: NSObject {
    
    var id: String = ""
    var name: String = ""
    var createdDateTime: String = ""

    
    init(_ dictionary: [String: Any]) {
        
        self.id = dictionary["_id"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.createdDateTime = dictionary["createdDateTime"] as? String ?? ""
    }
    
}

