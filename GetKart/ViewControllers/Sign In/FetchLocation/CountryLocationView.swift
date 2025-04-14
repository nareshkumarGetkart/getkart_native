//
//  CountryLocationView.swift
//  Getkart
//
//  Created by gurmukh singh on 2/18/25.
//

import SwiftUI

struct CountryLocationView: View {
    
    @State private var searchText = ""
    @Environment(\.presentationMode) var presentationMode
    @State var arrCountries:Array<CountryModel> = []
    @State var arrSearchedCountries:Array<CountryModel> = []
    @State var popType:PopType?
    var locationManager = LocationManager()
    var navigationController: UINavigationController?

    var body: some View {
        
        VStack(spacing: 0) {
            HStack{
                
                Button {
                    self.navigationController?.popViewController(animated: true)
                } label: {
                    Image("arrow_left").renderingMode(.template).foregroundColor(.black)
                }.frame(width: 40,height: 40)
                
                Text("Location")
                    .font(Font.manrope(.bold, size: 20.0))
                    .foregroundColor(.black)
                Spacer()
            }.frame(height:44).background(Color.white)
            
            // MARK: - Search Bar
            HStack {
                HStack {
                    Image("search").resizable().frame(width: 20,height: 20)
                    TextField("Search Country", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal, 8)
                        .frame(height: 36)
                    //.background(Color(.systemGray6))
                    //.cornerRadius(8)
                        .onChange(of: searchText) { newValue in
                            print(newValue)
                            searchCountry(strCountry:newValue)
                        }
                    
                    if searchText.count > 0 {
                        Button("Clear") {
                            searchText = ""
                        }.foregroundColor(.black)
                    }
                }.background(Color.white).padding().frame(height: 45).overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                }
                // Icon button on the right (for settings or any other action)
                Button(action: {
                    // Action for icon button
                    
                }) {
                    Image("symbolShareLocation")
                        .foregroundColor(.gray)
                        .frame(width: 40,height:40)
                            .foregroundColor(.orange)
                            .background(Color(UIColor.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        .padding(.leading, 8)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
            
            // MARK: - Current Location Row
            HStack {
                
                Button(action: {
                    // Enable location action
                    findMyLocationAction()
                }) {
                    Image("currentLocation")
                        .foregroundColor(.orange)
                    Text("Use Current Location")
                        .font(Font.manrope(.medium, size: 15))
                        .foregroundColor(.orange)
                }.padding(.leading, 20)
                    .padding(.top, 5)
                Spacer()
                
                
            }.padding(.top, 8)
            if self.locationManager.checkForLocationAccess() == false {
                HStack {
                    Button(action: {
                        // Enable location action
                    }) {
                        Text("Enable Location")
                            .font(Font.manrope(.medium, size: 15))
                            .foregroundColor(.black)
                    }.padding(.leading, 20)
                        .padding(.top, 5)
                    
                    
                    Spacer()
                }
                .padding()
                
                Divider()
            }
            
            // MARK: - List of Countries
            ScrollView{
                if searchText.count == 0 {
                    ForEach(arrCountries) { country in
                        CountryRow(strTitle:country.name ?? "")
                            .frame(height: 40)//.padding(.horizontal)
                            .onTapGesture{
                                self.navigateToStateListing(country: country)
                            }
                        Divider()
                    }
                    
                }else {
                    ForEach(arrSearchedCountries) { country in
                        CountryRow(strTitle:country.name ?? "")
                            .frame(height: 40)//.padding(.horizontal)
                            .onTapGesture{
                                
                                self.navigateToStateListing(country: country)
                            }
                        Divider()
                    }
                }
            }
            
            Spacer()
        }.onAppear{
            fetchCountryListing()
        }
        .navigationTitle("Location")
        .navigationBarBackButtonHidden()
        .navigationBarHidden(true)
    }
    
    func findMyLocationAction(){
        
        locationManager.delegate = self
        locationManager.checkLocationAuthorization()
        
        /*if let coordinate = locationManager.lastKnownLocation {
            print("Latitude: \(coordinate.latitude)")
            print("Longitude: \(coordinate.longitude)")
            print(Local.shared.getUserCity(), Local.shared.getUserState(), Local.shared.getUserCountry(),Local.shared.getUserTimeZone())
            
            locationManager.delegate = nil
            self.locationSelected()
            
            
        } else {
            print("Unknown Location")
        }*/
        
    }
    
    func searchCountry(strCountry:String){
        arrSearchedCountries.removeAll()
        for country in arrCountries {
            let countryName = country.name ?? ""
            if let range = countryName.range(of: strCountry, options:.caseInsensitive) {
                print(range)
                arrSearchedCountries.append(country)
            }
        }
        
    }
    
     func fetchCountryListing(){
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: Constant.shared.get_Countries) { (obj:CountryParse) in
            arrCountries = obj.data?.data ?? []
        }
    }
    
    func navigateToStateListing(country:CountryModel){
       
        let vc = UIHostingController(rootView: StateLocationView(navigationController: self.navigationController, strTitle: country.name ?? "", country: country, popType: self.popType))
           self.navigationController?.pushViewController(vc, animated: true)
           
       
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



struct CountryRow: View {
    var strTitle: String = "India"
    var body: some View {
        HStack {
            Text("\(strTitle)")
                .font(Font.manrope(.medium, size: 15))
            Spacer()
            Image("arrow_right").frame(width: 30,height:30)
                .foregroundColor(.orange)
                .background(Color(UIColor.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 6))

        }.padding(.horizontal,10)
        
    }
}

//#Preview {
//    CountryRow()
//}
//

extension CountryLocationView :LocationAutorizationUpdated {
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
                    self.locationSelected()
                    
                    
                } else {
                    print("Unknown Location")
                }
            }
        }
    }

