//
//  Model.swift
//  TestDrive-swift
//
//  Created by Michael Katz on 6/4/14.
//  Copyright (c) 2014 Kinvey. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//


import Foundation

protocol ModelDelegate {
    func modelUpdated(model:Model) -> Void
}

class Model: NSObject {

    let apiKey = "kid_TTRtv78pQi"
    let apiSecret = "1a59307010e944c8ad888bf924ebfd2d"
    
    var data : NSDictionary[] = []
    let session : NSURLSession
    var user:NSString?
    
    var delegate : ModelDelegate?
    
    
    init()  {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration:config)
    }
    
    func load() {
        if !user {
            createUser(load)
        } else {
        var request = NSMutableURLRequest()
        let urlStr = "https://baas.kinvey.com/appdata/\(apiKey)/objects"
        request.URL = NSURL(string: urlStr)
        request.HTTPMethod = "GET"

        request.setValue(user, forHTTPHeaderField: "Authorization")
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error {
                println(error)
            } else {
                if let responseBody : AnyObject = NSJSONSerialization.JSONObjectWithData(data, options:nil, error: nil)  {
                    println(responseBody)
                    if !error {
                        self.data = responseBody as NSDictionary[]
                        self.delegate?.modelUpdated(self)
                    }
                }
            }
        }
        task.resume()
        }
    }
    
    func createUser(completion:()->()) {
        var request = NSMutableURLRequest()
        let urlStr = "https://baas.kinvey.com/user/\(apiKey)"
        request.URL = NSURL(string: urlStr)
        request.HTTPMethod = "POST"

        let body : Dictionary = Dictionary<String,String>()
        var e : NSError?
        let opt : NSJSONWritingOptions = nil
        let bodyData = NSJSONSerialization.dataWithJSONObject(body, options:opt, error:&e)
        request.HTTPBody = bodyData;
        
        let cred = "\(apiKey):\(apiSecret)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let credData = cred.base64Encoding()
        let authValue = "Basic \(credData)"
        request.setValue(authValue, forHTTPHeaderField: "Authorization")

        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error {
                println(error)
            } else {
                if let responseDict = NSJSONSerialization.JSONObjectWithData(data, options:nil, error: nil) as? NSDictionary {
                    if let authtoken = responseDict["_kmd"]?["authtoken"] as? String {
                        println(authtoken)
                        self.user = "Kinvey \(authtoken)"
                    } else if let authtoken = responseDict["error"]?["XXXXX"] as? String {
                        // error
                    } else {
                        // Handle malformed server response
                    }
                }
                completion()                
            }
        }
        task.resume()
    }
    
    func addObject(title: String, completion:(error : NSError?)->()) {
        var request = NSMutableURLRequest()
        let urlStr = "https://baas.kinvey.com/appdata/\(apiKey)/objects"
        request.URL = NSURL(string: urlStr)
        request.HTTPMethod = "POST"
        
        let body : Dictionary = ["title":title]
        var e : NSError?
        let opt : NSJSONWritingOptions = nil
        let bodyData = NSJSONSerialization.dataWithJSONObject(body, options:opt, error:&e)
        request.HTTPBody = bodyData
        
        request.addValue(self.user, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error {
                println(error)
                completion(error: error)
            } else {
                if let newObj = NSJSONSerialization.JSONObjectWithData(data, options:nil, error: nil) as? NSDictionary {
                    self.data.append(newObj)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    completion(error: nil)
                }
            }
        }
        task.resume()
    }
    
    func deleteObject(object: NSDictionary, index:Int, completion:(error : NSError?)->()) {
        var request = NSMutableURLRequest()
        let _id = object["_id"] as String;
        let urlStr = "https://baas.kinvey.com/appdata/\(apiKey)/objects/\(_id)"
        println(urlStr)
        request.URL = NSURL(string: urlStr)
        request.HTTPMethod = "DELETE"
        
        request.addValue(self.user, forHTTPHeaderField: "Authorization")
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if let respObj = NSJSONSerialization.JSONObjectWithData(data, options:nil, error: nil) as? NSDictionary {
                println(respObj)
            }
            if error {
                println(error)
                completion(error: error)
            } else {
                self.data.removeAtIndex(index)
                dispatch_async(dispatch_get_main_queue()) {
                    completion(error: nil)
                }
            }
        }
        task.resume()
    }
}
