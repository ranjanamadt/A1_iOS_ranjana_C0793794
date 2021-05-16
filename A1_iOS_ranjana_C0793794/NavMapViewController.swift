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
    
    // Dictionary to keep tapped location coordinates and titles
    var tappedLocation = [String:CLLocationCoordinate2D]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Enable User's Current Location on Map
        mapView.showsUserLocation=true
        
        // Intially Hide Navigation Button
        btnNavigation.isHidden=true
        
        // Giving delegates of MKMapViewDelegate to this class
        mapView.delegate=self
    
        // Giving delegate of locationManager to this class
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
    
  
    
    //MARK:-Function that respond to location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //removePin()
        let userLoc=locations[0]
        
        // Return Latitude and longitude of current location of User
        let userLat = userLoc.coordinate.latitude
        let userLong = userLoc.coordinate.longitude
     
        // Display annotation on current location of user
        displayAnnotaionOnLocation(latitude: userLat, longitude: userLong, locTitle: "Your Location", locSubtitle: "you are here")
        
    }

    //MARK:- Function to diaplay annotation on current location of User
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

    //MARK: - Function to drop Annotation on Map for Tapped Location
    @objc func dropMarkerOnTapLocation(sender: UITapGestureRecognizer) {
        
        // If User have not added any location then add location woth title "A" and keep navigation button hidden
        if (tappedLocation.isEmpty){
            mapView.removeOverlays(mapView.overlays)
            addAnnotationWithTitle(title: "A", sender: sender)
            btnNavigation.isHidden=true
        }else if (tappedLocation.count<3){
            
            // If User have at least one and less than 3 locations in tapped list
            if(!tappedLocation.keys.contains("A")){
                addAnnotationWithTitle(title: "A", sender: sender)
            }else if (!tappedLocation.keys.contains("B")){
                addAnnotationWithTitle(title: "B", sender: sender)
            }else if (!tappedLocation.keys.contains("C")){
                addAnnotationWithTitle(title: "C", sender: sender)
            }
            
        }else if(tappedLocation.count==3){
            // If user already added 3 locations tryng to add the 4th
           removePin()
           tappedLocation.removeAll()
           btnNavigation.isHidden=true
            mapView.removeOverlays(mapView.overlays)
            addAnnotationWithTitle(title: "A", sender: sender)
        }

    
    }
    
    //MARK:- Add annotation on map double tap gesture
    
    func addAnnotationWithTitle(title:String,sender :UITapGestureRecognizer) {
        let touchPoint = sender.location(in: mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.title = title
        
        var isNearByCoordinate=false
      
        
        // Check if user to Tap on  marker or close in distance of 300 meters from  marker
        for tappedLoc in tappedLocation{
            if (distanceBetweenTwoCoordinates(firstLocation:convert2DToCLLoc(toCovert: tappedLoc.value),
                                              secondLocation: convert2DToCLLoc(toCovert: coordinate))<=300
            ){
                isNearByCoordinate=true
                // remove marker
                tappedLocation.removeValue(forKey: tappedLoc.key)
                removeAnnotationFormMapAt(coodrinates: tappedLoc.value)
                break;
            }
        }
        
        
        // If Tap is not near by of any marker
        if(!isNearByCoordinate){
            if(tappedLocation.count<3){
                annotation.coordinate = coordinate
                mapView.addAnnotation(annotation)
                tappedLocation[title]=coordinate
            }
        }
      
        // If adding third marker drwa the polygon
        if(tappedLocation.count==3){
            btnNavigation.isHidden=false
            //drawTrianglePolylines()
            let values  = tappedLocation.values
            var coordinates = [CLLocationCoordinate2D]()
            for value in values{
                coordinates.append(value)
            }
            coordinates.append(coordinates[0])
            drawTrianglePolygon(coordinates: coordinates)
        }
        
        
       
    }
    
//    //MARK:- Method to draw Ploylines
//    func drawTrianglePolylines(coordinates : [CLLocationCoordinate2D]) {
//        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
//
//        mapView.addOverlay(polyline)
//    }
    
    //MARK: - Draw Polygon in connecting all 3 locations and fill
    func drawTrianglePolygon(coordinates : [CLLocationCoordinate2D]) {
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
      
        mapView.addOverlay(polygon)
    }
    
    //MARK: - Remove all pins from mapview
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
   
    //MARK: - Remove annotation from near by location of dropped marker
    func removeAnnotationFormMapAt(coodrinates: CLLocationCoordinate2D) {
        for annotation in mapView.annotations {
            if(distanceBetweenTwoCoordinates(firstLocation:convert2DToCLLoc(toCovert: annotation.coordinate),
                                             secondLocation: convert2DToCLLoc(toCovert: coodrinates))<=300){
               mapView.removeAnnotation(annotation)
            }
        }
    }
   
    
    //MARK: - Draw routes between 3 locations
    @IBAction func onNavigationclick(_ sender: UIButton) {
        
        mapView.removeOverlays(mapView.overlays)

        drawRouteBetweenPoints(sourceCoordinate: tappedLocation["A"]!, desCoordinates: tappedLocation["B"]!)
        drawRouteBetweenPoints(sourceCoordinate: tappedLocation["B"]!, desCoordinates: tappedLocation["C"]!)
        drawRouteBetweenPoints(sourceCoordinate: tappedLocation["C"]!, desCoordinates: tappedLocation["A"]!)
        
    }
  
    //MARK:- Function to draw routes between two points
    func drawRouteBetweenPoints(sourceCoordinate : CLLocationCoordinate2D,desCoordinates : CLLocationCoordinate2D) {
    
    let sourcePlaceMark = MKPlacemark(coordinate: sourceCoordinate)
    let destinationPlaceMark = MKPlacemark(coordinate: desCoordinates)
    
    // Request to Get Direction
    let directionRequest = MKDirections.Request()
    
    // Assign source and destination properties to request
    directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
    directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
    
    // Set Tranportation type
    directionRequest.transportType = .automobile
    
    // Calculate the direction
    let directions = MKDirections(request: directionRequest)
    directions.calculate { (response, error) in
        guard let directionResponse = response else {return}
        // Create the route
        let route = directionResponse.routes[0]
        // Draw a polyline
        self.mapView.addOverlay(route.polyline, level: .aboveRoads)
        
        // Define the bounding map rect
        let rect = route.polyline.boundingMapRect
        self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 200, right: 100), animated: true)
        
    }
}

}

// MARK:-Function to calculate the difference between two locations
func distanceBetweenTwoCoordinates(firstLocation:CLLocation,secondLocation :CLLocation)->Int{
    let difference = Int(firstLocation.distance(from: secondLocation))
    return difference
}

//MARK:- Method to convert CLLocationCoordinate2D to CLLocation
func convert2DToCLLoc(toCovert:CLLocationCoordinate2D)->CLLocation{
    return CLLocation(latitude: toCovert.latitude, longitude: toCovert.longitude)
}

extension NavMapViewcontroller: MKMapViewDelegate {
    
    //MARK: - Cusrtomize the annotations
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
    
        switch annotation.title {
        case "Current Location":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
           annotationView.markerTintColor = .blue
            annotationView.image = UIImage(named: "ic_marker")
            return annotationView
        case "A":
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AcustomPin") ?? MKPinAnnotationView()
            annotationView.image = UIImage(named: "ic_marker_pink")
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            return annotationView
        case "B":
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "BcustomPin") ?? MKPinAnnotationView()
            annotationView.image = UIImage(named: "ic_marker_pink")
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return annotationView
        case "C":
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "CcustomPin") ?? MKPinAnnotationView()
            annotationView.image = UIImage(named: "ic_marker_pink")
            annotationView.canShowCallout = true
            
            let label=UILabel()
            
            label.text=String(mapView.userLocation.location!.distance(from: CLLocation(latitude:tappedLocation["C"]!.latitude,longitude: tappedLocation["C"]!.longitude)))
            
            annotationView.rightCalloutAccessoryView=label
        
            //print(String(mapView.userLocation.location!.distance(from: CLLocation(latitude:tappedLocation["C"]!.latitude,longitude: tappedLocation["C"]!.longitude))))
            
            
            return annotationView
        default:
            return nil
        }
    }
    //MARK: - Function for renderer of overlays
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
       if overlay is MKPolyline {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.strokeColor = UIColor.blue
            rendrer.lineWidth = 3
            return rendrer
        } else if overlay is MKPolygon {
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.5)
            rendrer.strokeColor = UIColor.systemGreen
            rendrer.lineWidth = 3
            return rendrer
        }
        return MKOverlayRenderer()
    }
    
}


