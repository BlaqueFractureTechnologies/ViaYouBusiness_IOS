//
//  ApiManager.swift
//  Promptchu
//
//  Created by Promptchu Pty Ltd on 24/7/19.
//  Copyright © 2019 AryaSreenivasan. All rights reserved.
//

import UIKit

struct ApiManager {
    
    let headerUrl       = "http://api.viayou.net/user/"
    let POSTSHEADER     = "http://api.viayou.net/post/"
    let COMPANY_HEADER  = "http://api.viayou.net/company/"
    let COMMENT_HEADER  = "http://api.viayou.net/comment/"
    let mainHeader = "http://api.viayou.net/"
    
    let instagramMainHeader = "https://api.instagram.com/oauth/access_token"
    
  //  let instagramHeader = "https://api.instagram.com/v1/users/self/?access_token="
    let instagramHeader = "https://graph.instagram.com/me?fields=id,username&access_token="
    let instagramAuthenticationToken = UserDefaults.standard.value(forKey: "InstagramAccessToken")
    let instagramAuthenticationCode = UserDefaults.standard.value(forKey: "InstagramAuthenticationCode")
    
    let REGISTRATION    = "register"
    let instagramUserIdInputApiHeader = "instaAccess"
    let fetchLibraryDataHeader = "listScreenCast"
    let referralHeader = "referral"
    let bucketSizeCalculationHeader = "subscription"
    let createChargesHeader = "subscription/createCharges"
    let deleteHeader = "delete"
    let featureRequest = "feedback/add"
    let fetchSubscriptionHeader = "subscription/fetch"
    let listDeletedScreenCastHeader = "listDeletedScreenCast"
    let restoreScreencastHeader = "restore"
    let firebaseRegisterHeader = "firebaseRegister"
    let addVideoPostHeader = "add"
    let profileHeader = "profile"

    
    
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
    
    func getInstagramTokenAPI(app_id:String,
                             app_secret:String,
                             grant_type:String,
                             redirect_uri:String,
                             code:String,
                             completion: @escaping (InstagramAccessResponse, _ error:Error?) -> ()) {
            let parameters: [String: Any] = [
                "app_id":app_id,
                "app_secret":app_secret,
                "grant_type":grant_type,
                "redirect_uri":redirect_uri,
                "code":code
            ]
            
            let requestURLString = "\(instagramMainHeader)"
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
                    completion(InstagramAccessResponse([:]),error)
                } else {
                    do {
                        if  let jsonDict = try JSONSerialization.jsonObject(with: data!) as? [String:Any] {
                            completion(InstagramAccessResponse(jsonDict),nil)
                        }else {
                            completion(InstagramAccessResponse([:]),nil)
                        }
                    } catch let parsingError {
                        print("parsingError=\(parsingError)")
                        completion(InstagramAccessResponse([:]),parsingError)
                    }
                }
            })
            dataTask.resume()
        

    }
    //instagram api starts
    func getInstagramAuthResponseFromAPI(completion: @escaping (InstagramAuthResponseModel, _ error:Error?) -> ()) {
        
        if let instagramToken = instagramAuthenticationToken {
            let validInstagramToken = instagramToken
             print(validInstagramToken)
            
            let requestURLString = "\(instagramHeader)\(validInstagramToken)"
            print(requestURLString)
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
       // let requestURLString = "\(headerUrlForGettingAllPosts)\(fetchLibraryDataHeader)"
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
    
    
    //Payment Confirmation API
    func confirmPaymentAPI(stripeToken:String,
                           type:String,
                           completion: @escaping (SubscriptionResponse, _ error:Error?) -> ()) {
        
        let parameters: [String: Any] = [
            "stripeToken":stripeToken,
            "type":type,
        ]
        let generatedUserToken = UserDefaults.standard.value(forKey: "GeneratedUserToken") as! String
        
        let requestURLString = "\(mainHeader)\(createChargesHeader)"
        let request = NSMutableURLRequest(url: NSURL(string: requestURLString)! as URL)
        // request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
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
                completion(SubscriptionResponse([:]),error)
            } else {
                do {
                    if  let jsonDict = try JSONSerialization.jsonObject(with: data!) as? [String:Any] {
                        print("jsonDict====>%@",jsonDict)
                        completion(SubscriptionResponse(jsonDict),nil)
                    }else {
                        completion(SubscriptionResponse([:]),nil)
                    }
                } catch let parsingError {
                    print("parsingError=\(parsingError)")
                    completion(SubscriptionResponse([:]),parsingError)
                }
            }
        })
        dataTask.resume()
    }
    
    
    let instaUserDetailsUrl:String = "https://api.instagram.com/v1/users/self/?access_token="
    
    func getInstaUserDetails(access_token:String,
                             completion: @escaping (InstagramUserResponse, _ error:Error?) -> ()) {
        
        
        let requestURLString = "\(instaUserDetailsUrl)\(access_token)"
        print(requestURLString)
        let request = NSMutableURLRequest(url: NSURL(string: requestURLString)! as URL)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error ?? "")
                completion(InstagramUserResponse([:]),error)
            } else {
                do {
                    if  let jsonDict = try JSONSerialization.jsonObject(with: data!) as? [String:Any] {
                        print("getInstaUserDetails :: jsonDict====>%@",jsonDict)
                        completion(InstagramUserResponse(jsonDict),nil)
                    }else {
                        completion(InstagramUserResponse([:]),nil)
                    }
                } catch let parsingError {
                    print("parsingError=\(parsingError)")
                    completion(InstagramUserResponse([:]),parsingError)
                }
            }
        })
        dataTask.resume()
    }
    
    //MARK:- Delete Post API
    func deletePostAPI(postId:String,
                       completion: @escaping (DeleteVideoResponse, _ error:Error?) -> ()) {
        
        let parameters: [String: Any] = [
            "postId":postId,
        ]
        let generatedUserToken = UserDefaults.standard.value(forKey: "GeneratedUserToken") as! String
        
        let requestURLString = "\(POSTSHEADER)\(deleteHeader)"
        let request = NSMutableURLRequest(url: NSURL(string: requestURLString)! as URL)
        // request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
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
                completion(DeleteVideoResponse([:]),error)
            } else {
                do {
                    if  let jsonDict = try JSONSerialization.jsonObject(with: data!) as? [String:Any] {
                        print("jsonDict====>%@",jsonDict)
                        completion(DeleteVideoResponse(jsonDict),nil)
                    }else {
                        completion(DeleteVideoResponse([:]),nil)
                    }
                } catch let parsingError {
                    print("parsingError=\(parsingError)")
                    completion(DeleteVideoResponse([:]),parsingError)
                }
            }
        })
        dataTask.resume()
    }
    
    func addFeatureAPI(description:String,
                       completion: @escaping (DeleteVideoResponse, _ error:Error?) -> ()) {
        
        let parameters: [String: Any] = [
            "description":description,
        ]
        let generatedUserToken = UserDefaults.standard.value(forKey: "GeneratedUserToken") as! String
        
        let requestURLString = "\(mainHeader)\(featureRequest)"
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
                completion(DeleteVideoResponse([:]),error)
            } else {
                do {
                    if  let jsonDict = try JSONSerialization.jsonObject(with: data!) as? [String:Any] {
                        print("jsonDict====>%@",jsonDict)
                        completion(DeleteVideoResponse(jsonDict),nil)
                    }else {
                        completion(DeleteVideoResponse([:]),nil)
                    }
                } catch let parsingError {
                    print("parsingError=\(parsingError)")
                    completion(DeleteVideoResponse([:]),parsingError)
                }
            }
        })
        dataTask.resume()
    }
    
    //MARK:- Fetch Subscription Details
    func getSubscriptionDetailsAPI(
        completion: @escaping (FetchSubscriptionResponse, _ error:Error?) -> ()) {
        
        let generatedUserToken = UserDefaults.standard.value(forKey: "GeneratedUserToken") as! String
        
        let requestURLString = "\(mainHeader)\(fetchSubscriptionHeader)"
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
                completion(FetchSubscriptionResponse([:]),error)
            } else {
                do {
                    if  let jsonDict = try JSONSerialization.jsonObject(with: data!) as? [String:Any] {
                        print("jsonDict====>%@",jsonDict)
                        completion(FetchSubscriptionResponse(jsonDict),nil)
                    }else {
                        completion(FetchSubscriptionResponse([:]),nil)
                    }
                } catch let parsingError {
                    print("parsingError=\(parsingError)")
                    completion(FetchSubscriptionResponse([:]),parsingError)
                }
            }
        })
        dataTask.resume()
    }
    
    //MARK:- List Deleted Screencast
    func ListDeletedScreencastAPI(
        completion: @escaping (LibraryFeedResponse, _ error:Error?) -> ()) {
        
        let generatedUserToken = UserDefaults.standard.value(forKey: "GeneratedUserToken") as! String
        
        let requestURLString = "\(headerUrl)\(listDeletedScreenCastHeader)"
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
    
    //MARK:- Restore Deleted Videos APIs
    func restoreVideosAPI(postId:String,
                          completion: @escaping (DeleteVideoResponse, _ error:Error?) -> ()) {
        
        let parameters: [String: Any] = [
            "postId":postId,
        ]
        let generatedUserToken = UserDefaults.standard.value(forKey: "GeneratedUserToken") as! String
        
        let requestURLString = "\(POSTSHEADER)\(restoreScreencastHeader)"
        let request = NSMutableURLRequest(url: NSURL(string: requestURLString)! as URL)
       // request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
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
                completion(DeleteVideoResponse([:]),error)
            } else {
                do {
                    if  let jsonDict = try JSONSerialization.jsonObject(with: data!) as? [String:Any] {
                        print("jsonDict====>%@",jsonDict)
                        completion(DeleteVideoResponse(jsonDict),nil)
                    }else {
                        completion(DeleteVideoResponse([:]),nil)
                    }
                } catch let parsingError {
                    print("parsingError=\(parsingError)")
                    completion(DeleteVideoResponse([:]),parsingError)
                }
            }
        })
        dataTask.resume()
    }
    
    //MARK:- Firebase Registration API
    func mongoDBRegisterAPI(name:String,
                        email:String,
                        userId:String,
                        completion: @escaping (SubscriptionResponse, _ error:Error?) -> ()) {
        
        let parameters: [String: Any] = [
            "name":name,
            "email":email,
            "userId":userId,
            ]
        let generatedUserToken = UserDefaults.standard.value(forKey: "GeneratedUserToken") as! String
        
        let requestURLString = "\(headerUrl)\(firebaseRegisterHeader)"
        let request = NSMutableURLRequest(url: NSURL(string: requestURLString)! as URL)
       // request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
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
                completion(SubscriptionResponse([:]),error)
            } else {
                do {
                    if  let jsonDict = try JSONSerialization.jsonObject(with: data!) as? [String:Any] {
                        print("jsonDict====>%@",jsonDict)
                        completion(SubscriptionResponse(jsonDict),nil)
                    }else {
                        completion(SubscriptionResponse([:]),nil)
                    }
                } catch let parsingError {
                    print("parsingError=\(parsingError)")
                    completion(SubscriptionResponse([:]),parsingError)
                }
            }
        })
        dataTask.resume()
    }
    //MARK:- Add Video Post to Firebase
    
    
//    func addVideoPostToFirebase(userID:String,
//                                title:String,
//                                description:String,
//                                fileName:String,
//                                completion: @escaping (_ responseDict:SubscriptionResponse, _ error:Error?) -> ()) {
//        let parameters: [String: Any] = [
//            "userID":userID,
//            "title":title,
//            "description":description,
//            "fileName":fileName,
//        ]
//        let generatedUserToken = UserDefaults.standard.value(forKey: "GeneratedUserToken") as! String
//
//        let requestURLString = "\(POSTSHEADER)\(addVideoPostHeader)"
//        let request = NSMutableURLRequest(url: NSURL(string: requestURLString)! as URL)
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue(generatedUserToken, forHTTPHeaderField: "token")
//        request.httpMethod = "POST"
//
//        let postData = NSMutableData()
//        for key in parameters.keys {
//            let keyString = "&\(key)"
//            let valueString = parameters[key] as? String ?? ""
//            postData.append("\(keyString)=\(valueString)".data(using: String.Encoding.utf8)!)
//        }
//        request.httpBody = postData as Data
//
//        let session = URLSession.shared
//        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
//            if (error != nil) {
//                print(error ?? "")
//                completion(SubscriptionResponse([:]),error)
//            } else {
//                do {
//                    if  let jsonDict = try JSONSerialization.jsonObject(with: data!) as? [String:Any] {
//                        print("jsonDict====>%@",jsonDict)
//                        completion(SubscriptionResponse(jsonDict),nil)
//                    }else {
//                        completion(SubscriptionResponse([:]),nil)
//                    }
//                } catch let parsingError {
//                    print("parsingError=\(parsingError)")
//                    completion(SubscriptionResponse([:]),parsingError)
//                }
//            }
//        })
//        dataTask.resume()
//    }
    
    func addVideoPostToFirebase(dataDict:[String : Any] , completion: @escaping (_ responseDict:SubscriptionResponse, _ error:Error?) -> ()) {
        let generatedUserToken = UserDefaults.standard.value(forKey: "GeneratedUserToken") as! String
        
        let requestURLString = "\(POSTSHEADER)\(addVideoPostHeader)"
        let request = NSMutableURLRequest(url: NSURL(string: requestURLString)! as URL)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(generatedUserToken, forHTTPHeaderField: "token")
        request.httpMethod = "POST"
        
        let parameters = dataDict
        do {
            if  let postDataDict = try JSONSerialization.data(withJSONObject: parameters, options: []) as? Data {
                request.httpBody = postDataDict as Data
            }
        } catch let JSONSerializationError {
            print("JSONSerializationError=\(JSONSerializationError)")
        }
        
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error ?? "")
                completion(SubscriptionResponse([:]),error)
            } else {
                do {
                    if  let jsonDict = try JSONSerialization.jsonObject(with: data!) as? [String:Any] {
                        print("jsonDict====>%@",jsonDict)
                        completion(SubscriptionResponse(jsonDict),nil)
                    }else {
                        completion(SubscriptionResponse([:]),nil)
                    }
                } catch let parsingError {
                    print("parsingError=\(parsingError)")
                    completion(SubscriptionResponse([:]),parsingError)
                }
            }
        })
        dataTask.resume()
    }
    
    //MARK:- get profile details api
    
    func getProfileDetails(userId:String,
                           completion: @escaping (UserProfileResponse, _ error:Error?) -> ()) {
        
        let parameters: [String: Any] = [
            "profileUserId":userId,
        ]
        let generatedUserToken = UserDefaults.standard.value(forKey: "GeneratedUserToken") as! String
        
        let requestURLString = "\(headerUrl)\(profileHeader)"
        let request = NSMutableURLRequest(url: NSURL(string: requestURLString)! as URL)
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
                completion(UserProfileResponse([:]),error)
            } else {
                do {
                    if  let jsonDict = try JSONSerialization.jsonObject(with: data!) as? [String:Any] {
                        print("getProfileDetails :: jsonDict====>\(jsonDict)")
                        completion(UserProfileResponse(jsonDict),nil)
                        print(UserProfileResponse(jsonDict))
                    }else {
                        completion(UserProfileResponse([:]),nil)
                    }
                } catch let parsingError {
                    print("parsingError=\(parsingError)")
                    completion(UserProfileResponse([:]),parsingError)
                }
            }
        })
        dataTask.resume()
    }
    //get profile details api ends
    
}

