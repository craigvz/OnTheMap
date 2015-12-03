//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Craig Vanderzwaag on 11/21/15.
//  Copyright © 2015 blueHula Studios. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var students: [StudentInfo] = [StudentInfo]()
    @IBOutlet var studentTableView: UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let background = CAGradientLayer().turquoiseColor()
        background.frame = self.view.bounds
        self.view.layer.insertSublayer(background, atIndex: 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UdacityClient.sharedInstance().getStudentLocations { students, error in
            if let students = students {
                self.students = students
                dispatch_async(dispatch_get_main_queue()) {
                  
                }
            } else {
                print(error)
            }
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UdacityClient.sharedInstance().students!.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:StudentCell = studentTableView!.dequeueReusableCellWithIdentifier("cell") as! StudentCell
        
        let student = UdacityClient.sharedInstance().students![indexPath.row]
        
        cell.firstName?.text = student.firstName
        cell.lastName?.text = student.lastName
        cell.location?.text = student.mapString
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let student = UdacityClient.sharedInstance().students![indexPath.row]
        
        if !UIApplication.sharedApplication().openURL(NSURL(string: student.mediaURL)!) {
            
            let controller = UIAlertController.showAlertController("Invalid Link", alertMessage: "User did not supply a valid URL")
            dispatch_async(dispatch_get_main_queue()){
                self.presentViewController(controller, animated: true, completion: nil)
            }
        } else {
            
            UIApplication.sharedApplication().openURL(NSURL(string: student.mediaURL)!)
        }
    }

    
    func didTouchLogoutButton() {
        
        if ((FBSDKAccessToken.currentAccessToken()) != nil) {
            FBSDKAccessToken.setCurrentAccessToken(nil)
            
        }
        
        FBSDKLoginManager().logOut()
        
        UdacityClient.sharedInstance().logOutOfSession() { (didSucceed, error) -> Void in
            if (didSucceed){
                dispatch_async(dispatch_get_main_queue()) {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            else{
                dispatch_async(dispatch_get_main_queue()) {
                    print(error)
                    let controller = UIAlertController.showAlertController("Uh OK", alertMessage: "Unable to Logout- Try Again")
                    self.presentViewController(controller, animated: true, completion: nil)
                
            }
            }
        }
    }

}
