//
//  PhoneContact.swift
//  ViaYou
//
//  Created by Arya S on 04/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class PhoneContact: NSObject {
    var firstName: String = ""
    var familyName: String = ""
    var fullName: String = ""
    var profilePic: UIImage!
    var isProfilePicAvailable: Bool = false
    var phoneNumbers: [String] = []
}
