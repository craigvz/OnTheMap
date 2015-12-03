//
//  UIAlertController+Convenience.swift
//  OnTheMap
//
//  Created by Craig Vanderzwaag on 12/2/15.
//  Copyright © 2015 blueHula Studios. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    class func showAlertController (alertTitle: String, alertMessage: String) -> UIAlertController {
        let alertController = UIAlertController(
            title: alertTitle,
            message: alertMessage,
            preferredStyle: .Alert)
        
        let OKAction = UIAlertAction(
            title: "OK",
            style: .Default,
            handler: nil)
        
        alertController.addAction(OKAction)
        
        return alertController

    }

}
