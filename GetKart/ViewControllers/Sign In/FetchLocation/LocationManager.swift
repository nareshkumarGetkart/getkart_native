//
//  LocationManager.swift
//  Getkart
//
//  Created by gurmukh singh on 2/18/25.
//

import Foundation
import CoreLocation
import UIKit
protocol LocationAutorizationUpdated {
    func locationAuthorizationUpdate(isToUpdateLocation:Bool)
}
final class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    static var sharedInstance = LocationManager()
    
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    var manager = CLLocationManager()
    var delegate:LocationAutorizationUpdated?
    
    var city = ""
    var state = ""
    var country = ""
    var timezone = ""
    var latitude :Double = 0.0
    var longitude :Double = 0.0
    
    var isToUpdateLocation = true
    
    
    func checkLocationAuthorization(isToUpdate:Bool = true) {
        
        isToUpdateLocation = isToUpdate
        manager.delegate = self
        manager.startUpdatingLocation()
        
        switch manager.authorizationStatus {
        case .notDetermined://The user choose allow or denny your app to get the location yet
            manager.requestWhenInUseAuthorization()
            
        case .restricted://The user cannot change this app’s status, possibly due to active restrictions such as parental controls being in place.
            print("Location restricted")
            showLocationSettingsAlert()

            
        case .denied://The user dennied your app to get location or disabled the services location or the phone is in airplane mode
            print("Location denied")
            showLocationSettingsAlert()

        case .authorizedAlways://This authorization allows you to use all location services and receive location events whether or not your app is in use.
            print("Location authorizedAlways")
            lastKnownLocation = manager.location?.coordinate
            updateStateCity(isToUpdate: isToUpdate)
            
        case .authorizedWhenInUse://This authorization allows you to use all location services and receive location events only when your app is in use
            print("Location authorized when in use")
            lastKnownLocation = manager.location?.coordinate
            updateStateCity(isToUpdate: isToUpdate)
        @unknown default:
            print("Location service disabled")
        
        }
    }
    
    func checkForLocationAccess()->Bool {
        
        manager.delegate = self
        manager.startUpdatingLocation()
        
        switch manager.authorizationStatus {
        case .notDetermined://The user choose allow or denny your app to get the location yet
            return false
            
        case .restricted://The user cannot change this app’s status, possibly due to active restrictions such as parental controls being in place.
            print("Location restricted")
            showLocationSettingsAlert()
            return false
            
        case .denied://The user dennied your app to get location or disabled the services location or the phone is in airplane mode
            print("Location denied")
            showLocationSettingsAlert()
            return false
            
        case .authorizedAlways://This authorization allows you to use all location services and receive location events whether or not your app is in use.
            print("Location authorizedAlways")
            return true
            
        case .authorizedWhenInUse://This authorization allows you to use all location services and receive location events only when your app is in use
            print("Location authorized when in use")
            return true
        @unknown default:
            print("Location service disabled")
            return false
        
        }
    }
    
    
    
    func showLocationSettingsAlert() {
        
        AlertView.sharedManager.presentAlertWith(title: "Location Access Needed", msg: "Please enable location access in Settings to continue.", buttonTitles: ["Cancel","Settings"], onController: (AppDelegate.sharedInstance.navigationController?.topViewController)!) { title, index in
            if index == 1{
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings)
                }
            }
        }
       
    }
    
    func updateStateCity(isToUpdate:Bool=true){
        // Create Location
        let location = CLLocation(latitude: lastKnownLocation?.latitude ?? 0.0, longitude:  lastKnownLocation?.longitude ?? 0.0)
        
        // Geocode Location
        var geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
          
             if let error = error {
                   print("❌ Reverse geocode failed: \(error.localizedDescription)")
                   if let cle = error as? CLError {
                       print("CLError code: \(cle.code.rawValue)")
                   }
                  // return
               }
            
            if let placemarks = placemarks{
                
                if let location = placemarks.first?.location{
                    
                    if let addressDict = (placemarks.first?.addressDictionary as? NSDictionary){
                        print(addressDict)
                        self.timezone =  (placemarks.first as? CLPlacemark)?.timeZone?.identifier ?? ""
                        self.city = addressDict["City"] as? String ?? ""
                        self.state = addressDict["State"] as? String ?? ""
                        self.country = addressDict["Country"] as? String ?? ""
                        self.latitude = location.coordinate.latitude
                        self.longitude = location.coordinate.longitude
                        //Local.shared.saveUserLocation(city: self.city, state: self.state, country: self.country, timezone: self.timezone)
                        self.delegate?.locationAuthorizationUpdate(isToUpdateLocation: isToUpdate)
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
    

    func isCurrentLocationEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled() &&
            (CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
             CLLocationManager.authorizationStatus() == .authorizedAlways)
    }

}
