//
//  StudentInfo.swift
//  OnTheMap
//
//  Created by Craig Vanderzwaag on 11/27/15.
//  Copyright © 2015 blueHula Studios. All rights reserved.
//

import Foundation

struct StudentInfo {
    
    var objectID: String?
    var uniqueKey: String?
    var firstName = ""
    var lastName = ""
    var mediaURL = ""
    var mapString = ""
    var lat: Double?
    var lon: Double?
    var createdAt: NSDate?
    var updatedAt: NSDate?
    

    
    init(dictionary: NSDictionary) {
        
        objectID = dictionary[UdacityClient.JSONResponseKeys.ObjectID] as? String
        uniqueKey = dictionary[UdacityClient.JSONResponseKeys.UniqueKey] as? String
        firstName = dictionary[UdacityClient.JSONResponseKeys.ParseFirstName] as! String
        lastName = dictionary[UdacityClient.JSONResponseKeys.ParseLastName] as! String
        mapString = dictionary[UdacityClient.JSONResponseKeys.MapString] as! String
        mediaURL = dictionary[UdacityClient.JSONResponseKeys.MediaURL] as! String
        
        if let latString = dictionary[UdacityClient.JSONResponseKeys.Latitude] as? NSNumber {
            lat = latString.doubleValue
        }
            
        if let lonString = dictionary[UdacityClient.JSONResponseKeys.Longitude] as? NSNumber {
            lon = lonString.doubleValue
        }
        
        if let timeString = dictionary[UdacityClient.JSONResponseKeys.UpdatedAt] as? String {
            let dateFormatter = NSDateFormatter()
            dateFormatter.timeZone = NSTimeZone(name: "UTC")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            let timestamp = dateFormatter.dateFromString(timeString)
            updatedAt = timestamp
        }
        
    }
    
    static func studentsFromResults(results: [[String : AnyObject]]) -> [StudentInfo] {
        var students = [StudentInfo]()
        
        for result in results {
            students.append(StudentInfo(dictionary: result))
        }
        
        return students
    }
}
