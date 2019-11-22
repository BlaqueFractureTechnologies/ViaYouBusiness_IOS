//
//  DefaultWrapper.swift
//  ViaYou
//
//  Created by Arya S on 21/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class DefaultWrapper: NSObject {
    func setPaymentTypePurchased(type:Int) {
        //0=> Solo
        //1=> Growth
        //2=> Pro
        UserDefaults.standard.set(type, forKey: "PaymentTypePurchased")
    }
    
    func getPaymentTypePurchased() ->Int {
        //0=> Solo
        //1=> Growth
        //2=> Pro
        let paymentTypePurchased = UserDefaults.standard.value(forKey: "PaymentTypePurchased") as? Int ?? -1
        return paymentTypePurchased
    }
    
    func setFirstTimeUserStatusAfterSignUp(status:Bool,userEmail:String) {
        UserDefaults.standard.set(status, forKey: "isFirstTimeUser_\(userEmail)")
    }
    
    func getFirstTimeUserStatus(userEmail:String) ->Bool {
        let status = UserDefaults.standard.value(forKey: "isFirstTimeUser_\(userEmail)") as? Bool ?? false
        return status
    }
    func setMaxDaysDifferenceForUser(maxDays:String,userId:String) {
        UserDefaults.standard.set(maxDays, forKey: "MAXDAYS_\(userId)")
    }
    
    func getMaxDaysDifferenceForUser(userId:String) ->String {
        let maxDays = UserDefaults.standard.value(forKey: "MAXDAYS_\(userId)") as? String ?? ""
        return maxDays
    }
    
    func setIsUserNotifiedOnThisDate(status:Bool, dateString:String, userId:String) {
        UserDefaults.standard.set(status, forKey: "IS_NOTIFIED_\(userId)_FOR_DATE_\(dateString)")
    }
    
    func getIsUserNotifiedOnThisDate(dateString:String, userId:String) ->Bool {
        let status = UserDefaults.standard.value(forKey: "IS_NOTIFIED_\(userId)_FOR_DATE_\(dateString)") as? Bool ?? false
        return status
    }
}
