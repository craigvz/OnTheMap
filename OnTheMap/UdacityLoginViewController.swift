//
//  UdacityLoginViewController.swift
//  OnTheMap
//
//  Created by Craig Vanderzwaag on 11/21/15.
//  Copyright © 2015 blueHula Studios. All rights reserved.
//


import UIKit
import Reachability
import FBSDKLoginKit


class UdacityLoginViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    let client = UdacityClient.sharedInstance()
    let loginView : FBSDKLoginButton = FBSDKLoginButton()
    
    var isReachable: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        client.checkNetworkConnection()
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        
        if(FBSDKAccessToken.currentAccessToken() == nil) {
            
            print("User is not logged in")
        
        } else {
            
            FBSDKLoginManager().logOut()
        }

    }

    @IBAction func didTouchSignUpButton(sender: AnyObject) {
        
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
        
    }
    @IBAction func didTouchLogin(sender: AnyObject) {
        
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        if (client.isReachable == true){
        
            client.authenticateWithViewController(self) { (success, errorString) in
            if success {
                self.completeLogin()
            } else {
                print(errorString)
                let controller = UIAlertController.showAlertController("Login Failed", alertMessage: errorString!)
                dispatch_async(dispatch_get_main_queue()){
                    self.presentViewController(controller, animated: true, completion: nil)
                }

            }
        }
            } else {
            let controller = UIAlertController.showAlertController("Network Unavailable", alertMessage: "Check your internet connection and try again")
            dispatch_async(dispatch_get_main_queue()){
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: Facebook Login Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        if ((error) != nil)
        {
         
            let controller = UIAlertController.showAlertController("Facebook Fail", alertMessage: "Unable to login via Facebook. Make sure your Udacity account is linked to Facebook and try again")
                self.presentViewController(controller, animated: true, completion: nil)
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
                self.completeLogin()
            
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    // MARK: LoginViewController
    
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            print("Login Successful")
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    // MARK: Modify UI
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                print(errorString)
            }
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}
