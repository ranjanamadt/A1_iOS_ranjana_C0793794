//
//  ViewController.swift
//  A1_iOS_ranjana_C0793794
//
//  Created by one on 15/05/21.
//

import UIKit
import MapKit

class NavMapViewcontroller: UIViewController , CLLocationManagerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnNavigation: UIButton!
    
    // Create and intialize Location Manager Instance
    var locationManager = CLLocationManager()
    
    // Variable to keep count of dropped markers
    var countMarkers:Int=0
    
    // List to keep tapped location coordinates
    var tappedLocation = [String:CLLocationCoordinate2D]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Enable User's Current Location on Map
        mapView.showsUserLocation=true
        
        // Intially Hide Navigation Button
        btnNavigation.isHidden=true
        
    
        // Give the delegate of locationManager to this class
        locationManager.delegate = self
        
        // Set accuracy of the location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Request to access the location from User
        locationManager.requestWhenInUseAuthorization()
        
        // Update the location of User
        locationManager.startUpdatingLocation()
        
        // Add Double Tap Gesture on Map to drop location markers
        addDoubleTapGestureOnMap()
        
    }
    
    @IBAction func onNavigationclick(_ sender: UIButton) {
        
    }
    
    //MARK:-Function that respond to location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLoc=locations[0]  // Return Latitude and longitude of current location
        let userLat = userLoc.coordinate.latitude
        let userLong = userLoc.coordinate.longitude
        
      //  let userCurrentLocation = getCityFromLatLong(location: userLoc)
       // print(userCurrentLocation+"//////")
        
        // Display annotaion on current Location
        displayAnnotaionOnLocation(latitude: userLat, longitude: userLong, locTitle: "Current Location", locSubtitle: "you are here")
        
    }

    func displayAnnotaionOnLocation(latitude:CLLocationDegrees,longitude: CLLocationDegrees,locTitle:String, locSubtitle:String){
        //Defining Span lat long
        let latDelta: CLLocationDegrees = 0.10
        let lngDelta: CLLocationDegrees = 0.10
        
        // Defining Span
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        
        // Define the location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // Define the region
        let region = MKCoordinateRegion(center: location, span: span)
        
        // Set the region for the map
        mapView.setRegion(region, animated: true)
        
        // Define annotation
        let annotation = MKPointAnnotation()
        
        // Set annotation title
        annotation.title = title
        // Set annotation subtitle
        annotation.subtitle=locSubtitle
        // Give annotaion cooridinates
        annotation.coordinate = location
        // Add annotation to the map view
        mapView.addAnnotation(annotation)
     
    }
    //MARK: - Function to add Double Tap Gesture on Map
    func addDoubleTapGestureOnMap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropMarkerOnTapLocation))
        doubleTap.numberOfTapsRequired = 2
        mapView.addGestureRecognizer(doubleTap)
        
    }
    
//    //MARK:- Fucntion to get address from Latitude and longitude
//    func getCityFromLatLong(location:CLLocation) -> String {
//        var city=""
//
//        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
//            if error != nil {
//                print(error!)
//
//            } else {
//
//                if let placemark = placemarks?[0] {
//                    if placemark.country != nil {
//                        city = placemark.country! + " "
//
//                    }
//                }
//            }
//        }
//        return city
//    }
    
    @objc func dropMarkerOnTapLocation(sender: UITapGestureRecognizer) {
      
        countMarkers+=1
    
        switch countMarkers {
        case 1:
            addAnnotationWithTitle(title: "A", sender: sender)
        case 2:
            addAnnotationWithTitle(title: "B", sender: sender)
        case 3:
            addAnnotationWithTitle(title: "C", sender: sender)
            btnNavigation.isHidden=false
            drawTrianglePolylines()
            
        case 4:
            countMarkers=1
            removePin()
            tappedLocation.removeAll()
            addAnnotationWithTitle(title: "A", sender: sender)
            btnNavigation.isHidden=true
        default:
            print("Error")
        }
    
    }
    
    //MARK:- Add annotation on map double tap gesture
    func addAnnotationWithTitle(title:String,sender :UITapGestureRecognizer) {
        let touchPoint = sender.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        tappedLocation[title]=coordinate
    }
    
    //MARK:- Draw Ploylines in connecting all 3 locations
    func drawTrianglePolylines() {
       
    }
    
    //MARK: - Remove all pins from mapview
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
    
}

extension NavMapViewcontroller: MKMapViewDelegate {
    
    //MARK: - viewFor annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        switch annotation.title {
        case "Current Location":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
            annotationView.image = UIImage(named: "ic_marker")
            return annotationView
            
        case "A":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
            annotationView.image = UIImage(named: "ic_marker_pink")
            return annotationView
        case "B":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
            annotationView.image = UIImage(named: "ic_marker_pink")
            return annotationView
        case "C":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
            annotationView.image = UIImage(named: "ic_marker_pink")
            return annotationView
        default:
            return nil
        }
    }
}


