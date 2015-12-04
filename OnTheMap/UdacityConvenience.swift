//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by Craig Vanderzwaag on 11/27/15.
//  Copyright © 2015 blueHula Studios. All rights reserved.
//

import Foundation
import UIKit

extension UdacityClient {
    
    func logOutOfSession(completionHandler: (didSucceed: Bool, error: NSError?) -> Void){
        
        
        taskForDeleteMethod(UdacityClient.Methods.UdacitySession) { (result, error) -> Void in
            
            if let error = error {
                completionHandler(didSucceed: false, error: error)
            } else {
                completionHandler(didSucceed: true, error: nil)
                self.userID = nil
            }
        }
    }
    
    func postUserLocation(student: StudentInfo, completionHandler: (result: String?, errorString: String?) -> Void)  {
        
        let parameters = [String: AnyObject]()
        
        let jsonBody : [String:AnyObject] = [
            UdacityClient.JSONBodyKeys.UniqueKey: student.uniqueKey!,
            UdacityClient.JSONBodyKeys.FirstName: student.firstName,
            UdacityClient.JSONBodyKeys.LastName: student.lastName,
            UdacityClient.JSONBodyKeys.MapString: student.mapString,
            UdacityClient.JSONBodyKeys.MediaURL: student.mediaURL,
            UdacityClient.JSONBodyKeys.Latitude: student.lat!,
            UdacityClient.JSONBodyKeys.Longitude: student.lon!

        ]
        
        taskForPOSTMethod(UdacityClient.Methods.ParseStudentLocation, parameters: parameters, jsonBody: jsonBody) { JSONResult, error in
            
            if let error = error {
                completionHandler(result: nil, errorString: error.localizedDescription)
            } else {
                if let results = JSONResult[UdacityClient.JSONResponseKeys.objectid] as? String {
                    completionHandler(result: results, errorString: nil)
                } else {
                    completionHandler(result: nil, errorString: "Could not find objectID." )
                }
            }
        }
    }
    
    
    func authenticateWithViewController(hostViewController: UdacityLoginViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {
    
        self.createSessionWithUserNameAndPassword(hostViewController.emailTextField.text!, password: hostViewController.passwordTextField.text!) { (success, userID, errorString) -> Void in
                            if success{
                                self.userID = userID
            
                                self.getPublicUserData({ ( success, result, error) -> Void in
                                    if (success){
            
                                        let userStudentInfo = StudentInfo(dictionary: [
                                            UdacityClient.JSONResponseKeys.UniqueKey: self.userID!,
                                            UdacityClient.JSONResponseKeys.ParseFirstName: result?[UdacityClient.JSONResponseKeys.FirstName] as! String,
                                            UdacityClient.JSONResponseKeys.ParseLastName: result?[UdacityClient.JSONResponseKeys.LastName] as! String,
                                            UdacityClient.JSONResponseKeys.MapString:"",
                                            UdacityClient.JSONResponseKeys.MediaURL:"",
                                            UdacityClient.JSONResponseKeys.Latitude:0.0,
                                            UdacityClient.JSONResponseKeys.Longitude:0.0
                                            ])
            
                                        UdacityClient.sharedInstance().udacityUser = userStudentInfo
            
                                        completionHandler(success: success, errorString: nil)
                                    }
                                    else{
                                        completionHandler(success: success, errorString: error!.localizedDescription)
                                    }
                                })
                            }
                            else{
                                completionHandler(success: success, errorString: errorString)
                            }
        }
    }
    
        
    
    
    
    
    func authenticateWithFacebook(accessToken: String, completionHandler: (success: Bool, errorString: String?) -> Void){
        createSessionWithFacebook(accessToken) { (success, userID, errorString) -> Void in
            if success{
                self.userID = userID
                
                self.getPublicUserData({ ( success, result, error) -> Void in
                    if (success){
                        
                        let udacityStudentInfo = StudentInfo(dictionary: [
                            UdacityClient.JSONResponseKeys.UniqueKey: self.userID!,
                            UdacityClient.JSONResponseKeys.ParseFirstName: result?[UdacityClient.JSONResponseKeys.FirstName] as! String,
                            UdacityClient.JSONResponseKeys.ParseLastName: result?[UdacityClient.JSONResponseKeys.LastName] as! String,
                            UdacityClient.JSONResponseKeys.MapString:"",
                            UdacityClient.JSONResponseKeys.MediaURL:"",
                            UdacityClient.JSONResponseKeys.Latitude:0.0,
                            UdacityClient.JSONResponseKeys.Longitude:0.0
                            ])
                        
                        UdacityClient.sharedInstance().udacityUser = udacityStudentInfo
                        
                        completionHandler(success: success, errorString: nil)
                    }
                    else{
                        completionHandler(success: success, errorString: error!.localizedDescription)
                    }
                })
            }
            else{
                completionHandler(success: success, errorString: errorString)
            }
        }
}
    
    func getPublicUserData(completionHandler: (success: Bool, result: [String:AnyObject]?, error: NSError?) -> Void){
        
        let parameters = [String: AnyObject]()
        
        var mutableMethod : String = Methods.UdacityUserID
        
        mutableMethod = UdacityClient.subtituteKeyInMethod(mutableMethod, key: UdacityClient.URLKeys.UserID, value: String(UdacityClient.sharedInstance().userID!))!
        
        taskForGETMethod(mutableMethod, parameters: parameters) { JSONResult, error in
            
            if let error = error {
                completionHandler(success: false, result: nil, error: error)
            } else {
                if let result  = JSONResult[UdacityClient.JSONResponseKeys.User] as? [String:AnyObject]{
                    completionHandler(success: true, result: result, error: nil)
                }else{
                    completionHandler(success: false, result: nil, error: NSError(domain: "getPublicUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getPublicUserData"]))
                }
            }
        }
    }
    
    func createSessionWithUserNameAndPassword(username: String, password: String, completionHandler: (success: Bool, userID: String?, errorString: String?) -> Void) {
        
        let parameters = [String: AnyObject]()
        
        let jsonBody : [String:AnyObject] = [
            UdacityClient.JSONBodyKeys.UCBodyHeader: [
                UdacityClient.JSONBodyKeys.Username: username,
                UdacityClient.JSONBodyKeys.Password: password
            ]
        ]
        
        taskForPOSTMethod(UdacityClient.Methods.UdacitySession, parameters: parameters, jsonBody: jsonBody) { (JSONResult, error) -> Void in
            
            if let error = error {
                completionHandler(success: false, userID: nil, errorString: String(error.userInfo[NSLocalizedDescriptionKey]!))
            } else {
                if let userID = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Account)!.valueForKey(UdacityClient.JSONResponseKeys.UserID) as? String! {
                    completionHandler(success: true, userID: userID, errorString: nil)
                } else {
                    print("Could not find \(UdacityClient.JSONResponseKeys.Account) \(UdacityClient.JSONResponseKeys.UserID) in \(JSONResult)")
                    completionHandler(success: false, userID: nil, errorString: "Login Failed (Create Session with UserName And Password)")
                }
            }
        }
    }
    
    func createSessionWithFacebook(accessToken: String, completionHandler: (success: Bool, userID: String?, errorString: String?) -> Void) {
        
        let parameters = [String: AnyObject]()
        
        let jsonBody : [String:AnyObject] = [
            UdacityClient.JSONBodyKeys.FBBodyHeader: [
                UdacityClient.JSONBodyKeys.AccessToken: accessToken
            ]
        ]
        
        taskForPOSTMethod(UdacityClient.Methods.UdacitySession, parameters: parameters, jsonBody: jsonBody) { (JSONResult, error) -> Void in
            
            if let error = error {
                completionHandler(success: false, userID: nil, errorString: String(error.userInfo[NSLocalizedDescriptionKey]!))
            } else {
                if let userID = JSONResult.valueForKey(UdacityClient.JSONResponseKeys.Account)!.valueForKey(UdacityClient.JSONResponseKeys.UserID) as? String! {
                    completionHandler(success: true, userID: userID, errorString: nil)
                } else {
                    print("Could not find \(UdacityClient.JSONResponseKeys.Account) \(UdacityClient.JSONResponseKeys.UserID) in \(JSONResult)")
                    completionHandler(success: false, userID: nil, errorString: "Login Failed (Create Session with Facebook)")
                }
            }
        }
    }
    
    func getStudentLocations(completionHandler: (result: [StudentInfo]?, error: NSError?) -> Void){
        
        let parameters = [UdacityClient.ParameterKeys.Limit : "100",
            UdacityClient.ParameterKeys.Order : "-updatedAt"
        ]
        
        taskForGETMethod(Methods.ParseStudentLocation, parameters: parameters) { JSONResult, error in
            
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if let results = JSONResult[UdacityClient.JSONResponseKeys.results] as? [[String:AnyObject]]{
                    let students = StudentInfo.studentsFromResults(results)
                        StudentData.sharedInstance().students = students
                    
                    completionHandler(result: students, error: nil)
                }
                else{
                    completionHandler(result: nil, error: NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse StudentLocations"]))
                }
            }
        }
    }
}
