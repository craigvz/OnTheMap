//
//  GeocodeAddressViewController.swift
//  OnTheMap
//
//  Created by Craig Vanderzwaag on 12/2/15.
//  Copyright © 2015 blueHula Studios. All rights reserved.
//

import UIKit
import MapKit

class GeocodeAddressViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userLocationMapView: MKMapView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var submitButton: UIButton!
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 100, 100)) as UIActivityIndicatorView

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userLocationMapView.hidden = true
        let background = CAGradientLayer().turquoiseColor()
        background.frame = self.view.bounds
        self.view.layer.insertSublayer(background, atIndex: 0)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTouchCancelButton(sender: AnyObject) {
    
        self.dismissViewControllerAnimated(true, completion: nil)
    
    }
    @IBAction func didTouchSubmitButton(sender: AnyObject) {
        locationTextField.resignFirstResponder()
        geocodeAddress(locationTextField.text!)
    }
    
    func geocodeAddress(submittedLocation: String) {
        
        startSpinning()
        
        //Additional indications of activity, such as modifying alpha/transparency of interface elements.
        titleLabel.text = "Geocoding..."
        submitButton.alpha = 0.5
        self.view.alpha = 0.5
        
        let geoCoder = CLGeocoder()
        
        if (UdacityClient.sharedInstance().isReachable == false) {
            let controller = UIAlertController.showAlertController("Network Trouble", alertMessage: "Could not connect to the internet- Try Again")
            self.presentViewController(controller, animated: true, completion: nil)
        } else {
        
        geoCoder.geocodeAddressString(submittedLocation) { (placeMarks, error) -> Void in
            
            if let placemark = placeMarks?[0] as CLPlacemark?{
              //  self.switchToMapView()
                
                self.userLocationMapView.hidden = false
                self.userLocationMapView.addAnnotation(MKPlacemark(placemark: placemark))
                
                let span = MKCoordinateSpanMake(0.03, 0.03)
                var region = MKCoordinateRegion(center: placemark.location!.coordinate, span: span)
                region = self.userLocationMapView.regionThatFits(region)
                self.userLocationMapView.setRegion(region, animated: true)
                
                UdacityClient.sharedInstance().udacityUser?.mapString = self.locationTextField.text!
                UdacityClient.sharedInstance().udacityUser?.lat = Double((placemark.location?.coordinate.latitude)!)
                UdacityClient.sharedInstance().udacityUser?.lon = Double((placemark.location?.coordinate.longitude)!)

                self.activityIndicator.stopAnimating()
                self.titleLabel.text = "Hi There!"
                self.submitButton.alpha = 1.0
                self.view.alpha = 1.0
            }
            else{
                print("Could Not Geocode String")
                self.activityIndicator.stopAnimating()
                let controller = UIAlertController.showAlertController("Darn it!", alertMessage: "Could not Geocode String- Try Again")
                dispatch_async(dispatch_get_main_queue()){
                    self.presentViewController(controller, animated: true, completion: nil)
                }

            }
        }
        }
        
    }
    
    func startSpinning() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}
