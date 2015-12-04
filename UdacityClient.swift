//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Craig Vanderzwaag on 11/25/15.
//  Copyright © 2015 blueHula Studios. All rights reserved.
//

import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import Reachability


class UdacityClient: NSObject {
    
    var isReachable: Bool?
    
    var baseURL: String? = nil
    
    /* Facebook Access Token */
    var accessToken: String? = nil
    
    /* Shared session */
    var session: NSURLSession
    
    /* Authentication state */
    var sessionID : String? = nil
    var userID : String? = nil
    var udacityUser : StudentInfo? = nil
    
    /* students array */
  //  var students : [StudentInfo]? = nil
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    
    //MARK: Network Connection
    
    func checkNetworkConnection() {
        
        let reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                if reachability.isReachableViaWiFi() {
                    self.isReachable = true
                    print("Reachable via WiFi")
                } else {
                    self.isReachable = true
                    print("Reachable via Cellular")
                }
            }
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                self.isReachable = false
                print("Not reachable")
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
    }
    
    func taskForGETMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        
        //Check if we're calling Udacity or Parse API and assigning associated URL
        if (method.containsString(UdacityClient.ParameterKeys.api)){
            baseURL = UdacityClient.Constants.UdacityBaseURLSecure
        }
        else{
            baseURL = UdacityClient.Constants.ParseBaseURLSecure
        }
        
        //Build the URL and configure the request
        let urlString = baseURL! + method + UdacityClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "GET"
        
        if (method.containsString(UdacityClient.ParameterKeys.api)){
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }else{
            request.addValue(UdacityClient.Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(UdacityClient.Constants.ParseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }
        
        // Perform GET with Completion options and error/response handling
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // Was there an error?
            guard (error == nil) else {
                let userInfo = [NSLocalizedDescriptionKey : error!.localizedDescription]
                completionHandler(result: false, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                return
            }
            
            //Did we get a sucessful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    let userInfo = [NSLocalizedDescriptionKey : "Your request returned an invalid response! Status code: \(response.statusCode)!"]
                    completionHandler(result: false, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                } else if let response = response {
                    let userInfo = [NSLocalizedDescriptionKey : "Your request returned an invalid response! Response: \(response)!"]
                    completionHandler(result: false, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                } else {
                    let userInfo = [NSLocalizedDescriptionKey : "Your request returned an invalid response!"]
                    completionHandler(result: false, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                }
                return
            }
            
            //Was there any data returned?
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey : "No data was returned by the request!"]
                completionHandler(result: false, error: NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
                return
            }
           
            //Pass Data to parse method for parsing
            UdacityClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        //Start the request
        task.resume()
        
        return task
    }
    
    func taskForPOSTMethod(method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        //Check if we're calling Udacity or Parse API and assigning associated URL
        if (method.containsString(UdacityClient.ParameterKeys.api)){
            baseURL = UdacityClient.Constants.UdacityBaseURLSecure
        }
        else{
            baseURL = UdacityClient.Constants.ParseBaseURLSecure
        }
        
        //Build the URL and configure the request
        let urlString = baseURL! + method + UdacityClient.escapedParameters(parameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        if (method.containsString("classes")){
            request.addValue(UdacityClient.Constants.ParseAppID, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(UdacityClient.Constants.ParseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        else{
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Fetch failed: \((error as NSError).localizedDescription)"]
            completionHandler(result: false, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
        }
        
        // Perform POST with Completion options and error/response handling
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            guard (error == nil) else {
                let userInfo = [NSLocalizedDescriptionKey : error!.localizedDescription]
                completionHandler(result: false, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                return
            }
            
            //Did we get a sucessful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    if response.statusCode == 403{
                        
                        let userInfo = [NSLocalizedDescriptionKey : "Invalid Username or Password"]
                        completionHandler(result: false, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                    }else if response.statusCode == 400{
                        let userInfo = [NSLocalizedDescriptionKey : "Failed to Post User Data"]
                        completionHandler(result: false, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                    }
                    else{
                        let userInfo = [NSLocalizedDescriptionKey : "Your request returned an invalid response! Status code: \(response.statusCode)!"]
                        completionHandler(result: false, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                    }
                } else if let response = response {
                    let userInfo = [NSLocalizedDescriptionKey : "Your request returned an invalid response! Response: \(response)!"]
                    completionHandler(result: false, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                } else {
                    let userInfo = [NSLocalizedDescriptionKey : "Your request returned an invalid response!"]
                    completionHandler(result: false, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                }
                return
            }
            
            //Was there any data returned?
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey : "No data was returned by the request!"]
                completionHandler(result: false, error: NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
                return
            }
            
             //Pass Data to parse method for parsing
            UdacityClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        //Start the request
        task.resume()
        
        return task
    }
    
    func taskForDeleteMethod(method: String, completionHandler: (result: AnyObject?, error: NSError?) -> Void) {
        
        //Build the URL and configure the request
        baseURL = UdacityClient.Constants.UdacityBaseURLSecure
        
        let urlString = baseURL! + method
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "DELETE"
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! as [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
         // Perform DELETE with Completion options and error/response handling
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            guard (error == nil) else {
                let userInfo = [NSLocalizedDescriptionKey : error!.localizedDescription]
                completionHandler(result: false, error: NSError(domain: "taskForDeleteMethod", code: 1, userInfo: userInfo))
                return
            }
            
            //Did we get a sucessful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    let userInfo = [NSLocalizedDescriptionKey : "Your request returned an invalid response! Status code: \(response.statusCode)!"]
                    completionHandler(result: false, error: NSError(domain: "taskForDeleteMethod", code: 1, userInfo: userInfo))
                } else if let response = response {
                    let userInfo = [NSLocalizedDescriptionKey : "Your request returned an invalid response! Response: \(response)!"]
                    completionHandler(result: false, error: NSError(domain: "taskForDeleteMethod", code: 1, userInfo: userInfo))
                } else {
                    let userInfo = [NSLocalizedDescriptionKey : "Your request returned an invalid response!"]
                    completionHandler(result: false, error: NSError(domain: "taskForDeleteMethod", code: 1, userInfo: userInfo))
                }
                
                return
            }
            
            //Was there any data returned?
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey : "No data was returned by the request!"]
                completionHandler(result: false, error: NSError(domain: "taskForDeleteMethod", code: 1, userInfo: userInfo))
                return
            }
            //Pass Data to parse method for parsing
            UdacityClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }
        
        //Start the request
        task.resume()
       
        
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            if (UdacityClient.sharedInstance().baseURL!.containsString(UdacityClient.JSONBodyKeys.UCBodyHeader)){
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data.subdataWithRange(NSMakeRange(5, data.length - 5)), options: .AllowFragments)}
            else{
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            }
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the received data"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandler(result: parsedResult, error: nil)
       
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
     
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }

    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
}


