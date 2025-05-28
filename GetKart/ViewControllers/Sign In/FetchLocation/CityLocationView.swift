
import Foundation
import SwiftUI
import Alamofire

enum PopType{
    case signUp
    case filter
    case home
    case buyPackage
    case createPost
    case editPost
    case categoriesSeeAll
}

struct CityLocationView: View {
    
    var navigationController: UINavigationController?
    var country:CountryModel = CountryModel()
    var state:StateModal = StateModal()
    var popType:PopType?
    var delLocationSelected:LocationSelectedDelegate?
    @State private var pageNo = 1
    @State private var totalRecords = 1
    @State private var arrCitiesSearch:Array<CityModal> = []
    @State private var isDataLoading = false
    @State private var pageNoSearch = 1
    @State private var isSearching = false
    @State var arrCities:Array<CityModal> = []
    @State private var searchText = ""
    
    var body: some View {
        
        VStack(spacing: 0) {
            HStack{
                
                Button {
                    self.navigationController?.popViewController(animated: true)
                } label: {
                    Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
                }.frame(width: 40,height: 40)
                
                Text("\(self.state.name ?? "")").font(.custom("Manrope-Bold", size: 20.0))
                    .foregroundColor(Color(UIColor.label))
                Spacer()
            }.frame(height:44).background(Color(UIColor.systemBackground))
            
            // MARK: - Search Bar
            HStack {
                HStack {
                    Image("search").resizable().frame(width: 20,height: 20)
                    TextField("Search City", text: $searchText)
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
                            self.fetchCityListing()
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
                        CountryRow(strTitle:"All in \(state.name ?? "")")
                            .frame(height: 40)
                            .padding(.horizontal)
                        
                            .onTapGesture{
                                
                                self.citySelected(city: CityModal())
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
                        
                        ForEach(arrCitiesSearch) { city in
                            CountryRow(strTitle:city.name ?? "")
                                .frame(height: 40)
                                .padding(.horizontal)
                                .onAppear{
                                    checkAndCallApi(cityObj: city, isSearching: true)
                                }
                                .onTapGesture{
                                    self.citySelected(city: city)
                                }
                            Divider()
                        }
                        
                    }else{
                        ForEach(arrCities) { city in
                            CountryRow(strTitle:city.name ?? "")
                                .frame(height: 40)
                                .padding(.horizontal)
                                .onAppear{
                                    checkAndCallApi(cityObj: city, isSearching: false)
                                }
                                .onTapGesture{
                                    self.citySelected(city: city)
                                }
                            Divider()
                        }
                        
                    }
                }
            }.searchable(text: $searchText)
            
            Spacer()
            
        }.onAppear{
            self.fetchCityListing()
        }
        .navigationTitle("Location")
        .navigationBarBackButtonHidden()
        .navigationBarHidden(true)
        
    }
  
    
    func checkAndCallApi(cityObj:CityModal,isSearching:Bool){
        
        if isSearching{
            if  let cityId = arrCitiesSearch.last?.id, cityObj.id == cityId{
                fetchCityListing()
            }
            
        }else{
          
            if  let cityId = arrCities.last?.id, cityObj.id == cityId{
                if self.totalRecords != arrCities.count {
                    fetchCityListing()
                }
            }
        }
    }
    
    func fetchCityListing(){
        guard !isDataLoading else { return }

        var url = Constant.shared.get_Cities + "?state_id=\(state.id ?? 0)&page=\(pageNo)&search=" //&search=\(searchText)"
        
        if isSearching{
             url = Constant.shared.get_Cities + "?state_id=\(state.id ?? 0)&page=\(pageNoSearch)&search=\(searchText)"
        }
       
        self.isDataLoading = true

        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: url) { (obj:CityParse) in
            
            if obj.code == 200{
                if self.isSearching{
                    
                    if self.pageNoSearch == 1 {
                        self.arrCitiesSearch.removeAll()
                    }
                    self.arrCitiesSearch.append(contentsOf: obj.data?.data ?? [])
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        self.isDataLoading = false
                        self.pageNoSearch = pageNoSearch + 1
                    })
               
                }else{
                    totalRecords  = obj.data?.total ?? 0
                    self.arrCities.append(contentsOf:obj.data?.data ?? [])
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
   
    
    func citySelected(city:CityModal) {
        
        
         let data: [String: Any] = [
                        "city": city.name ?? "",
                        "state": self.state.name ?? "",
                        "country": self.country.name ?? "",
                        "latitude": city.latitude ?? "",
                        "longitude": city.longitude ?? "",
                        "locality": "",
                     ]
        
        if popType == .home || popType == .signUp{
            Local.shared.saveUserLocation(city: city.name ?? "", state: self.state.name ?? "", country: self.country.name ?? "", latitude:city.latitude ?? "", longitude:city.longitude ?? "", timezone: "")
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
            }
        }
    }
}


#Preview {
    StateLocationView()
}
