//
//  PostStudentInfoViewController.swift
//  OnTheMap
//
//  Created by Craig Vanderzwaag on 12/2/15.
//  Copyright © 2015 blueHula Studios. All rights reserved.
//

import UIKit

class PostStudentInfoViewController: UIViewController {
        
    @IBOutlet weak var urlTextField: UITextField!
        override func viewDidLoad() {
            super.viewDidLoad()
            
            let background = CAGradientLayer().turquoiseColor()
            background.frame = self.view.bounds
            self.view.layer.insertSublayer(background, atIndex: 0)

        }
    
    @IBAction func didTouchPostButton(sender: AnyObject) {
        
        if (urlTextField.text!.containsString("http://") || urlTextField.text!.containsString("https://")){

        UdacityClient.sharedInstance().udacityUser?.mediaURL = self.urlTextField.text!
        
        UdacityClient.sharedInstance().postUserLocation(UdacityClient.sharedInstance().udacityUser!, completionHandler: { (result, error) -> Void in
            if result != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
            }
            else{
                dispatch_async(dispatch_get_main_queue(), {

                })
            }
        })
        } else {
            
            let controller = UIAlertController.showAlertController("Darn it!", alertMessage: "Could not Post Location- Try Again")
            dispatch_async(dispatch_get_main_queue()){
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
    }
    
}
