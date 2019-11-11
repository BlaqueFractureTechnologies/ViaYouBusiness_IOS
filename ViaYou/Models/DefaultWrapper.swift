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
}
