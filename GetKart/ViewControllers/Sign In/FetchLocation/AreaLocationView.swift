
import Foundation
import SwiftUI
import Alamofire
import CoreLocation

struct AreaLocationView: View {
    
    var navigationController: UINavigationController?
    var country:CountryModel = CountryModel()
    var state:StateModal = StateModal()
    var city:CityModal = CityModal()
    var popType:PopType?
    var delLocationSelected:LocationSelectedDelegate?
   
    @State private var pageNo = 1
    @State private var totalRecords = 1
    @State private var arrAreaSearch:Array<AreaModal> = []
    @State private var isDataLoading = false
    @State private var pageNoSearch = 1
    @State private var isSearching = false
    @State var arrAreas:Array<AreaModal> = []
    @State private var searchText = ""
    
    var body: some View {
        
        VStack(spacing: 0) {
            HStack{
                
                Button {
                    self.navigationController?.popViewController(animated: true)
                } label: {
                    Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
                }.frame(width: 40,height: 40)
                
                Text("\(self.city.name ?? "")").font(.custom("Manrope-Bold", size: 20.0))
                    .foregroundColor(Color(UIColor.label))
                Spacer()
            }.frame(height:44).background(Color(UIColor.systemBackground))
            
            // MARK: - Search Bar
            HStack {
                HStack {
                    Image("search").resizable().frame(width: 20,height: 20)
                    TextField("Search Area", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal, 8)
                        .frame(height: 36)
                    
                        .tint(Color(Themes.sharedInstance.themeColor))
                    
                        .onChange(of: searchText) { newValue in
                            print(newValue)
                            pageNoSearch = 1
                            self.isSearching = true
                            if newValue.count == 0{
                                self.isSearching = false
                            }
                            self.fetchAreaListing()
                        }
                    if searchText.count > 0 {
                        Button("Clear") {
                            self.isDataLoading = false
                            searchText = ""
                        }.padding(.horizontal)
                            .foregroundColor(Color(UIColor.label))
                    }
                }.background(Color(UIColor.systemBackground)).padding().frame(height: 45).overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                }
                
                // Icon button on the right (for settings or any other action)
                /*   Button(action: {
                 // Action for icon button
                 
                 }) {
                 Image(systemName: "gearshape.fill")
                 .foregroundColor(.gray)
                 .padding(.leading, 8)
                 }*/
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
            
            // MARK: - List of Countries
            ScrollView{
                LazyVStack {
                    if popType == .filter || popType == .home{
                        CountryRow(strTitle:"All in \(city.name ?? "")")
                            .frame(height: 40)
                            .padding(.horizontal)
                        
                            .onTapGesture{
                                
                                self.areaSelected(area: AreaModal(id: nil, name: nil, cityID: nil, stateID: nil, stateCode: nil, countryID: nil, createdAt: nil, updatedAt: nil))
                            }
                    }else {
                        CountryRow(strTitle:"Choose City",isArrowNeeded:false)
                            .frame(height: 40)
                            .padding(.horizontal)
                        
                            .onTapGesture{
                            }
                    }
                    Divider()
                    
                    if isSearching{
                        
                        ForEach(arrAreaSearch) { area in
                            CountryRow(strTitle:area.name ?? "")
                                .frame(height: 40)
                                .padding(.horizontal)
                                .onAppear{
                                    checkAndCallApi(areaObj: area, isSearching: true)
                                }
                                .onTapGesture{
                                    
                                    self.getLatLongFromAddress(areaObj: area)
                                   // self.areaSelected(arae: area)
                                }
                            Divider()
                        }
                        
                    }else{
                        ForEach(arrAreas) { area in
                            CountryRow(strTitle:area.name ?? "")
                                .frame(height: 40)
                                .padding(.horizontal)
                                .onAppear{
                                    checkAndCallApi(areaObj: area, isSearching: false)
                                }
                                .onTapGesture{
                                  //  self.areaSelected(city: area)
                                    self.getLatLongFromAddress(areaObj: area)

                                }
                            Divider()
                        }
                        
                    }
                }
            }.searchable(text: $searchText)
            
            Spacer()
            
        }.onAppear{
            self.fetchAreaListing()
        }
        .navigationTitle("Location")
        .navigationBarBackButtonHidden()
        .navigationBarHidden(true)
        
    }
  
    
    func checkAndCallApi(areaObj:AreaModal,isSearching:Bool){
        
        if isSearching{
            if  let areaId = arrAreaSearch.last?.id, areaObj.id == areaId{
                fetchAreaListing()
            }
            
        }else{
          
            if  let areaId = arrAreas.last?.id, areaObj.id == areaId{
                if self.totalRecords != arrAreas.count {
                    fetchAreaListing()
                }
            }
        }
    }
    
    func fetchAreaListing(){
        guard !isDataLoading else { return }

        var url = Constant.shared.get_areas + "?city_id=\(city.id ?? 0)&page=\(pageNo)&search=" //&search=\(searchText)"
        
        if isSearching{
             url = Constant.shared.get_areas + "?city_id=\(city.id ?? 0)&page=\(pageNoSearch)&search=\(searchText)"
        }
       
        self.isDataLoading = true

        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: url) { (obj:AreaModelParse) in
            
            if obj.code == 200{
                if self.isSearching{
                    
                    if self.pageNoSearch == 1 {
                        self.arrAreaSearch.removeAll()
                    }
                    self.arrAreaSearch.append(contentsOf: obj.data?.data ?? [])
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        self.isDataLoading = false
                        self.pageNoSearch = pageNoSearch + 1
                    })
               
                }else{
                    totalRecords  = obj.data?.total ?? 0
                    self.arrAreas.append(contentsOf:obj.data?.data ?? [])
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        self.isDataLoading = false
                        self.pageNo = pageNo + 1
                    })
                }
            }else{
                self.isDataLoading = false

            }
           
       }
   }
   
    
    func areaSelected(area:AreaModal) {
        
        
         let data: [String: Any] = [
                        "city": city.name ?? "",
                        "state": self.state.name ?? "",
                        "country": self.country.name ?? "",
                        "latitude": area.latitude ?? "",
                        "longitude": area.longitude ?? "",
                        "locality": area.name ?? "",
                     ]
        
        if popType == .home || popType == .signUp{
            Local.shared.saveUserLocation(city: city.name ?? "", state: self.state.name ?? "", country: self.country.name ?? "", latitude:area.latitude ?? "", longitude:area.longitude ?? "", timezone: "",locality: area.name ?? "")
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
                
                if let vc1 = vc as? ConfirmLocationHostingController {
                    
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
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotiKeysLocSelected.homeNewLocation.rawValue),
                                                        object: nil, userInfo: data)
                        self.navigationController?.popToViewController(vc1, animated: true)
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
    
    
    func getLatLongFromAddress(areaObj:AreaModal){
        
        let address = "\(areaObj.name ?? "") \(city.name ?? "") \(state.name ?? "") \(country.name ?? "")"
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) {
            placemarks, error in
            let placemark = placemarks?.first
            if  let lat = placemark?.location?.coordinate.latitude, let lon = placemark?.location?.coordinate.longitude{
                
                print("Lat: \(lat), Lon: \(lon)")
                var obj =  areaObj
                
                obj.latitude = "\(lat)"
                obj.longitude = "\(lon)"
                self.areaSelected(area: obj)
            }
        }

    
    }
}


#Preview {
    AreaLocationView()
}
