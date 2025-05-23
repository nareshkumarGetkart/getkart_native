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
    
    @StateObject var viewModel = ConfirmLocationViewModel()

    @State var latitiude = 0.0
    @State var longitude = 0.0
    @State var isfirst = true

    @State var imgData:Data?
    @State var imgName = ""
    @State var gallery_images:Array<Data> = []
    @State var gallery_imageNames:Array<String> = []
     var navigationController: UINavigationController?
    @State var popType:PopType?
    @State var params:Dictionary<String,Any> = [:]
    var onAppeared: (() -> Void)?

//    @State var mapRegion = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
//        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//    )
    
  //  @State var locationInfo = ""
   // @State  var selectedCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    @State  var range1: Double = 0.0
   // @State var circle = MKCircle(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), radius: 1000.0 as CLLocationDistance)
    
    var body: some View {
            
            HStack{
                Button {
                    self.navigationController?.popViewController(animated: true)
                } label: {
                    Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
                }.frame(width: 40,height: 40)
                
                Text("Confirm Location")
                    .font(Font.manrope(.bold, size: 20.0))
                    .foregroundColor(.black)
                Spacer()
            }.frame(height:44).background(Color.white)
            .onAppear{
                if isfirst{
                    isfirst = false
                    
                    if latitiude != 0{
                        viewModel.mapRegion = MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: latitiude, longitude: longitude),
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                        
                        viewModel.selectedCoordinate = CLLocationCoordinate2D(latitude: latitiude, longitude: longitude)
                        
                        viewModel.circle = MKCircle(center: CLLocationCoordinate2D(latitude: latitiude, longitude: longitude), radius: 0.0 as CLLocationDistance)
                        self.updateStateCity1(for: viewModel.selectedCoordinate)
                    }

                }
                
                // Ensure it's not called multiple times
                               DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                   onAppeared?()
                               }
            }
            
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
                        
            if viewModel.selectedCoordinate.latitude != 0.0 {
                                
                TapMapView1(coordinate: $viewModel.selectedCoordinate, mapRegion: $viewModel.mapRegion,locationInfo: $viewModel.locationInfo, range:$range1, circle: $viewModel.circle,delegate: self)
            }else {
                TapMapView1(coordinate: $viewModel.selectedCoordinate, mapRegion: $viewModel.mapRegion,locationInfo: $viewModel.locationInfo, range:$range1, circle: $viewModel.circle,delegate: self)
            }
            HStack{
                Image(systemName: "location")
                Text("\(viewModel.locationInfo)")
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
            
            
        }.navigationBarHidden(true)
            .onAppear{
                
                if latitiude == 0{
                    LocationManager.sharedInstance.delegate = self
                    LocationManager.sharedInstance.checkLocationAuthorization()
                }
                
            }
        
    }
    
    
    func updateStateCity1(for coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else { return }
            DispatchQueue.main.async {
                let city = placemark.locality ?? ""
                let state = placemark.administrativeArea ?? ""
                let country = placemark.country ?? ""
                self.savePostLocation(latitude:"\(coordinate.latitude)", longitude: "\(coordinate.longitude)", city: city, state: state, country: country)
            }
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
         
        /* if viewModel.selectedCoordinate.latitude == 0{
             
             let latitude = LocationManager.sharedInstance.latitude
             let longitude = LocationManager.sharedInstance.longitude
             let state = LocationManager.sharedInstance.state
             let country = LocationManager.sharedInstance.country
             let city = LocationManager.sharedInstance.city
             
             self.params[AddKeys.address.rawValue] = city + ", " + state + ", " + country
             self.params[AddKeys.latitude.rawValue] = latitude
             self.params[AddKeys.longitude.rawValue] = longitude
             self.params[AddKeys.country.rawValue] = country
             self.params[AddKeys.city.rawValue] = city
             self.params[AddKeys.state.rawValue] = state

             self.uploadFIleToServer()
             
           //  self.savePostLocation(latitude: "\(LocationManager.sharedInstance.latitude)", longitude: "\(LocationManager.sharedInstance.longitude)", city: LocationManager.sharedInstance.city, state: LocationManager.sharedInstance.state, country: LocationManager.sharedInstance.country)
             
         }else*/
         if viewModel.selectedCoordinate.latitude != 0 {
             
            self.uploadFIleToServer()
          //  self.savePostLocation(latitude: "\(LocationManager.sharedInstance.latitude)", longitude: "\(LocationManager.sharedInstance.longitude)", city: LocationManager.sharedInstance.city, state: LocationManager.sharedInstance.state, country: LocationManager.sharedInstance.country)
         }else{
             AlertView.sharedManager.showToast(message: "Please enable location  or select location manually.")
         }
    }
           
    
    
    
   
    
     func savePostLocation(latitude:String, longitude:String,  city:String, state:String, country:String) {
        
            
         
             self.params[AddKeys.address.rawValue] = city + ", " + state + ", " + country
             self.params[AddKeys.latitude.rawValue] = latitude
             self.params[AddKeys.longitude.rawValue] = longitude
             self.params[AddKeys.country.rawValue] = country
             self.params[AddKeys.city.rawValue] = city
             self.params[AddKeys.state.rawValue] = state
         
         DispatchQueue.main.async {
               self.viewModel.updateLocation(latitude: latitude, longitude: longitude, city: city, state: state, country: country)
           }
         
        /* if viewModel.selectedCoordinate.latitude != Double(latitude) {
             viewModel.selectedCoordinate.latitude = Double(latitude) ?? 0.0
             self.selectedCoordinate.longitude = Double(longitude) ?? 0.0
             self.mapRegion.center = self.selectedCoordinate
             self.circle  = MKCircle(center: self.selectedCoordinate, radius: range1)
             self.locationInfo = city + ", " + state + ", " + country
             mapRegion.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)

         }
         */
        
             // self.uploadFIleToServer()
         
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
                
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.refreshAdsScreen.rawValue), object: nil, userInfo: nil)

                
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
                    
                    if let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) {
                        do {
                            let item = try JSONDecoder().decode(SingleItemParse.self, from: jsonData)
                            if let itemObj = item.data?.first {
                                
                                if itemObj.status?.lowercased() == "draft"{
                                    DispatchQueue.main.async {
                                        
                                        let swiftView = AdNotPostedView(navigationController: self.navigationController,itemObj: itemObj,message:message)
                                        let destVC = UIHostingController(rootView: swiftView)
                                        self.navigationController?.pushViewController(destVC, animated: true)
                                    }
                                }else{
                                    AlertView.sharedManager.showToast(message: message)
                                }
                            }
                        }catch {
                            
                        }
                        
                    } else {
                        print("Something is wrong while converting dictionary to JSON data.")
                        
                    }

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
                    
                    Local.shared.saveUserLocation(city: LocationManager.sharedInstance.city, state: LocationManager.sharedInstance.state, country: LocationManager.sharedInstance.country, latitude:"\(LocationManager.sharedInstance.latitude)", longitude:"\(LocationManager.sharedInstance.longitude)", timezone: LocationManager.sharedInstance.timezone)
                }
                
                print(Local.shared.getUserCity(), Local.shared.getUserState(), Local.shared.getUserCountry(),Local.shared.getUserTimeZone())
                
                
                LocationManager.sharedInstance.delegate = nil
                /*
                viewModel.mapRegion.center =  LocationManager.sharedInstance.lastKnownLocation ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                viewModel.mapRegion.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                
                viewModel.locationInfo = Local.shared.getUserCity() + "," + Local.shared.getUserState() + "," + Local.shared.getUserCountry()
                viewModel.circle = MKCircle(center: LocationManager.sharedInstance.lastKnownLocation ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), radius: (range1) as CLLocationDistance)
                
                viewModel.selectedCoordinate = LocationManager.sharedInstance.lastKnownLocation ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                */
                let latitude = LocationManager.sharedInstance.latitude
                let longitude = LocationManager.sharedInstance.longitude
                let state = LocationManager.sharedInstance.state
                let country = LocationManager.sharedInstance.country
                let city = LocationManager.sharedInstance.city
                
                
                self.savePostLocation(latitude:"\(coordinate.latitude)", longitude: "\(coordinate.longitude)", city: city, state: state, country: country)

             
                
                
            } else {
                print("Unknown Location")
            }
        }else{
            
        }
    }
}




import SwiftUI

class ConfirmLocationHostingController: UIHostingController<ConfirmLocationCreateAdd> {
    var onDidAppear: (() -> Void)?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Ensure delegate call after view is fully shown
        DispatchQueue.main.async {
            self.onDidAppear?()
        }
    }
}
