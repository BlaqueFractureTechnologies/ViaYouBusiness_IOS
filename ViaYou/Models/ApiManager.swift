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
    let fetchLibraryDataHeader = "listScreenCast"
    let referralHeader = "referral"
    let bucketSizeCalculationHeader = "subscription"
    
    
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
    
    //MARK:- Library Posts Fetch API
    
    func getAllPostsAPI(from:String,
                        size:String,
                        completion: @escaping (LibraryFeedResponse, _ error:Error?) -> ()) {
        
        let parameters: [String: Any] = [
            "from":from,
            "size":size,
            
            ]
        let generatedUserToken = UserDefaults.standard.value(forKey: "GeneratedUserToken") as! String
        
        let requestURLString = "\(headerUrl)\(fetchLibraryDataHeader)"
        let request = NSMutableURLRequest(url: NSURL(string: requestURLString)! as URL)
        request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        request.setValue(generatedUserToken, forHTTPHeaderField: "token")
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
                completion(LibraryFeedResponse([:]),error)
            } else {
                do {
                    if  let jsonDict = try JSONSerialization.jsonObject(with: data!) as? [String:Any] {
                        print("jsonDict====>%@",jsonDict)
                        completion(LibraryFeedResponse(jsonDict),nil)
                    }else {
                        completion(LibraryFeedResponse([:]),nil)
                    }
                } catch let parsingError {
                    print("parsingError=\(parsingError)")
                    completion(LibraryFeedResponse([:]),parsingError)
                }
            }
        })
        dataTask.resume()
    }
    
    //MARK:- User Referral API
    //instagram post api starts
    
    func callUserReferralAPI(referredBy:String,
                             completion: @escaping (ReferralResponse, _ error:Error?) -> ()) {
        
        let parameters: [String: Any] = [
            "referredBy":referredBy
        ]
        
        let requestURLString = "\(headerUrl)\(referralHeader)"
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
                completion(ReferralResponse([:]),error)
            } else {
                do {
                    if  let jsonDict = try JSONSerialization.jsonObject(with: data!) as? [String:Any] {
                        completion(ReferralResponse(jsonDict),nil)
                        print(ReferralResponse(jsonDict))
                    }else {
                        completion(ReferralResponse([:]),nil)
                    }
                } catch let parsingError {
                    print("parsingError=\(parsingError)")
                    completion(ReferralResponse([:]),parsingError)
                }
            }
        })
        dataTask.resume()
    }
    
    //calculate bucket size api
    func getTotalBucketSize(
                        completion: @escaping (BucketSizeResponse, _ error:Error?) -> ()) {
        
        let generatedUserToken = UserDefaults.standard.value(forKey: "GeneratedUserToken") as! String
        
        let requestURLString = "\(headerUrl)\(bucketSizeCalculationHeader)"
        let request = NSMutableURLRequest(url: NSURL(string: requestURLString)! as URL)
        request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        request.setValue(generatedUserToken, forHTTPHeaderField: "token")
        request.httpMethod = "POST"
        
        let postData = NSMutableData()
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error ?? "")
                completion(BucketSizeResponse([:]),error)
            } else {
                do {
                    if  let jsonDict = try JSONSerialization.jsonObject(with: data!) as? [String:Any] {
                        print("jsonDict====>%@",jsonDict)
                        completion(BucketSizeResponse(jsonDict),nil)
                    }else {
                        completion(BucketSizeResponse([:]),nil)
                    }
                } catch let parsingError {
                    print("parsingError=\(parsingError)")
                    completion(BucketSizeResponse([:]),parsingError)
                }
            }
        })
        dataTask.resume()
    }

}

