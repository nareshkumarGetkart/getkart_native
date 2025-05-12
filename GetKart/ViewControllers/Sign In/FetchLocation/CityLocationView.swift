
import Foundation
import SwiftUI


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
    @State var arrCities:Array<CityModal> = []
    @State private var searchText = ""
    var country:CountryModel = CountryModel()
    var state:StateModal = StateModal()
    @State var pageNo = 1
    @State var totalRecords = 1
    @State var arrCitiesSearch:Array<CityModal> = []
    @State var isDataLoading = true

    
   // @State var isNewPost = false
   // @State var isFilterList = false
    
    @State var pageNoSearch = 1
    @State private var isSearching = false
    
    @State var popType:PopType?
    var delLocationSelected:LocationSelectedDelegate!
    
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
                    //.background(Color(.systemGray6))
                    //.cornerRadius(8)
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
                            searchText = ""
                        }.padding(.horizontal).foregroundColor(Color(UIColor.label))
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
                                    if  let index = arrCitiesSearch.firstIndex(where: { $0.id == city.id }) {
                                        if index == arrCitiesSearch.count - 1{
                                          //  if self.totalRecords != arrCitiesSearch.count {
                                                fetchCityListing()
                                          //  }
                                        }
                                    }
                                 
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
                                    if  let index = arrCities.firstIndex(where: { $0.id == city.id }) {
                                        if index == arrCities.count - 1{
                                            if self.totalRecords != arrCities.count {
                                                fetchCityListing()
                                            }
                                        }
                                    }
                                 
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
    
  
    
    func fetchCityListing(){
        var url = Constant.shared.get_Cities + "?state_id=\(state.id ?? 0)&page=\(pageNo)&search=" //&search=\(searchText)"
        
        if isSearching{
             url = Constant.shared.get_Cities + "?country_id=\(country.id ?? 0)&page=\(pageNoSearch)&search=\(searchText)"
        }
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: url) { (obj:CityParse) in
            
            if obj.code == 200{
                if self.isSearching{
                    
                    if self.pageNoSearch == 1 {
                        self.arrCitiesSearch.removeAll()
                    }
                    //  self.totalRecords = obj.data?.total ?? 0
                    self.arrCitiesSearch.append(contentsOf: obj.data?.data ?? [])
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                        self.isDataLoading = false
                        self.pageNoSearch = pageNoSearch + 1
                    })
               
                }else{
                  //  pageNo = pageNo + 1
                    totalRecords  = obj.data?.total ?? 0
                    self.arrCities.append(contentsOf:obj.data?.data ?? [])
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                        self.isDataLoading = false
                        self.pageNo = pageNo + 1
                    })
                }
            }
           
       }
   }
   
    
    func citySelected(city:CityModal) {
        
        if popType == .home || popType == .signUp{
            Local.shared.saveUserLocation(city: city.name ?? "", state: self.state.name ?? "", country: self.country.name ?? "", latitude:city.latitude ?? "", longitude:city.longitude ?? "", timezone: "")
        }
        
        for vc in self.navigationController?.viewControllers ?? [] {
          
            if popType == .buyPackage {
                
                    if let vc1 = vc as? CategoryPlanVC  {
                        delLocationSelected?.savePostLocation(latitude:city.latitude ?? "", longitude:city.longitude ?? "",  city:city.name ?? "", state:self.state.name ?? "", country:self.country.name ?? "")
                        self.navigationController?.popToViewController(vc1, animated: true)
                        break
                    }
                
            }else if popType == .filter {
                
                    if let vc1 = vc as? FilterVC  {
                        delLocationSelected?.savePostLocation(latitude:city.latitude ?? "", longitude:city.longitude ?? "",  city:city.name ?? "", state:self.state.name ?? "", country:self.country.name ?? "")
                        self.navigationController?.popToViewController(vc1, animated: true)
                        break
                    }
                
            }else  if popType == .createPost {
                
               
                if let vc1 = vc as? UIHostingController<ConfirmLocationCreateAdd> {
                    self.navigationController?.popToViewController(vc, animated: true)
                    delLocationSelected?.savePostLocation(latitude:city.latitude ?? "", longitude:city.longitude ?? "",  city:city.name ?? "", state:self.state.name ?? "", country:self.country.name ?? "")
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
                        
                        delLocationSelected?.savePostLocation(latitude:city.latitude ?? "", longitude:city.longitude ?? "",  city:city.name ?? "", state:self.state.name ?? "", country:self.country.name ?? "")
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
