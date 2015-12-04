//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Craig Vanderzwaag on 11/27/15.
//  Copyright © 2015 blueHula Studios. All rights reserved.
//

extension UdacityClient {
    
    //MARK: Constants
    struct Constants {
        
        //MARK: API Key
        static let ParseAPIKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        //MARK: AppID
        
        static let FBAppID : String = "365362206864879"
        static let ParseAppID : String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        
        //MARK URL's
        static let ParseBaseURLSecure : String = "https://api.parse.com/1/"
        static let UdacityBaseURLSecure : String = "https://www.udacity.com/"
        
    }
    
    struct Methods  {
        
        //MARK: Udacity Methods
        
        static let UdacitySession = "api/session"
        static let UdacityUserID = "api/users/{user_id}"
        
        //MARK: Parse Methods
        static let ParseStudentLocation = "classes/StudentLocation"
        
    }
    
    struct ParameterKeys {
        
        //MARK: Udacity Parameter Keys
        static let api = "api"
        
        //MARK: Parse Parameter Keys
        static let Limit = "limit"
        static let Skip = "skip"
        static let Order = "order"
    }
    
    struct JSONBodyKeys{
        
        //MARK: Udacity JSON Body Keys
        static let UCBodyHeader = "udacity"
        static let Username = "username"
        static let Password = "password"
        
        //facebook
        static let FBBodyHeader = "facebook_mobile"
        static let AccessToken = "access_token"
        
        //MARK: Parse JSON Body Keys
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let UpdatedAt = "updatedAt"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude =  "latitude"
        static let Longitude = "longitude"
    }
    
    struct JSONResponseKeys{
        
        //MARK: Udacity JSON Response Keys
        static let UserID = "key"
        static let Account = "account"
        static let User = "user"
        static let LastName = "last_name"
        static let FirstName = "first_name"
        static let LinkedInUrl = "linkedin_url"
        static let session = "session"
        static let expiration = "id"
        
        //MARK: Parse JSON Response Keys
        static let ObjectID = "objectId"
        static let UniqueKey = "uniqueKey"
        static let UpdatedAt = "updatedAt"
        static let ParseFirstName = "firstName"
        static let ParseLastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude =  "latitude"
        static let Longitude = "longitude"
        static let objectid = "objectId"
        static let results = "results"
        
    }
    
    struct URLKeys{
        static let UserID = "user_id"
    }
    
}
