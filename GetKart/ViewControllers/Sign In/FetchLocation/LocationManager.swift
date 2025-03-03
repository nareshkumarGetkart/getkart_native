//
//  LocationManager.swift
//  Getkart
//
//  Created by gurmukh singh on 2/18/25.
//

import Foundation
import CoreLocation
protocol LocationAutorizationUpdated {
    func locationAuthorizationUpdate()
}
final class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    var manager = CLLocationManager()
    var delegate:LocationAutorizationUpdated?
    
    var city = ""
    var state = ""
    var country = ""
    var timezone = ""
    
    func checkLocationAuthorization() {
        
        manager.delegate = self
        manager.startUpdatingLocation()
        
        switch manager.authorizationStatus {
        case .notDetermined://The user choose allow or denny your app to get the location yet
            manager.requestWhenInUseAuthorization()
            
        case .restricted://The user cannot change this app’s status, possibly due to active restrictions such as parental controls being in place.
            print("Location restricted")
            
        case .denied://The user dennied your app to get location or disabled the services location or the phone is in airplane mode
            print("Location denied")
            
        case .authorizedAlways://This authorization allows you to use all location services and receive location events whether or not your app is in use.
            print("Location authorizedAlways")
            lastKnownLocation = manager.location?.coordinate
            updateStateCity()
            
        case .authorizedWhenInUse://This authorization allows you to use all location services and receive location events only when your app is in use
            print("Location authorized when in use")
            lastKnownLocation = manager.location?.coordinate
            updateStateCity()
        @unknown default:
            print("Location service disabled")
        
        }
    }
    
    func updateStateCity(){
        // Create Location
        let location = CLLocation(latitude: lastKnownLocation?.latitude ?? 0.0, longitude:  lastKnownLocation?.longitude ?? 0.0)
        
        // Geocode Location
        var geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let placemarks = placemarks{
                
                if let location = placemarks.first?.location{
                    
                    if let addressDict = (placemarks.first?.addressDictionary as? NSDictionary){
                        print(addressDict)
                        self.timezone =  (placemarks.first as? CLPlacemark)?.timeZone?.identifier ?? ""
                        self.city = addressDict["City"] as? String ?? ""
                        self.state = addressDict["State"] as? String ?? ""
                        self.country = addressDict["Country"] as? String ?? ""
                        self.delegate?.locationAuthorizationUpdate()
                    }
                }
            }
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {//Trigged every time authorization status changes
        checkLocationAuthorization()
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.first?.coordinate
    }
}
