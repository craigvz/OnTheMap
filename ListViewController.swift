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
    
    @IBOutlet var studentTableView: UITableView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let background = CAGradientLayer().turquoiseColor()
        background.frame = self.view.bounds
        self.view.layer.insertSublayer(background, atIndex: 0)
        print(StudentData().students)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Retrieve Student Info
        UdacityClient.sharedInstance().getStudentLocations { (students, error) -> Void in
            if let students = students as [StudentInfo]!{
                StudentData.sharedInstance().students = students
                
                dispatch_async(dispatch_get_main_queue()) {
                    print("Successfully retrieved Student Info")
                    self.studentTableView?.reloadData()
                }
            } else {
                    print(error)
            }
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
            return StudentData.sharedInstance().students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:StudentCell = studentTableView!.dequeueReusableCellWithIdentifier("cell") as! StudentCell
        
        let student = StudentData.sharedInstance().students[indexPath.row]
    
        
        cell.firstName?.text = student.firstName
        cell.lastName?.text = student.lastName
        cell.location?.text = student.mapString
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let student = StudentData.sharedInstance().students[indexPath.row]
        
        if !UIApplication.sharedApplication().openURL(NSURL(string: student.mediaURL)!) {
            
            let controller = UIAlertController.showAlertController("Invalid Link", alertMessage: "User did not supply a valid URL")
            dispatch_async(dispatch_get_main_queue()){
                self.presentViewController(controller, animated: true, completion: nil)
            }
        } else {
            
            UIApplication.sharedApplication().openURL(NSURL(string: student.mediaURL)!)
        }
    }
    
    @IBAction func didTouchRefreshButton(sender: AnyObject) {
        
        //Retrieve Student Info
        UdacityClient.sharedInstance().getStudentLocations { (students, error) -> Void in
            if let students = students as [StudentInfo]!{
                StudentData.sharedInstance().students = students
                dispatch_async(dispatch_get_main_queue()) {

                    self.studentTableView?.reloadData()
                }
            }else{
                dispatch_async(dispatch_get_main_queue()) {
                    print(error)
                    let controller = UIAlertController.showAlertController("OOPS", alertMessage: "Something wen't wrong and cant refresh- Try Again")
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            }
        }
    }

    @IBAction func didTouchLogoutButton() {
        
        if ((FBSDKAccessToken.currentAccessToken()) != nil) {
            FBSDKAccessToken.setCurrentAccessToken(nil)
        }
        
        FBSDKLoginManager().logOut()
        
        UdacityClient.sharedInstance().logOutOfSession() { (didSucceed, error) -> Void in
            if (didSucceed){
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentLoginViewController()
                }
            }
            else{
                dispatch_async(dispatch_get_main_queue()) {
                    print(error)
                    let controller = UIAlertController.showAlertController("OOPS", alertMessage: "Unable to Logout- Try Again")
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            }
        }
    }
    
    func presentLoginViewController () {
        
        if(UdacityClient.sharedInstance().userID == nil) && (FBSDKAccessToken.currentAccessToken() == nil){
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("loginVC") as! UdacityLoginViewController
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }

}
