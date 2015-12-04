//
//  StudentData.swift
//  OnTheMap
//
//  Created by Craig Vanderzwaag on 12/3/15.
//  Copyright © 2015 blueHula Studios. All rights reserved.
//

import UIKit

class StudentData: NSObject {
    
    var students = [StudentInfo]()
    
    override init() {
        
        super.init()
    }
    
    class func sharedInstance() -> StudentData {
        
        struct Singleton {
            static var sharedInstance = StudentData()
            
        }
        return Singleton.sharedInstance
    }

}
