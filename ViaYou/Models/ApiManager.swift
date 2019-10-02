//
//  ApiManager.swift
//  Promptchu
//
//  Created by Promptchu Pty Ltd on 24/7/19.
//  Copyright © 2019 AryaSreenivasan. All rights reserved.
//

import UIKit

struct ApiManager {
    
    let headerUrl       = "https://promptchu-api.herokuapp.com/user/"
    let POSTSHEADER     = "https://promptchu-api.herokuapp.com/post/"
    let COMPANY_HEADER  = "https://promptchu-api.herokuapp.com/company/"
    let COMMENT_HEADER  = "https://promptchu-api.herokuapp.com/comment/"
    
    let instagramHeader = "https://api.instagram.com/v1/users/self/?access_token="
    let instagramAuthenticationToken = UserDefaults.standard.value(forKey: "InstagramAccessToken")
    let REGISTRATION    = "register"
    let instagramUserIdInputApiHeader = "instaAccess"
    let profileHeader = "profile"
    let shadowHeader = "shadow"
    let unshadowHeader = "unshadow"
    //    let generatedUserToken = UserDefaults.standard.value(forKey: "GeneratedUserToken") as! String
    let mainHeader = "https://promptchu-api.herokuapp.com"
    let listAllPostsHeader = "/post/listForYou"
    let listShadowingPostHeader = "/post/listShadowing"
    let listDiscoverPostHeader = "/post/listDiscover"
    let rateHeader = "/post/rate"
    let viewedPostHeader = "/post/viewed"
    let updateProfileHeader = "/user/updateProfile"
    let addVideoPostHeader = "/post/add"
    let searchCompanyHeader = "/company/search"
    let searchHeader = "search"
    let locationSearchHeader = "searchByLocation"
    let getUserPromptsHeader = "listById"
    let getUserShadowsListHeader = "shadows"
    let getUserShadowingListHeader = "shadowing"
    let notificationsHeader = "notifications"
    
    let companySearchHeader = "search"
    let addNewCompanyHeader = "add"
    let addCommentHeader = "/comment/add"
    let findFriendsHeader = "findFriends"
    let tagsHeader = "myTags"
    let tagNotifiedHeader = "tagNotified"
    let listCommentsHeader = "list"
    let deleteHeader = "delete"
    
    
    //MARK:- Registration API
    //editing starts
    func callRegistrationAPI(email:String,
                             password:String,
                             gender:String,
                             completion: @escaping (RegisterResponse, _ error:Error?) -> ()) {
        
        let parameters: [String: Any] = [
            "email":email,
            "password":password,
            "gender":gender
        ]
        
        let requestURLString = "\(headerUrl)\(REGISTRATION)"
        let request = NSMutableURLRequest(url: NSURL(string: requestURLString)! as URL)
        request.httpMethod = "POST"
        
        let postData = NSMutableData()
        for key in parameters.keys {
            let keyString = "&\(key)"
            let valueString = parameters[key] as? String ?? ""
            postData.append("\(keyString)=\(valueString)".data(using: String.Encoding.utf8)!)
        }
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error ?? "")
                completion(RegisterResponse([:]),error)
            } else {
                do {
                    if  let jsonDict = try JSONSerialization.jsonObject(with: data!) as? [String:Any] {
                        completion(RegisterResponse(jsonDict),nil)
                    }else {
                        completion(RegisterResponse([:]),nil)
                    }
                } catch let parsingError {
                    print("parsingError=\(parsingError)")
                    completion(RegisterResponse([:]),parsingError)
                }
            }
        })
        dataTask.resume()
    }
    //editing ends
    //MARK:- Instagram Authentication API
    //instagram api starts
    func getInstagramAuthResponseFromAPI(completion: @escaping (InstagramAuthResponseModel, _ error:Error?) -> ()) {
        
        if let instagramToken = instagramAuthenticationToken {
            let validInstagramToken = instagramToken
            // print(validInstagramToken)
            
            let requestURLString = "\(instagramHeader)\(validInstagramToken)"
            let request = NSMutableURLRequest(url: NSURL(string: requestURLString)! as URL)
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    print(error ?? "")
                    completion(InstagramAuthResponseModel([:]),error)
                } else {
                    do {
                        if  let jsonDict = try JSONSerialization.jsonObject(with: data!) as? [String:Any] {
                            let listResponse = InstagramAuthResponseModel(jsonDict)
                            print(listResponse)
                            completion(listResponse,nil)
                        }else {
                            completion(InstagramAuthResponseModel([:]),nil)
                        }
                    } catch let parsingError {
                        print("parsingError=\(parsingError)")
                        completion(InstagramAuthResponseModel([:]),parsingError)
                    }
                }
            })
            dataTask.resume()
        }
    }
    
    //instagram api ends
    
    //instagram post api starts
    
    func postInstagramUserIdAPI(userId:String,
                                name:String,
                                completion: @escaping (InstagramUserDetailsResponse, _ error:Error?) -> ()) {
        
        let parameters: [String: Any] = [
            "userId":userId,
            "name":name
        ]
        
        let requestURLString = "\(headerUrl)\(instagramUserIdInputApiHeader)"
        let request = NSMutableURLRequest(url: NSURL(string: requestURLString)! as URL)
        request.httpMethod = "POST"
        let postData = NSMutableData()
        for key in parameters.keys {
            let keyString = "&\(key)"
            let valueString = parameters[key] as? String ?? ""
            postData.append("\(keyString)=\(valueString)".data(using: String.Encoding.utf8)!)
        }
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error ?? "")
                completion(InstagramUserDetailsResponse([:]),error)
            } else {
                do {
                    if  let jsonDict = try JSONSerialization.jsonObject(with: data!) as? [String:Any] {
                        completion(InstagramUserDetailsResponse(jsonDict),nil)
                        print(InstagramUserDetailsResponse(jsonDict))
                    }else {
                        completion(InstagramUserDetailsResponse([:]),nil)
                    }
                } catch let parsingError {
                    print("parsingError=\(parsingError)")
                    completion(InstagramUserDetailsResponse([:]),parsingError)
                }
            }
        })
        dataTask.resume()
    }
    
    //instagram post api ends
    
    
}

