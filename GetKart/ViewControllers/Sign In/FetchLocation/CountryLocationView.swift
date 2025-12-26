//
//  CountryLocationView.swift
//  Getkart
//
//  Created by gurmukh singh on 2/18/25.
//

import SwiftUI

struct CountryLocationView: View, LocationSelectedDelegate{
    
    @State private var searchText = ""
    @State var arrCountries:Array<CountryModel> = []
    @State var arrSearchedCountries:Array<CountryModel> = []
    @State var popType:PopType?
    @State var isFirstTime = true
    @State var strCurrentLocagtion = "Fetch current location"
    @State private var showSearch:Bool = false
    @State private var showAlert = false
    var locationManager = LocationManager()
    var navigationController: UINavigationController?
    var delLocationSelected:LocationSelectedDelegate!
    
   private let recentLocationArray = RecentLocationManager.shared.fetch()

    var body: some View {
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
        
        VStack(spacing: 0) {
            
            // MARK: - Current Location Row
            VStack(alignment:.leading){
                if Local.shared.placeApiKey.count > 0 {
                    ZStack{
                        HStack {
                            Image("search").resizable().frame(width: 20,height: 20)
                            TextField("Search city,area or locality", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.horizontal, 8)
                                .frame(height: 36)
                                .tint(Color(Themes.sharedInstance.themeColor)).disabled(true)
                            
                        }.background(Color(UIColor.systemBackground)).padding()
                            .frame(height: 45).overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray, lineWidth: 1)
                                
                                Button(action: {
                                    showSearch = true
                                }) {
                                    Color.clear
                                }
                                .contentShape(Rectangle())
                                
                            }
                        
                    }.padding(.horizontal)
                        .sheet(isPresented: $showSearch) {
                            PlaceSearchView { selected in
                                print("User picked: \(selected)")
                                
                                if popType == .createPost || popType == .buyPackage {
                                    
                                    if (selected.city?.count ?? 0) == 0{
                                        showAlert = true
                                    }else{
                                        savedLocation(selLoc: selected)
                                        placeApiLocSelected(selLoc: selected)
                                    }
                                    
                                }else{
                                    savedLocation(selLoc: selected)
                                    placeApiLocSelected(selLoc: selected)
                                }
                                
                                
                            }
                        }.alert("", isPresented: $showAlert) {
                            Button("OK", role: .cancel) { }
                        } message: {
                            Text("Please select specific city or area.")
                        }
                    
                }
                VStack(alignment:.leading){
                    HStack {
                        
                        Button(action: {
                            // Enable location action
                            findMyLocationAction(isToUpdate: true)
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
                }.padding(.bottom,5)
               
            }//.padding(.top, 1)
            
            Divider().padding([.top,.bottom],5).padding(.horizontal,10)
            
            // MARK: - List of Countries
            ScrollView{
                
                if searchText.count == 0 {
                    ForEach(arrCountries) { country in
                        CountryRow(strTitle:country.name ?? "")
                            .frame(height: 40)
                            .onTapGesture{
                                self.navigateToStateListing(country: country)
                            }
                        Divider()//.padding(.horizontal,10)
                    }
                    
                }else {
                    
                    ForEach(arrSearchedCountries) { country in
                        CountryRow(strTitle:country.name ?? "")
                            .frame(height: 40)
                            .onTapGesture{
                                
                                self.navigateToStateListing(country: country)
                            }
                        Divider()//.padding(.horizontal,10)
                    }
                }
                
               
                if recentLocationArray.count > 0{
                    VStack(alignment:.leading){
                        Text("Recents").font(Font.manrope(.medium, size: 15))
                            .foregroundColor(.gray).padding([.top])
                        Divider()
                        ForEach(recentLocationArray) { location in
                           
                            HStack {
                                Text("\(location.fullAddress)")
                                    .font(Font.manrope(.medium, size: 15))
                                Spacer()
                                
                            }
                            .contentShape(Rectangle()).onTapGesture {
                                
                                selectedLocationRecent(location:location)


                            }
                            Divider()
                        }
                    }//.padding(.horizontal,10)
                  

                    
                }
            }.padding(.horizontal,10)
            
            Spacer()
        }
        .onAppear{
            if arrCountries.count == 0{
                fetchCountryListing()
            }
            if isFirstTime == true {
                
                if locationManager.isCurrentLocationEnabled(){
                    findMyLocationAction(isToUpdate: false)
                }
            }
        }
        .navigationTitle("Location")
        .navigationBarBackButtonHidden()
        .navigationBarHidden(true)
    }
    
    
    func selectedLocationRecent(location:RecentLocation){
        let name = ""
        let city = location.city
        let state = location.state
        let country = location.country
        let locality = location.area
        let lat = location.latitude
        let lon = location.longitude
        let addr = location.fullAddress

        let selectedPlace = SelectedPlace(
            name: name,
            city: city,
            state: state,
            country: country,
            locality: locality,
            latitude: lat,
            longitude: lon,
            formattedAddress: addr
        )

        placeApiLocSelected(selLoc: selectedPlace)

    }
   
    func findMyLocationAction(isToUpdate:Bool){
        
        locationManager.delegate = self
        locationManager.checkLocationAuthorization(isToUpdate: isToUpdate)
        
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
    
    func savedLocation(selLoc:SelectedPlace){
        
        RecentLocationManager.shared.save(location: RecentLocation(latitude: selLoc.latitude, longitude: selLoc.longitude, city: selLoc.city ?? "", state: selLoc.state  ?? "", area: selLoc.locality  ?? "", country: selLoc.country  ?? "", fullAddress: selLoc.formattedAddress  ?? ""))

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
        var rootView = StateLocationView(navigationController: self.navigationController, country: country, popType: self.popType)
        rootView.delLocationSelected = self
        let vc = UIHostingController(rootView: rootView)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func allCountrySelected() {
        
        if popType == .home || popType == .signUp{
            
            Local.shared.saveUserLocation(city: "", state:  "", country: "", latitude: "0",longitude: "0", timezone: "")
        }
        
        for vc in self.navigationController?.viewControllers ?? [] {
          
            if popType == .buyPackage {
                
                    if let vc1 = vc as? CategoryPlanVC  {
                        delLocationSelected?.savePostLocation(latitude:"", longitude:"",  city:"", state:"", country:"", locality: "")
                        self.navigationController?.popToViewController(vc1, animated: true)
                        break
                    }
                
            }else if popType == .filter {
                
                    if let vc1 = vc as? FilterVC  {
                        delLocationSelected?.savePostLocation(latitude:"", longitude: "",  city: "", state: "", country: "", locality: "")
                        self.navigationController?.popToViewController(vc1, animated: true)
                        break
                    }
                
            }else  if popType == .createPost {
                
               
                if let vc1 = vc as? ConfirmLocationHostingController {
                    delLocationSelected?.savePostLocation(latitude:"", longitude: "",  city:"", state: "", country: "", locality: "")
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
                        delLocationSelected?.savePostLocation(latitude: "", longitude:"",  city:"", state: "", country: "", locality: "")
                        self.navigationController?.popToViewController(vc1, animated: true)
                        break
                    }
                   
                }
            }
        }
    }
    
    
    
    
    
    func placeApiLocSelected(selLoc:SelectedPlace) {
        
         let data: [String: Any] = [
                        "city": selLoc.city ?? "",
                        "state": selLoc.state ?? "",
                        "country": selLoc.country ?? "",
                        "latitude": "\(selLoc.latitude)",
                        "longitude": "\(selLoc.longitude)",
                        "locality": selLoc.locality ?? "",
                     ]
        
        
        if popType == .home || popType == .signUp{
            Local.shared.saveUserLocation(city: selLoc.city ?? "", state: selLoc.state ?? "", country: selLoc.country ?? "", latitude: "\(selLoc.latitude)", longitude:  "\(selLoc.longitude)", timezone: "",locality: selLoc.locality ?? "")
        }
        
        for vc in self.navigationController?.viewControllers ?? [] {
          
            if popType == .buyPackage {
                
                if let vc1 = vc as? CategoryPlanVC  {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotiKeysLocSelected.buyPackageNewLocation.rawValue),
                                                    object: nil, userInfo: data)
                    self.navigationController?.popToViewController(vc1, animated: true)
                    break
                }
                
            }else if popType == .filter {
                
                if let vc1 = vc as? FilterVC  {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotiKeysLocSelected.filterNewLocation.rawValue),
                                                    object: nil, userInfo: data)
                    self.navigationController?.popToViewController(vc1, animated: true)
                    break
                }
                
            }else  if popType == .createPost {
                
              //  if let vc1 = vc as? ConfirmLocationHostingController {
                    if let vc1 = vc as? PostAdFinalVC {

                    // Pop to that view controller
                    self.navigationController?.popToViewController(vc1, animated: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotiKeysLocSelected.createPostNewLocation.rawValue),
                                                        object: nil, userInfo: data)
                    }
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
                   
                        self.navigationController?.popToViewController(vc1, animated: true)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotiKeysLocSelected.homeNewLocation.rawValue),
                                                        object: nil, userInfo: data)
                        break
                    }
                }
            } else  if popType == .bannerPromotionLocation {
                
                if vc.isKind(of: UIHostingController<ChooseLocationBannerView>.self) == true{
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotiKeysLocSelected.bannerPromotionNewLocation.rawValue),
                                                    object: nil, userInfo: data)
                    self.navigationController?.popToViewController(vc, animated: true)
                    break
                }
            }
        }
    }
    

    func locationSelected() {
                
        for vc in self.navigationController?.viewControllers ?? [] {
          
            if popType == .buyPackage {
                
                    if let vc1 = vc as? CategoryPlanVC  {
                        vc1.savePostLocation(latitude:"\(self.locationManager.latitude)", longitude:"\(locationManager.longitude)",  city:locationManager.city, state:locationManager.state, country:locationManager.country, locality: "")
                        self.navigationController?.popToViewController(vc1, animated: true)
                        break
                    }
                
            }else if popType == .filter {
                
                    if let vc1 = vc as? FilterVC  {
                        vc1.savePostLocation(latitude:"\(self.locationManager.latitude)", longitude:"\(locationManager.longitude)",  city:locationManager.city, state:locationManager.state, country:locationManager.country, locality: "")
                        self.navigationController?.popToViewController(vc1, animated: true)
                        break
                    }
                
            }else  if popType == .createPost {
               // if let vc1 = vc as? ConfirmLocationHostingController {
                    
                if let vc1 = vc as? PostAdFinalVC {

                    delLocationSelected?.savePostLocation(latitude:"\(self.locationManager.latitude)", longitude:"\(locationManager.longitude)",  city:locationManager.city, state:locationManager.state, country:locationManager.country, locality: "")
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
                        vc1.savePostLocation(latitude:"\(locationManager.latitude)", longitude:"\(locationManager.longitude)",  city:locationManager.city, state:locationManager.state, country:locationManager.country, locality: "")
                        
                        self.navigationController?.popToViewController(vc1, animated: true)
                        break
                    }
                   
                }
            }else  if popType == .bannerPromotionLocation {
                
                let data: [String: Any] = [
                    "city": locationManager.city,
                    "state": locationManager.state,
                    "country": locationManager.country,
                    "latitude": locationManager.latitude,
                    "longitude": locationManager.longitude,
                    "locality": locationManager.locality]
                
                if vc.isKind(of: UIHostingController<ChooseLocationBannerView>.self) == true{
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotiKeysLocSelected.bannerPromotionNewLocation.rawValue),
                                                    object: nil, userInfo: data)
                    self.navigationController?.popToViewController(vc, animated: true)
                    break
                }
            }
        }
    }
    
    func savePostLocation(latitude:String, longitude:String,  city:String, state:String, country:String) {
        delLocationSelected?.savePostLocation(latitude: latitude, longitude: longitude, city: city, state: state, country: country, locality: "")
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
    func locationAuthorizationUpdate(isToUpdateLocation:Bool) {
       
        if locationManager.manager.authorizationStatus == .authorizedAlways  ||  locationManager.manager.authorizationStatus == .authorizedWhenInUse {
            
            if let coordinate = locationManager.lastKnownLocation {
                
                print("Latitude: \(coordinate.latitude)")
                print("Longitude: \(coordinate.longitude)")
                
                if (popType == .home || popType == .signUp) && isToUpdateLocation{
                    
                    Local.shared.saveUserLocation(city: locationManager.city, state: locationManager.state, country: locationManager.country,latitude: "\(locationManager.latitude)", longitude: "\(locationManager.longitude)", timezone: locationManager.timezone)
                }
                    
                    print(Local.shared.getUserCity(), Local.shared.getUserState(), Local.shared.getUserCountry(),Local.shared.getUserTimeZone())
                    
                    locationManager.delegate = nil
                if isFirstTime == false && isToUpdateLocation {
                    
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
    
    func savePostLocation(latitude:String, longitude:String,  city:String, state:String, country:String,locality:String)
    func savePostLocationWithRange(latitude:String, longitude:String,  city:String, state:String, country:String, range:Double)
    
}

extension LocationSelectedDelegate {
    func savePostLocation(latitude:String, longitude:String,  city:String, state:String, country:String,locality:String){}
    func savePostLocationWithRange(latitude:String, longitude:String,  city:String, state:String, country:String, range:Double){}
}





struct RecentLocation: Codable, Equatable,Identifiable {
    let id = UUID()
    let latitude: Double
    let longitude: Double
    let city: String
    let state: String
    let area: String
    let country: String
    let fullAddress: String
    
}


class RecentLocationManager {
    private let key = "recent_locations"

    static let shared = RecentLocationManager()

    func save(location: RecentLocation) {
        var list = fetch()

        
        // Remove if same address already exists
        list.removeAll { $0.fullAddress == location.fullAddress }
        
        // Remove existing entry if same location already present
        if let index = list.firstIndex(of: location) {
            list.remove(at: index)
        }

        // Add new at top
        list.insert(location, at: 0)

        // Keep max 4
        if list.count > 4 {
            list = Array(list.prefix(4))
        }

        // Save to UserDefaults
        if let data = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    


    func fetch() -> [RecentLocation] {
        if let data = UserDefaults.standard.data(forKey: key),
           let obj = try? JSONDecoder().decode([RecentLocation].self, from: data) {
            return obj
        }
        return []
    }

    func clearAll() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
