//
//  MyLocationView.swift
//  Getkart
//
//  Created by gurmukh singh on 2/18/25.
//
import SwiftUI

struct MyLocationView: View {
    var navigationController: UINavigationController?
    @StateObject private var locationManager = LocationManager()
    @State private var navigateCountryLocation = false
    var countryCode = ""
    var mobile = ""
   
    
    var body: some View {
        VStack {
            
            HStack{
                Image("myLocation")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 233, height: 223, alignment: .center)
            }.padding(.top ,30)
            HStack{
                Text("What's your location")
                    .font(Font.manrope(.semiBold, size: 20.0))
                    .padding(.horizontal)
                    .frame(height: 50, alignment: .center)
            }.padding(.top ,30)
            HStack{
                Text("Enjoy a personalize selling and buying experience by telling us your loction")
                    .font(Font.manrope(.regular, size: 20.0))
                    .foregroundColor(.gray)
                    .padding([.leading, .trailing], 20.0)
                //.frame(width: UIScreen.main.bounds.size.width - 60,  alignment: .center)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
            }.padding(.top ,10)
            
            HStack{
                Button( action: findMyLocationAction){
                    Text("Find My Location")
                        .font(Font.manrope(.regular, size: 15.0))
                        .frame(width: (UIScreen.main.bounds.size.width - 60),height: 50)
                        .padding([.leading,.trailing],10)
                }.foregroundColor(.white)
                    .background(.orange)
                    .cornerRadius(10)
                
                
                
            }.padding(.top ,30)
            HStack{
                Button( action: otherLocationAction){
                    Text("Other Location")
                        .font(Font.manrope(.regular, size: 15.0))
                        .frame(width: (UIScreen.main.bounds.size.width - 60),height: 50)
                        .padding([.leading,.trailing],10)
                }.foregroundColor(.orange)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.orange, lineWidth: 1)
                    ).clipped()
            }.padding(.top ,30)
            
            Spacer()
        }.navigationBarHidden(true)
            .onAppear {
                if Local.shared.getUserCity().count > 0 {
                    if let vc = StoryBoard.main.instantiateViewController(identifier: "HomeBaseVC") as? HomeBaseVC {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
    }
    
    
    
    func findMyLocationAction(){
        locationManager.delegate = self
        locationManager.checkLocationAuthorization()
        
        if let coordinate = locationManager.lastKnownLocation {
            // print("Latitude: \(coordinate.latitude)")
            // print("Longitude: \(coordinate.longitude)")
            //  print(Local.shared.getUserCity(), Local.shared.getUserState(), Local.shared.getUserCountry(),Local.shared.getUserTimeZone())
            locationManager.delegate = nil
            if let vc = StoryBoard.main.instantiateViewController(identifier: "HomeBaseVC") as? HomeBaseVC {
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        } else {
            print("Unknown Location")
        }
        
    }
    
    func otherLocationAction(){
        self.fetchCountryListing()
    }
    
    func fetchCountryListing(){
       ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_Countries) { (obj:CountryParse) in
            let arrCountry = obj.data?.data ?? []
           let vc = UIHostingController(rootView: CountryLocationView(arrCountries: arrCountry, popType: .signUp, navigationController: self.navigationController))
           self.navigationController?.pushViewController(vc, animated: true)
           
       }
   }
    
}

extension MyLocationView :LocationAutorizationUpdated {
    func locationAuthorizationUpdate(isToUpdateLocation:Bool) {
        if locationManager.manager.authorizationStatus == .authorizedAlways  ||  locationManager.manager.authorizationStatus == .authorizedWhenInUse {
            if let coordinate = locationManager.lastKnownLocation {
               // print("Latitude: \(coordinate.latitude)")
              //  print("Longitude: \(coordinate.longitude)")
                Local.shared.saveUserLocation(city: locationManager.city, state: locationManager.state, country: locationManager.country,latitude:"\(locationManager.latitude)" , longitude:"\(locationManager.longitude)", timezone: locationManager.timezone)
                
              //  print(Local.shared.getUserCity(), Local.shared.getUserState(), Local.shared.getUserCountry(),Local.shared.getUserTimeZone())
                
                locationManager.delegate = nil
                if let vc = StoryBoard.main.instantiateViewController(identifier: "HomeBaseVC") as? HomeBaseVC {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
                
            } else {
                print("Unknown Location")
            }
        }
    }
}



