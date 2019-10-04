//
//  LibraryFeedResponse.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 3/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

struct LibraryFeedResponse {
    var success:Bool = false
    var message:String = ""
    var data:[FeedDataArrayObject] = []
    
    init(_ dictionary: [String: Any]) {
        self.success    = dictionary["success"] as? Bool ?? false
        self.message    = dictionary["message"] as? String ?? ""
        
        data = []
        let dataArray = dictionary["data"] as? [[String:Any]] ?? []
        for i in 0..<dataArray.count {
            let objectAtIndex = FeedDataArrayObject(dataArray[i])
            data.append(objectAtIndex)
        }
    }
}

class FeedDataArrayObject: NSObject {
    var location:FeedDataLocation = FeedDataLocation([:])
    var title:String = ""
    var tags:[FeedTag] = []
    var notifiedTags:[FeedNotifiedTag] = []
    var commentsCount:String = ""   //Int from API
    var viewCount:String = ""   //Int from API
    var rateCount:String = ""   //Int from API
    var isRatedByUser:Bool = false
    var isBlocked:Bool = false
    var isDeleted:Bool = false
    var isScreenCast:Bool = false
    var _id:String = ""
    var user:FeedUser = FeedUser([:])
    var fileName:String = ""
    var createdDateTime:String = ""
    var updatedDateTime:String = ""
    var ratedBy:[FeedUserRatedByArrayObject] = []
    var viewedBy:[FeedUserViewdByArrayObject] = []
    
    var isInfoPopUpDisplaying:Bool = false
    
    init(_ dictionary: [String: Any]) {
        self.location   =  FeedDataLocation(dictionary["location"] as? [String:Any] ?? [:])
        self.title    = dictionary["title"] as? String ?? ""
        
        tags = []
        let tagsDataArray = dictionary["tags"] as? [[String:Any]] ?? []
        for i in 0..<tagsDataArray.count {
            let objectAtIndex = FeedTag(tagsDataArray[i])
            tags.append(objectAtIndex)
        }
        
        notifiedTags = []
        let notifiedTagsDataArray = dictionary["notifiedTags"] as? [[String:Any]] ?? []
        for i in 0..<notifiedTagsDataArray.count {
            let objectAtIndex = FeedNotifiedTag(notifiedTagsDataArray[i])
            notifiedTags.append(objectAtIndex)
        }
        
        
        if let commentsCountValue = dictionary["commentsCount"] as? Int {
            self.commentsCount = "\(commentsCountValue)"
        }else if let commentsCountValue = dictionary["commentsCount"] as? String {
            self.commentsCount = "\(commentsCountValue)"
        }
        
        if let viewCountValue = dictionary["viewCount"] as? Int {
            self.viewCount = "\(viewCountValue)"
        }else if let viewCountValue = dictionary["viewCount"] as? String {
            self.viewCount = "\(viewCountValue)"
        }
        
        if let rateCountValue = dictionary["rateCount"] as? Int {
            self.rateCount = "\(rateCountValue)"
        }else if let rateCountValue = dictionary["rateCount"] as? String {
            self.rateCount = "\(rateCountValue)"
        }
        
        self.isRatedByUser  = dictionary["isRatedByUser"] as? Bool ?? false
        self.isBlocked      = dictionary["isBlocked"] as? Bool ?? false
        self.isDeleted      = dictionary["isDeleted"] as? Bool ?? false
        self.isScreenCast   = dictionary["isScreenCast"] as? Bool ?? false
        
        self._id = dictionary["_id"] as? String ?? ""
        
        self.user =  FeedUser(dictionary["user"] as? [String:Any] ?? [:])
        
        self.isInfoPopUpDisplaying   = dictionary["isInfoPopUpDisplaying"] as? Bool ?? false
        
        self.fileName           = dictionary["fileName"] as? String ?? ""
        
        self.createdDateTime    = dictionary["createdDateTime"] as? String ?? ""
        self.updatedDateTime    = dictionary["updatedDateTime"] as? String ?? ""
        
        ratedBy = []
        let ratedByDataArray = dictionary["ratedBy"] as? [[String:Any]] ?? []
        for i in 0..<ratedByDataArray.count {
            let objectAtIndex = FeedUserRatedByArrayObject(ratedByDataArray[i])
            ratedBy.append(objectAtIndex)
        }
        
        viewedBy = []
        let viewedByDataArray = dictionary["viewedBy"] as? [[String:Any]] ?? []
        for i in 0..<viewedByDataArray.count {
            let objectAtIndex = FeedUserViewdByArrayObject(viewedByDataArray[i])
            viewedBy.append(objectAtIndex)
        }
        
    }
}

class FeedDataLocation: NSObject {
    var type:String = ""
    
    init(_ dictionary: [String: Any]) {
        self.type    = dictionary["type"] as? String ?? ""
    }
}

//--------- ADD PROPER DATA ON RESPONSE AND FILL THE MODEL ACCORDINGLY
class FeedTag: NSObject {
    
    init(_ dictionary: [String: Any]) {
        
    }
}

//--------- ADD PROPER DATA ON RESPONSE AND FILL THE MODEL ACCORDINGLY
class FeedNotifiedTag: NSObject {
    
    init(_ dictionary: [String: Any]) {
        
    }
}


class FeedUser: NSObject {
    var promptsCount:String = ""   //Int from API
    var shadowing:Bool = false
    var shadowCount:String = ""   //Int from API
    var shadowingCount:String = ""   //Int from API
    var storage:String = ""   //Int from API
    var storageExpireDate:String = ""
    var _id:String = ""
    var email:String = ""
    var name:String = ""
    var __v:String = ""   //Int from API
    var shadows:[FeedUserShadows] = []
    var bio:String = ""
    var city:String = ""
    var country:String = ""
    var dob:String = ""
    var gender:String = ""
    var phone:String = ""   //Int from API
    var state:String = ""
    var displayName:String = ""
    var updatedDateTime:String = ""
    var notifiedDateTime:String = ""
    var referrals:[FeedUserReferrals] = []
    
    var videoImage:UIImage = UIImage(named: "defaultFeedCellBg")!
    
    init(_ dictionary: [String: Any]) {
        if let promptsCountValue = dictionary["promptsCount"] as? Int {
            self.promptsCount = "\(promptsCountValue)"
        }else if let promptsCountValue = dictionary["promptsCount"] as? String {
            self.promptsCount = "\(promptsCountValue)"
        }
        
        self.shadowing  = dictionary["shadowing"] as? Bool ?? false
        
        if let shadowCountValue = dictionary["shadowCount"] as? Int {
            self.shadowCount = "\(shadowCountValue)"
        }else if let shadowCountValue = dictionary["shadowCount"] as? String {
            self.shadowCount = "\(shadowCountValue)"
        }
        
        if let shadowingCountValue = dictionary["shadowingCount"] as? Int {
            self.shadowingCount = "\(shadowingCountValue)"
        }else if let shadowingCountValue = dictionary["shadowingCount"] as? String {
            self.shadowingCount = "\(shadowingCountValue)"
        }
        
        if let storageValue = dictionary["storage"] as? Int {
            self.storage = "\(storageValue)"
        }else if let storageValue = dictionary["storage"] as? String {
            self.storage = "\(storageValue)"
        }
        
        self.storageExpireDate  = dictionary["storageExpireDate"] as? String ?? ""
        self._id                = dictionary["_id"] as? String ?? ""
        self.email              = dictionary["email"] as? String ?? ""
        self.name               = dictionary["name"] as? String ?? ""
        
        shadows = []
        let shadowsDataArray = dictionary["shadows"] as? [[String:Any]] ?? []
        for i in 0..<shadowsDataArray.count {
            let objectAtIndex = FeedUserShadows(shadowsDataArray[i])
            shadows.append(objectAtIndex)
        }
        
        self.bio        = dictionary["bio"] as? String ?? ""
        self.city       = dictionary["city"] as? String ?? ""
        self.country    = dictionary["country"] as? String ?? ""
        self.dob        = dictionary["dob"] as? String ?? ""
        self.gender     = dictionary["gender"] as? String ?? ""
        
        if let phoneValue = dictionary["phone"] as? Int {
            self.phone = "\(phoneValue)"
        }else if let phoneValue = dictionary["phone"] as? String {
            self.phone = "\(phoneValue)"
        }
        
        self.state              = dictionary["state"] as? String ?? ""
        self.displayName        = dictionary["displayName"] as? String ?? ""
        self.updatedDateTime    = dictionary["updatedDateTime"] as? String ?? ""
        self.notifiedDateTime   = dictionary["notifiedDateTime"] as? String ?? ""
        
        referrals = []
        let referralsDataArray = dictionary["referrals"] as? [[String:Any]] ?? []
        for i in 0..<referralsDataArray.count {
            let objectAtIndex = FeedUserReferrals(referralsDataArray[i])
            referrals.append(objectAtIndex)
        }
        
        if let __vValue = dictionary["__v"] as? Int {
            self.__v = "\(__vValue)"
        }else if let __vValue = dictionary["__v"] as? String {
            self.__v = "\(__vValue)"
        }
        
        self.videoImage = dictionary["videoImage"] as? UIImage ?? UIImage(named: "defaultFeedCellBg")!
        
    }
    
}

class FeedUserShadows: NSObject {
    var shadowedDateTime:String = ""
    var _id:String = ""
    var user:String = ""
    
    init(_ dictionary: [String: Any]) {
        self.shadowedDateTime = dictionary["shadowedDateTime"] as? String ?? ""
        self._id              = dictionary["_id"] as? String ?? ""
        self.user             = dictionary["user"] as? String ?? ""
    }
}

class FeedUserReferrals: NSObject {
    var referredDateTime:String = ""
    var _id:String = ""
    var user:String = ""
    
    init(_ dictionary: [String: Any]) {
        self.referredDateTime = dictionary["referredDateTime"] as? String ?? ""
        self._id              = dictionary["_id"] as? String ?? ""
        self.user             = dictionary["user"] as? String ?? ""
    }
}

//--------- ADD PROPER DATA ON RESPONSE AND FILL THE MODEL ACCORDINGLY
class FeedUserRatedByArrayObject: NSObject {
    
    init(_ dictionary: [String: Any]) {
        
    }
}

//--------- ADD PROPER DATA ON RESPONSE AND FILL THE MODEL ACCORDINGLY
class FeedUserViewdByArrayObject: NSObject {
    
    init(_ dictionary: [String: Any]) {
        
    }
}

