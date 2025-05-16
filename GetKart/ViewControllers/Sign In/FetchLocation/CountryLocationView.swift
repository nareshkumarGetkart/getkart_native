//
//  CountryLocationView.swift
//  Getkart
//
//  Created by gurmukh singh on 2/18/25.
//

import SwiftUI

struct CountryLocationView: View, LocationSelectedDelegate{
    
    @State private var searchText = ""
    @Environment(\.presentationMode) var presentationMode
    @State var arrCountries:Array<CountryModel> = []
    @State var arrSearchedCountries:Array<CountryModel> = []
    @State var popType:PopType?
    var locationManager = LocationManager()
    var navigationController: UINavigationController?
    var delLocationSelected:LocationSelectedDelegate!
    @State var isFirstTime = true
    @State var strCurrentLocagtion = "Show here current location"
 
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack{
                
                Button {
                    self.navigationController?.popViewController(animated: true)
                } label: {
                    Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
                }.frame(width: 40,height: 40)
                
                Text("Location")
                    .font(Font.manrope(.bold, size: 20.0))
                    .foregroundColor(Color(UIColor.label))
                Spacer()
            }.frame(height:44).background(Color(UIColor.systemBackground))
           
            /*
            // MARK: - Search Bar
            HStack {
                HStack {
                    Image("search").resizable().frame(width: 20,height: 20).padding(.leading,10)
                    TextField("Search Country", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal, 5)
                        .frame(height: 45)

                        .onChange(of: searchText) { newValue in
                            print(newValue)
                            searchCountry(strCountry:newValue)
                        }
                    
                    if searchText.count > 0 {
                        Button("Clear") {
                            searchText = ""
                        }.padding(.horizontal).foregroundColor(.black)
                    }
                }.background(Color.white).frame(height: 45).overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                }
                
                if popType == .filter {
                    // Icon button on the right (for settings or any other action)
                    Button(action: {
                        // Action for icon button
                        var rootView = SelectLocationRangeView(navigationController: self.navigationController, popType: self.popType)
                        rootView.delLocationSelected = self
                        let vc = UIHostingController(rootView:rootView )
                        self.navigationController?.pushViewController(vc, animated: true)
                    }) {
                        Image("symbolShareLocation")
                            .foregroundColor(.gray)
                            .frame(width: 40,height:40)
                            .foregroundColor(.orange)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .padding(.leading, 8)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            */
           // Divider()
            
            // MARK: - Current Location Row
            VStack(alignment:.leading){
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
                    
                    Spacer()
                }
            Text(strCurrentLocagtion).padding(.leading,50)
                    .font(Font.manrope(.regular, size: 14))
                    .foregroundColor(Color(UIColor.label))
            }.padding(.top, 10)
        
            Divider().padding([.top,.bottom],10)
/*
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
            */
            // MARK: - List of Countries
            ScrollView{
              /*  if popType == .filter || popType == .home{
                    CountryRow(strTitle:"All Countries")
                        .frame(height: 40)//.padding(.horizontal)
                        .onTapGesture{
                            self.allCountrySelected()
                        }
                    Divider()
                }
                */
                
                /*else {
                    CountryRow(strTitle:"Choose Country")
                        .frame(height: 40)//.padding(.horizontal)
                        .onTapGesture{
                        }
                    Divider()
                }*/
                
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
        }//.background(Color(UIColor.systemGray6))
            .onAppear{
              fetchCountryListing()
                if isFirstTime == true {
                    
                    if locationManager.isCurrentLocationEnabled(){
                        findMyLocationAction()
                    }
                   // findMyLocationAction()
                }
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
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: Constant.shared.get_Countries) { (obj:CountryParse) in
            
            if obj.code == 200 {
                arrCountries = obj.data?.data ?? []

            }
        }
    }
    
    func navigateToStateListing(country:CountryModel){
        var rootView = StateLocationView(navigationController: self.navigationController, strTitle: country.name ?? "", country: country, popType: self.popType)
        rootView.delLocationSelected = self
        let vc = UIHostingController(rootView: rootView)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func allCountrySelected() {
        
        if popType == .home || popType == .signUp{
            
            Local.shared.saveUserLocation(city: "", state:  "", country: "", latitude: "",longitude: "", timezone: "")
        }
        
        for vc in self.navigationController?.viewControllers ?? [] {
          
            if popType == .buyPackage {
                
                    if let vc1 = vc as? CategoryPlanVC  {
                        delLocationSelected?.savePostLocation(latitude:"", longitude:"",  city:"", state:"", country:"")
                        self.navigationController?.popToViewController(vc1, animated: true)
                        break
                    }
                
            }else if popType == .filter {
                
                    if let vc1 = vc as? FilterVC  {
                        delLocationSelected?.savePostLocation(latitude:"", longitude: "",  city: "", state: "", country: "")
                        self.navigationController?.popToViewController(vc1, animated: true)
                        break
                    }
                
            }else  if popType == .createPost {
                
               
                if let vc1 = vc as? ConfirmLocationHostingController {
                    delLocationSelected?.savePostLocation(latitude:"", longitude: "",  city:"", state: "", country: "")
                    self.navigationController?.popToViewController(vc, animated: true)
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
                        delLocationSelected?.savePostLocation(latitude: "", longitude:"",  city:"", state: "", country: "")
                        self.navigationController?.popToViewController(vc1, animated: true)
                        break
                    }
                   
                }
            }
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
                if let vc1 = vc as? ConfirmLocationHostingController {
                    
                    delLocationSelected?.savePostLocation(latitude:"\(self.locationManager.latitude)", longitude:"\(locationManager.longitude)",  city:locationManager.city, state:locationManager.state, country:locationManager.country)
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
    
    func savePostLocation(latitude:String, longitude:String,  city:String, state:String, country:String) {
        delLocationSelected?.savePostLocation(latitude: latitude, longitude: longitude, city: city, state: state, country: country)
    }
    func savePostLocationWithRange(latitude:String, longitude:String,  city:String, state:String, country:String, range:Double = 0.0){
        delLocationSelected?.savePostLocationWithRange(latitude:latitude, longitude:longitude,  city:city, state:state, country:country, range:range)
    }
}



struct CountryRow: View {
    var strTitle: String = "India"
    var isArrowNeeded = true
    var body: some View {
        HStack {
            Text("\(strTitle)")
                .font(Font.manrope(.medium, size: 15))
            Spacer()
            if isArrowNeeded{
                Image("arrow_right").frame(width: 30,height:30)
                    .foregroundColor(.orange)
                    .background(Color(UIColor.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }

        }.padding(.horizontal,10)
       .contentShape(Rectangle())
        
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
                    
                    Local.shared.saveUserLocation(city: locationManager.city, state: locationManager.state, country: locationManager.country,latitude: "\(locationManager.latitude)", longitude: "\(locationManager.longitude)", timezone: locationManager.timezone)
                }
                    
                    print(Local.shared.getUserCity(), Local.shared.getUserState(), Local.shared.getUserCountry(),Local.shared.getUserTimeZone())
                    
                    locationManager.delegate = nil
                if isFirstTime == false {
                    self.locationSelected()
                }else {
                    self.isFirstTime = false
                    strCurrentLocagtion = locationManager.city
                    if locationManager.state.count > 0 {
                        strCurrentLocagtion =  strCurrentLocagtion.count > 0 ? strCurrentLocagtion + ", " + locationManager.state : locationManager.state
                    }
                    
                    if locationManager.country.count > 0 {
                        strCurrentLocagtion =  strCurrentLocagtion.count > 0 ? strCurrentLocagtion + ", " + locationManager.country : locationManager.country
                    }
                    
                }
                    
                    
                } else {
                    print("Unknown Location")
                }
            }
        }
    }


protocol LocationSelectedDelegate{
    func savePostLocation(latitude:String, longitude:String,  city:String, state:String, country:String)
    func savePostLocationWithRange(latitude:String, longitude:String,  city:String, state:String, country:String, range:Double)
    
}

extension LocationSelectedDelegate {
    func savePostLocation(latitude:String, longitude:String,  city:String, state:String, country:String){}
    func savePostLocationWithRange(latitude:String, longitude:String,  city:String, state:String, country:String, range:Double){}
}
