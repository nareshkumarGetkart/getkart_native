//
//  ChooseLocationBannerView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 01/08/25.
//

import SwiftUI

struct ChooseLocationBannerView: View {
    
    var navigationController:UINavigationController?
    @State  private var searchTxt = ""
    @State private var sliderValue: Double = 15
    @State private var mapRadius: Int = 1500
    @State private var latitude: Double = 0.0
    @State private var longitude: Double = 0.0

    
    var selectedLocation: (_ lat: Double, _ long: Double, _ address: String, _ locality: String, _ radius: Int) -> Void

    var body: some View {

    HStack{
            Button {
                navigationController?.popViewController(animated: true)
                
            } label: {
                Image("Cross").renderingMode(.template).foregroundColor(Color(UIColor.label))
            }.frame(width: 40,height: 40)
        
            Text("Locations").font(.manrope(.bold, size: 20.0))
                .foregroundColor(Color(UIColor.label))
            Spacer()
            
        }.frame(height:44).background(Color(UIColor.systemBackground))
            .onAppear{
                
                if latitude == 0{
                    latitude = Double(Local.shared.getUserLatitude()) ?? 0
                    longitude = Double(Local.shared.getUserLongitude()) ?? 0
                    self.updateLocationLabel(city:  Local.shared.getUserCity(), state:  Local.shared.getUserState(), country:  Local.shared.getUserCountry())
                }
            }
        VStack{
            
            HStack{
                
                Image("search").padding(.leading)
              
                Button {
                    pushToSearchLocation()
                    
                } label: {
                    HStack{
                        TextField("Search city,area or locality", text: $searchTxt).multilineTextAlignment(.leading).foregroundColor(Color(.label)).frame(maxWidth:.infinity)
                      //  Text("Search city,area or locality").foregroundColor(Color(.gray))
                        Spacer()
                   }
                }.background(Color.clear).frame(maxWidth:.infinity)

            }.frame(height:60).background(Color(UIColor.systemBackground)).cornerRadius(8.0).padding(8.0)
            
           /* HStack{
                Image("currentLocation").padding(.leading)
                VStack(alignment:.leading){
                    Text("Use current location").font(.manrope(.semiBold, size: 15))
                    Text("New Delhi 110034").font(.manrope(.regular, size: 13))
                }
                Spacer()

            }.frame(height:60).background(Color(UIColor.systemBackground))
           */
            MapViewBanner(latitude: latitude, longitude:longitude ,address:"",radius: Int(mapRadius))
            
            VStack(alignment:.leading, spacing: 10) {
                Text("Radius").font(.manrope(.regular, size: 14))
                HStack{ Spacer()
                    Text("\(Int(sliderValue))")
                        .font(.headline)
                    Spacer()
                }
                
                Slider(value: $sliderValue, in: 1...30, step: 1).onChange(of: sliderValue) { newValue in
                    print("Slider changed to: \(newValue)")
                    // Perform your logic here
                    mapRadius = Int(newValue * 100)
                }
                .accentColor(Color(.systemOrange))
            }.padding()
            
            Button {
                selectedLocation(latitude,longitude,searchTxt,"",mapRadius/100)
                self.navigationController?.popViewController(animated: true)

            } label: {
                Text("Done").foregroundColor(.white)
            }.frame(maxWidth:.infinity,minHeight:50, maxHeight: 50)
                .background(Color(hexString: "#FF9900")).cornerRadius(8.0).padding()
            
            Spacer()
        }.background(Color(.systemGray6))
        
        
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name(NotiKeysLocSelected.bannerPromotionNewLocation.rawValue))) { notification in
                if let userInfo = notification.userInfo as? [String: Any] {
                    let latitude = userInfo["latitude"] as? String ?? ""
                    let longitude = userInfo["longitude"] as? String ?? ""
                    let city = userInfo["city"] as? String ?? ""
                    let state = userInfo["state"] as? String ?? ""
                    let country = userInfo["country"] as? String ?? ""
                    let locality = userInfo["locality"] as? String ?? ""
                    
                    // Handle the data in SwiftUI View
                    print("Location: \(city), \(state), \(country)")
                    
                    if locality.count > 0{
                        searchTxt =  locality + "," + city + ", " + state + ", " + country
                        
                    }else{
                        searchTxt = city + ", " + state + ", " + country
                        
                    }
                    self.latitude = Double(latitude) ?? 0
                    self.longitude =  Double(longitude) ?? 0
                    
                    //DispatchQueue.main.async { }
                }
            }


    }
    
    
     func pushToSearchLocation(){
         let rootView = CountryLocationView(popType: .bannerPromotionLocation, navigationController: self.navigationController)
        // rootView.delLocationSelected = self
            let vc = UIHostingController(rootView:rootView)
         self.navigationController?.pushViewController(vc, animated: true)
     }
    
    
    func updateLocationLabel(city: String, state: String, country: String) {
       
        if city.count == 0{
            
        }else{
            var locStr = city
            if !state.isEmpty { locStr += ", \(state)" }
            if !country.isEmpty { locStr += ", \(country)" }
            searchTxt = locStr.isEmpty ? "" : locStr
            
            
            if searchTxt.hasPrefix(",") {
                searchTxt = String(searchTxt.dropFirst())
            }
            
        }
    }
}

//#Preview {
//    ChooseLocationBannerView(, selectedLocation: (String, String, String, String, String) -> Void)
//}




import Foundation
import MapKit
import SwiftUI


struct MapViewBanner: UIViewRepresentable {
    
    let latitude: Double
    let longitude: Double
    let address: String
    var radius = 100
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        mapView.setRegion(region, animated: false)

        // Add 1km radius circle overlay
        let circle = MKCircle(center: location, radius: CLLocationDistance(radius))
        mapView.addOverlay(circle)
        
        // Add marker
               let annotation = MKPointAnnotation()
               annotation.coordinate = location
               annotation.title = address.isEmpty ? "Selected Location" : address
               mapView.addAnnotation(annotation)
        
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        mapView.setRegion(region, animated: true)
        
        // Remove previous overlays to avoid duplication
        mapView.removeOverlays(mapView.overlays)
        
        // Add updated circle
        let circle = MKCircle(center: location, radius: CLLocationDistance(radius))
        mapView.addOverlay(circle)
        
        
        // Add updated marker
                let annotation = MKPointAnnotation()
                annotation.coordinate = location
                annotation.title = address.isEmpty ? "" : address
                mapView.addAnnotation(annotation)
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let circleOverlay = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circleOverlay)
                renderer.fillColor = Themes.sharedInstance.themeColor.withAlphaComponent(0.2)
                renderer.strokeColor = Themes.sharedInstance.themeColor
                renderer.lineWidth = 2
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
