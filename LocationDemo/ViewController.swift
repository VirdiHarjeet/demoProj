//
//  ViewController.swift
//  LocationDemo
//
//  Created by Harjeet Singh on 01/04/23.
//

import UIKit
import CoreLocation
import MapKit


class ViewController: UIViewController {
    @IBOutlet weak var lblAdress: UILabel!
    
    @IBOutlet weak var mapView: MKMapView!
    var location:CLLocationManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        location = CLLocationManager()
        location.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        location.delegate = self
       checkLocationStatus()
    }
  
    func addPin(){
        let annotation = MKPointAnnotation()
        let regionRadius: CLLocationDistance = 2000
        annotation.coordinate = CLLocationCoordinate2D(latitude: 30.7046, longitude: 76.7179)
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 30.7046, longitude: 76.7179)
        let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius*5,longitudinalMeters: regionRadius*5)
        mapView.setRegion(viewRegion, animated: true)
        mapView.addAnnotation(annotation)
    }
    func checkLocationStatus(){
        switch CLLocationManager.authorizationStatus(){
        case .notDetermined:
            location.requestWhenInUseAuthorization()
        case .restricted:
            print("Location Restricted")
        case .denied:
            showSettingAlert(controller: self)
            print("Location Denied")
        case .authorizedAlways,.authorizedWhenInUse:
            location.startUpdatingLocation()
        @unknown default:
            print("somthing went wrong")
        }
    }
    
    func getAdress(location:CLLocation){
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, preferredLocale: .current) { placeMark, error in
            guard let place = placeMark?.first, error == nil else{return}
            print(place)
            let l = place.country
            let lo = place.locality
            let subLo = place.subAdministrativeArea
            let adminre = place.administrativeArea
            self.lblAdress.text = "\(String(describing: subLo)), \(adminre!), \(lo!), \(l!)"
        }
        
    }
}

extension ViewController:CLLocationManagerDelegate{
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            print(location)
            getAdress(location: location)
            addPin()
        }
        location.stopUpdatingLocation()
    }
    
}

extension UIViewController{
    func showSettingAlert(controller:UIViewController){
        let alert = UIAlertController(title: "You Not Allow Location", message: "Please Allow Location in Phone Settings", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Setting", style: UIAlertAction.Style.default, handler: { action in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
            
if UIApplication.shared.canOpenURL(settingsUrl) {
    UIApplication.shared.open(settingsUrl, completionHandler:{ (success) in
                        print("Settings opened: \(success)")
                        })
                    }
        }))
            self.present(alert, animated: true, completion: nil)
    }
}
 
extension UIViewController{
    func addnew(){
        // add two numbers
        let a = 5
        let b = 8
        let c = a+b
    }
}
