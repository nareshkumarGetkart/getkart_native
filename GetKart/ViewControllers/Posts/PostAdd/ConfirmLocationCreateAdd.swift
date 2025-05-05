//
//  ConfirmLocationCreateAdd.swift
//  GetKart
//
//  Created by gurmukh singh on 4/17/25.
//

import Foundation
import SwiftUI
import MapKit

struct ConfirmLocationCreateAdd: View, LocationSelectedDelegate {
    
    
    @State var imgData:Data?
    @State var imgName = ""
    @State var gallery_images:Array<Data> = []
    @State var gallery_imageNames:Array<String> = []
     var navigationController: UINavigationController?
    @State var popType:PopType?
    @State var params:Dictionary<String,Any> = [:]
    
    
    
    
    @State var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @State var locationInfo = ""
    @State  var selectedCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    @State  var range1: Double = 0.0
    @State var circle = MKCircle(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), radius: 1000.0 as CLLocationDistance)
    
    var body: some View {
            
            HStack{
                Button {
                    self.navigationController?.popViewController(animated: true)
                } label: {
                    Image("arrow_left").renderingMode(.template).foregroundColor(.black)
                }.frame(width: 40,height: 40)
                
                Text("Confirm Location")
                    .font(Font.manrope(.bold, size: 20.0))
                    .foregroundColor(.black)
                Spacer()
            }.frame(height:44).background(Color.white)
            
        VStack(spacing: 10) {
            Text("What is the location of the item you are selling?")
                            .font(.system(size: 18, weight: .medium))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                
            Button(action: {
                            // Change location action
                self.fetchCountryListing()
                        }) {
                            Text("Somewhere else")
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .padding(.horizontal)
                        }
                        
            if selectedCoordinate.latitude != 0.0 {
                TapMapView(coordinate: $selectedCoordinate, mapRegion: $mapRegion,locationInfo: $locationInfo, range:$range1, circle: $circle)
            }else {
                TapMapView(coordinate: $selectedCoordinate, mapRegion: $mapRegion,locationInfo: $locationInfo, range:$range1, circle: $circle)
            }
            HStack{
                Image(systemName: "location")
                Text("\(locationInfo)")
                Spacer()
            }.frame(height: 50)
            
            Button(action: {
             postNowAction()
            }) {
                Text(popType == .createPost ? "Post Now" : "Update")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            
            
        }.navigationBarHidden(true).onAppear{
            
            LocationManager.sharedInstance.delegate = self
            LocationManager.sharedInstance.checkLocationAuthorization()
        }
        
    }
    
    func fetchCountryListing(){
       ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_Countries) { (obj:CountryParse) in
            let arrCountry = obj.data?.data ?? []
           var rootView = CountryLocationView(arrCountries: arrCountry, popType: .createPost, navigationController: self.navigationController)
           rootView.delLocationSelected = self
           let vc = UIHostingController(rootView:rootView)
           self.navigationController?.pushViewController(vc, animated: true)
           
       }
   }
    
     func postNowAction(){
        if selectedCoordinate.latitude != 0 {
            self.savePostLocation(latitude: "\(LocationManager.sharedInstance.latitude)", longitude: "\(LocationManager.sharedInstance.longitude)", city: LocationManager.sharedInstance.city, state: LocationManager.sharedInstance.state, country: LocationManager.sharedInstance.country)
        }
        
    }
           
    
   
    
     func savePostLocation(latitude:String, longitude:String,  city:String, state:String, country:String) {
        
             self.params[AddKeys.address.rawValue] = city + ", " + state + ", " + country
             self.params[AddKeys.latitude.rawValue] = latitude
             self.params[AddKeys.longitude.rawValue] = longitude
             self.params[AddKeys.country.rawValue] = country
             self.params[AddKeys.city.rawValue] = city
             self.params[AddKeys.state.rawValue] = state
         
//         if self.selectedCoordinate.latitude != Double(latitude) {
//             self.selectedCoordinate.latitude = Double(latitude) ?? 0.0
//             self.selectedCoordinate.longitude = Double(longitude) ?? 0.0
//             self.mapRegion.center = self.selectedCoordinate
//             self.circle  = MKCircle(center: self.selectedCoordinate, radius: range1)
//         }
              self.uploadFIleToServer()
         
    }
    
    func uploadFIleToServer(){
        
        var url = Constant.shared.add_itemURL
       
        if popType == .editPost {
            url = Constant.shared.update_itemURL
        }
        
        URLhandler.sharedinstance.uploadImageArrayWithParameters(imageData: imgData ?? Data(), imageName: imgName, imagesData: gallery_images, imageNames: gallery_imageNames, url: url, params: self.params, completionHandler: { responseObject, error in

            if error == nil {
                let result = responseObject! as NSDictionary
                let code = result["code"] as? Int ?? 0
                let message = result["message"] as? String ?? ""
                
                
                if code == 200{
                    
                    if let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) {
                        do {
                            let item = try JSONDecoder().decode(SingleItemParse.self, from: jsonData)
                            if let itemObj = item.data?.first {
                                let vc = UIHostingController(rootView: AddPostSuccessView( navigationController: self.navigationController, itemObj: itemObj ))
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        }catch {
                            
                        }
                        
                    } else {
                        print("Something is wrong while converting dictionary to JSON data.")
                        
                    }
                    
                    
                    
                }else{
                    //self?.delegate?.showError(message: message)
                }
            }
        })
    }
    
}


#Preview {
    ConfirmLocationCreateAdd()
}


extension ConfirmLocationCreateAdd :LocationAutorizationUpdated {
    func locationAuthorizationUpdate() {
        if LocationManager.sharedInstance.manager.authorizationStatus == .authorizedAlways  ||  LocationManager.sharedInstance.manager.authorizationStatus == .authorizedWhenInUse {
            if let coordinate = LocationManager.sharedInstance.lastKnownLocation {
                print("Latitude: \(coordinate.latitude)")
                print("Longitude: \(coordinate.longitude)")
                
                if popType == .home || popType == .signUp{
                    
                    Local.shared.saveUserLocation(city: LocationManager.sharedInstance.city, state: LocationManager.sharedInstance.state, country: LocationManager.sharedInstance.country, timezone: LocationManager.sharedInstance.timezone)
                }
                
                print(Local.shared.getUserCity(), Local.shared.getUserState(), Local.shared.getUserCountry(),Local.shared.getUserTimeZone())
                
                LocationManager.sharedInstance.delegate = nil
                
                mapRegion.center =  LocationManager.sharedInstance.lastKnownLocation ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                mapRegion.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                
                locationInfo = Local.shared.getUserCity() + "," + Local.shared.getUserState() + "," + Local.shared.getUserCountry()
                circle = MKCircle(center: LocationManager.sharedInstance.lastKnownLocation ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), radius: (range1) as CLLocationDistance)
                
                selectedCoordinate = LocationManager.sharedInstance.lastKnownLocation ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                
                
            } else {
                print("Unknown Location")
            }
        }
    }
}
