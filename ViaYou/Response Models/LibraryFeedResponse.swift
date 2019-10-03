//
//  LibraryFeedResponse.swift
//  ViaYou
//
//  Created by Promptchu Pty Ltd on 3/10/19.
//  Copyright © 2019 Promptchu Pty Ltd. All rights reserved.
//

import UIKit

class LibraryFeedResponse: NSObject {
    
    var success: Bool = false
    var message: String = ""
    var data:[FeedDataArrayObject] = []
}

class FeedDataArrayObject: NSObject {
    
}
