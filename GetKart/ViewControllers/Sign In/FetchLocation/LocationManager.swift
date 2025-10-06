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
    var locality = ""

    var isToUpdateLocation = true
    
    
    func checkLocationAuthorization(isToUpdate:Bool = true) {
        
        isToUpdateLocation = isToUpdate
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
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
        let location = CLLocation(latitude: lastKnownLocation?.latitude.rounded(toPlaces: 6) ?? 0.0, longitude:  lastKnownLocation?.longitude.rounded(toPlaces: 6) ?? 0.0)
        
        // Geocode Location
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { [self] (placemarks, error) in
            
            if let error = error {
                print("❌ Reverse geocode failed: \(error.localizedDescription)")
                if let cle = error as? CLError {
                    print("CLError code: \(cle.code.rawValue)")
                }
                self.getAddressFromLatLongApi(lat: location.coordinate.latitude, lng: location.coordinate.longitude, isToUpdate: isToUpdate)
              //  return
            }else{
            
            
            
            if let placemarks = placemarks{
                
                if let location = placemarks.first?.location{
                    
                    if let addressDict = (placemarks.first?.addressDictionary as? NSDictionary){
                        print(addressDict)
                        self.timezone =  (placemarks.first as? CLPlacemark)?.timeZone?.identifier ?? ""
                        self.city = addressDict["City"] as? String ?? ""
                        self.state = addressDict["State"] as? String ?? ""
                        self.country = addressDict["Country"] as? String ?? ""
                        self.latitude = location.coordinate.latitude.rounded(toPlaces: 6)
                        self.longitude = location.coordinate.longitude.rounded(toPlaces: 6)
                        self.locality = addressDict["SubLocality"] as? String ?? ""
                        
                        //Local.shared.saveUserLocation(city: self.city, state: self.state, country: self.country, timezone: self.timezone)
                        self.delegate?.locationAuthorizationUpdate(isToUpdateLocation: isToUpdate)
                    }
                }
            }
        }
        }
    }
    
    
    func getAddressFromLatLongApi(lat: Double, lng: Double,isToUpdate:Bool) {
       // type :  1=> retrive lat long , 2=>retrive address
        let params = ["lat":lat,"lng":lng,"type":1]
        
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.fetch_google_location, param: params, methodType: .post,showLoader: true) { responseObject, error in
            
            if error == nil {
                if let result = responseObject as? [String: Any],
                   let data = result["data"] as? [String: Any],
                   let results = data["results"] as? [[String: Any]],
                   let first = results.first,
                   let addressComponents = first["address_components"] as? [[String: Any]] {
                    
                    var country = ""
                    var state = ""
                    var city = ""
                    var area = ""
                    
                    for component in addressComponents {
                        guard let longName = component["long_name"] as? String,
                              let types = component["types"] as? [String] else { continue }
                        
                        if types.contains("country") {
                            country = longName
                        } else if types.contains("administrative_area_level_1") {
                            state = longName
                        } else if types.contains("locality") {
                            city = longName
                        } else if types.contains("sublocality_level_1") || types.contains("sublocality_level_2") {
                            area = longName
                        }
                    }
                    
                    print("🌍 Country: \(country)")
                    print("🗾 State: \(state)")
                    print("🏙️ City: \(city)")
                    print("📍 Area: \(area)")
                    
                    
               
                    
                    // Example: Store or use in UI
                    DispatchQueue.main.async {
                        // update your SwiftUI or UIKit state here
                        self.city = city
                        self.state = state
                        self.country = country
                        self.latitude = lat
                        self.longitude = lng
                        self.locality = area
                        self.delegate?.locationAuthorizationUpdate(isToUpdateLocation: isToUpdate)

                    }
                }
            }
        }

     
     
    }
    
//    func fetchAddressFromGoogle(lat: Double, lng: Double,isToUpdate:Bool) {
//        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(lat),\(lng)&key=\(geoCodingKey)"
//        
//        guard let url = URL(string: urlString) else { return }
//        print(urlString)
//        URLSession.shared.dataTask(with: url) { data, _, error in
//           
//            
//              if let error = error {
//                    print("❌ Network Error: \(error.localizedDescription)")
//                    return
//                }
//            
//            
//            
//            guard let data = data else { return }
//            
//            do {
//                
//                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
//                    // Check status
//                    if let status = json["status"] as? String {
//                        if status != "OK" {
//                            let message = json["error_message"] as? String ?? "No error_message"
//                            print("⚠️ Geocoding API Error - Status: \(status), Message: \(message)")
//                            return
//                        }
//                    }
//                    
//                    if
//                       let results = json["results"] as? [[String: Any]],
//                       let firstResult = results.first,
//                       let components = firstResult["address_components"] as? [[String: Any]] {
//                        
//                      
//                        var city = "", state = "", country = "", locality = "", postalCode = ""
//                        
//                        for comp in components {
//                            if let types = comp["types"] as? [String], let name = comp["long_name"] as? String {
//                                if types.contains("locality") {
//                                    city = name
//                                } else if types.contains("administrative_area_level_1") {
//                                    state = name
//                                } else if types.contains("country") {
//                                    country = name
//                                } else if types.contains("sublocality") || types.contains("sublocality_level_1") {
//                                    locality = name
//                                } else if types.contains("postal_code") {
//                                    postalCode = name
//                                }
//                            }
//                        }
//                        
//                        
//                        
//                        self.city = city
//                        self.state = state
//                        self.country = country
//                        self.latitude = lat
//                        self.longitude = lng
//                        self.locality = locality
//                        
//                        self.delegate?.locationAuthorizationUpdate(isToUpdateLocation: isToUpdate)
//                        
//                        print("🌆 City: \(city)")
//                        print("📌 Locality/Area: \(locality)")
//                        print("🗺️ State: \(state)")
//                        print("🔢 Postal Code: \(postalCode)")
//                        print("🌍 Country: \(country)")
//                    }
//                }
//            }
//                catch {
//                print("❌ JSON Error: \(error.localizedDescription)")
//            }
//        }.resume()
//    }

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


extension Double {
    func roundedDecimal(toPlaces places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (self * factor).rounded() / factor
    }
}
