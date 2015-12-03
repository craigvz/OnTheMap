//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Craig Vanderzwaag on 11/21/15.
//  Copyright © 2015 blueHula Studios. All rights reserved.
//

import UIKit
import MapKit
import FBSDKLoginKit

class MapViewController: UIViewController {
    
        var filePath : String {
            let manager = NSFileManager.defaultManager()
            let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
            return url.URLByAppendingPathComponent("mapRegionArchive").path!
        }

    @IBOutlet weak var studentMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        
       presentLoginViewController()
    }
    
    func presentLoginViewController () {
        
        if(UdacityClient.sharedInstance().userID == nil) && (FBSDKAccessToken.currentAccessToken() == nil){
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("loginVC") as! UdacityLoginViewController
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
       
        //Retrieve Student Info
        UdacityClient.sharedInstance().getStudentLocations { (students, error) -> Void in
            if let students = students as [StudentInfo]!{
                UdacityClient.sharedInstance().students = students
                dispatch_async(dispatch_get_main_queue()) {
                    let annotationsToRemove = self.studentMapView.annotations
                    self.studentMapView.removeAnnotations( annotationsToRemove )
                    self.addMapAnnotations()
                }
        }
        else {
                print(error)
                let controller = UIAlertController.showAlertController("Oh No... ", alertMessage: "Could Not Retrieve Student Info- Try Again")
                dispatch_async(dispatch_get_main_queue()){
                    self.presentViewController(controller, animated: true, completion: nil)
                }

            }
        }
    }

    // MARK: - MapView Functions
    func addMapAnnotations()
    {
        var annotations = [MKPointAnnotation]()
        
        for student in UdacityClient.sharedInstance().students! {
            
            let lat = CLLocationDegrees(student.lat!)
            let long = CLLocationDegrees(student.lon!)
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = student.firstName
            let last = student.lastName
            let mediaURL = student.mediaURL
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        
        studentMapView.addAnnotations(annotations)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation!.subtitle!!)!)
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        saveMapRegion()
    }
    
    func saveMapRegion(){
        
        let dictionary = [
            "latitude" : studentMapView.region.center.latitude,
            "longtitude" : studentMapView.region.center.longitude,
            "latitudeDelta" : studentMapView.region.span.latitudeDelta,
            "longitudeDelta" : studentMapView.region.span.longitudeDelta
        ]
        
        NSKeyedArchiver.archiveRootObject(dictionary, toFile: filePath)
    }
    
    @IBAction func didTouchRefreshButton(sender: AnyObject) {

        //Retrieve Student Info
        UdacityClient.sharedInstance().getStudentLocations { (students, error) -> Void in
            if let students = students as [StudentInfo]!{
                UdacityClient.sharedInstance().students = students
                dispatch_async(dispatch_get_main_queue()) {

                    let annotationsToRemove = self.studentMapView.annotations
                    self.studentMapView.removeAnnotations( annotationsToRemove )
                    self.addMapAnnotations()
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

}
