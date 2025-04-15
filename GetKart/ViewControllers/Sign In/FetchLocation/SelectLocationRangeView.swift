//
//  SelectLocationRangeView.swift
//  GetKart
//
//  Created by gurmukh singh on 4/11/25.
//

import SwiftUI
import MapKit

struct SelectLocationRangeView: View {
    var navigationController: UINavigationController?
    // @State var mapRegion = MKCoordinateRegion()
    
    @State var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State  var locationManager = LocationManager()
    @State var popType:PopType?
    
    
    
    @State var locationInfo = ""
    @State private var selectedCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    @State private var range: Double = 1.0
    @State private var range1: Double = 1000.0
    @State var circle = MKCircle(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), radius: 1000.0 as CLLocationDistance)
    var body: some View {
        HStack{
            
            Button {
                self.navigationController?.popViewController(animated: true)
            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(.black)
            }.frame(width: 40,height: 40)
            
            Text(" Select Location").font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(.black)
            
            Spacer()
        }.frame(height:44).background(Color.white)
        
        
        VStack(spacing: 0) {
           
            ZStack {
                
                HStack{
                    
                    if selectedCoordinate.latitude != 0.0 {
                        TapMapView(coordinate: $selectedCoordinate, mapRegion: $mapRegion,locationInfo: $locationInfo, range:$range1, circle: $circle)
                    } else {
                        TapMapView(coordinate: $selectedCoordinate, mapRegion: $mapRegion,locationInfo: $locationInfo, range:$range1, circle: $circle)
                    }
                    
                }
                
                
                
                // Location Info
                VStack {
                    HStack {
                        Label("\(locationInfo)", systemImage: "mappin.circle.fill")
                            .font(.subheadline)
                            .padding(10)
                        
                        Spacer()
                    }
                    .frame(minHeight: 50)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
                    Spacer()
                }
            }.background(.red)
                .frame(height: heightScreen-250)
            
            // Range slider
            VStack(alignment: .leading, spacing: 8) {
                Text("Select area range")
                    .font(.subheadline)
                
                Slider(value: $range, in: 1...100, step: 1){ editing in
                    print("+++++",editing)
                    if editing == false {
                       // circle = MKCircle(center: selectedCoordinate, radius: (range * 1000) as CLLocationDistance)
                        //selectedCoordinate = selectedCoordinate
                        range1 = range * 1000
                    }
                }
                
                HStack {
                    Text("1 Km")
                    Spacer()
                    Text("\(Int(range)) Km")
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            .padding([.horizontal, .vertical])
            
            // Buttons
            HStack(spacing: 16) {
                Button("Reset") {
                    mapRegion.center = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                    locationInfo = ""
                    selectedCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                    range = 1.0
                    range1 = 1000.0
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.orange)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange))
                
                Button("Apply") {
                    // Do something with selectedCoordinate & range
                    locationSelected()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(Color.orange)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
        }.onAppear{
            
            locationManager.delegate = self
            locationManager.checkLocationAuthorization()
        }
    }
    
 
    
    func locationSelected() {
                
        for vc in self.navigationController?.viewControllers ?? [] {
          
            if popType == .buyPackage {
                
                    if let vc1 = vc as? CategoryPlanVC  {
                        vc1.savePostLocation(latitude:"\(self.locationManager.latitude)", longitude:"\(locationManager.longitude)",  city:locationManager.city ?? "", state:locationManager.state ?? "", country:locationManager.country)
                        self.navigationController?.popToViewController(vc1, animated: true)
                        break
                    }
                
            }else if popType == .filter {
                
                    if let vc1 = vc as? FilterVC  {
                        vc1.savePostLocation(latitude:"\(self.locationManager.latitude)", longitude:"\(locationManager.longitude)",  city:locationManager.city, state:locationManager.state, country:locationManager.country)
                        self.navigationController?.popToViewController(vc1, animated: true)
                        break
                    }
                
            }else  if popType == .createPost {
                
               
                    if let vc1 = vc as? CreateAddVC2 {
                        vc1.savePostLocation(latitude:"\(self.locationManager.latitude)", longitude:"\(locationManager.longitude)",  city:locationManager.city, state:locationManager.state, country:locationManager.country)
                        self.navigationController?.popToViewController(vc1, animated: true)
                        break
                    }
                
            }else if popType == .signUp {
                
                if vc.isKind(of: UIHostingController<MyLocationView>.self) == true{
                  
                    self.navigationController?.popToViewController(vc, animated: true)
                    break
                }
            } else  if popType == .home {
                
                if vc.isKind(of: HomeVC.self) == true {
                    if let vc1 = vc as? HomeVC {
                        vc1.savePostLocation(latitude:"\(locationManager.latitude)", longitude:"\(locationManager.longitude)",  city:locationManager.city, state:locationManager.state, country:locationManager.country)
                        
                        self.navigationController?.popToViewController(vc1, animated: true)
                        break
                    }
                   
                }
            }
        }
    }
    
    
}


extension SelectLocationRangeView :LocationAutorizationUpdated {
    func locationAuthorizationUpdate() {
        if locationManager.manager.authorizationStatus == .authorizedAlways  ||  locationManager.manager.authorizationStatus == .authorizedWhenInUse {
            if let coordinate = locationManager.lastKnownLocation {
                print("Latitude: \(coordinate.latitude)")
                print("Longitude: \(coordinate.longitude)")
                
                if popType == .home || popType == .signUp{
                    
                    Local.shared.saveUserLocation(city: locationManager.city, state: locationManager.state, country: locationManager.country, timezone: locationManager.timezone)
                }
                
                print(Local.shared.getUserCity(), Local.shared.getUserState(), Local.shared.getUserCountry(),Local.shared.getUserTimeZone())
                
                locationManager.delegate = nil
                
                mapRegion.center =  locationManager.lastKnownLocation ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                mapRegion.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                
                locationInfo = Local.shared.getUserCity() + "," + Local.shared.getUserState() + "," + Local.shared.getUserCountry()
                circle = MKCircle(center: locationManager.lastKnownLocation ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), radius: (range1) as CLLocationDistance)
                
                selectedCoordinate = locationManager.lastKnownLocation ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                
                
            } else {
                print("Unknown Location")
            }
        }
    }
}

#Preview {
    SelectLocationRangeView()
}






struct TapMapView: UIViewRepresentable {
    @Binding var coordinate: CLLocationCoordinate2D
    @Binding var mapRegion: MKCoordinateRegion
    @Binding var locationInfo:String
    @Binding var range: Double
    var annotation = MKPointAnnotation()
    
    @Binding var circle:  MKCircle
    let mapView = MKMapView()
    func makeUIView(context: Context) -> MKMapView {
       
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.mapTapped(_:)))
        mapView.addGestureRecognizer(tapGesture)
        mapView.delegate = context.coordinator
        mapView.region = mapRegion
        
        annotation.coordinate = mapRegion.center
        mapView.addAnnotation(annotation)
        
        if coordinate.latitude != 0.0 {
            self.updateStateCity()
            mapView.removeOverlay(circle)
            mapView.addOverlay(circle)
        }
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // You can update region or annotations here if needed
        
       
        /*if coordinate.latitude != 0.0 {
            mapView.removeOverlay(circle)
            circle = MKCircle(center: coordinate, radius: (range) as CLLocationDistance )
            mapView.addOverlay(circle)

        }*/
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: TapMapView
        
        init(_ parent: TapMapView) {
            self.parent = parent
        }
        
        @objc func mapTapped(_ sender: UITapGestureRecognizer) {
            let mapView = sender.view as! MKMapView
            let point = sender.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            
            parent.coordinate = coordinate
            parent.annotation.coordinate = coordinate
            parent.mapRegion.center = coordinate
            
            mapView.addAnnotation(parent.annotation)
            mapView.delegate = self
            
            
            self.parent.mapView.removeOverlay(self.parent.circle)
            self.parent.circle = MKCircle(center: coordinate, radius: (self.parent.range) as CLLocationDistance)
            self.parent.mapView.addOverlay(self.parent.circle)
            
            
            parent.updateStateCity()
            
        }
        
       
        func mapView(_ mapView: MKMapView!, rendererFor overlay: MKOverlay!) -> MKOverlayRenderer! {
                if overlay is MKCircle {
                    var circle = MKCircleRenderer(overlay: overlay)
                    circle.strokeColor = UIColor.red
                    circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
                    circle.lineWidth = 1
                    return circle
                } else {
                    return nil
                }
            }
        
    }
    
    
    func updateStateCity(){
        // Create Location
        let location = CLLocation(latitude: coordinate.latitude, longitude:  coordinate.longitude)
        
        // Geocode Location
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let placemarks = placemarks{
                
                if let location = placemarks.first?.location{
                    
                    if let addressDict = (placemarks.first?.addressDictionary as? NSDictionary){
                        print(addressDict)
                        //self.locationManager.timezone =  (placemarks.first as? CLPlacemark)?.timeZone?.identifier ?? ""
                        let city = addressDict["City"] as? String ?? ""
                        let state = addressDict["State"] as? String ?? ""
                        let country = addressDict["Country"] as? String ?? ""
                        
                        locationInfo = city + "," + state + "," + country
                    }
                }
            }
        }
    }
}

