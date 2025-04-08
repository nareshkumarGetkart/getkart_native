
import Foundation
import SwiftUI


enum PopType{
    case signUp
    case filter
    case home
    case buyPackage
    case createPost
}

struct CityLocationView: View {
    var navigationController: UINavigationController?
    @State var arrCities:Array<CityModal> = []
    @State private var searchText = ""
    var country:CountryModel = CountryModel()
    var state:StateModal = StateModal()
    @State var pageNo = 1
    @State var totalRecords = 1
   // @State var isNewPost = false
   // @State var isFilterList = false
    
    @State var popType:PopType?
    
    var body: some View {
        
        
        VStack(spacing: 0) {
            HStack{
                
                Button {
                    self.navigationController?.popViewController(animated: true)
                } label: {
                    Image("arrow_left").renderingMode(.template).foregroundColor(.black)
                }.frame(width: 40,height: 40)
                
                Text("\(self.state.name ?? "")").font(.custom("Manrope-Bold", size: 20.0))
                    .foregroundColor(.black)
                Spacer()
            }.frame(height:44).background(Color.white)
            
            // MARK: - Search Bar
            HStack {
                TextField("Search State", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 8)
                    .frame(height: 36)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                // Icon button on the right (for settings or any other action)
                Button(action: {
                    // Action for icon button
                    
                }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            
            
            
            
            Divider()
            
            // MARK: - List of Countries
            ScrollView{
                LazyVStack {
                    ForEach(arrCities) { city in
                        CountryRow(strTitle:city.name ?? "").frame(height: 40)
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
            
            Spacer()
        }.onAppear{
            self.fetchCityListing()
        }
        .navigationTitle("Location")
        .navigationBarBackButtonHidden()
        .navigationBarHidden(true)
}
    
  
    
    func fetchCityListing(){
        let url = Constant.shared.get_Cities + "?state_id=\(state.id ?? 0)&page=\(pageNo)"
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: url) { (obj:CityParse) in
            
            pageNo = pageNo + 1
            totalRecords  = obj.data?.total ?? 0
            self.arrCities.append(contentsOf:obj.data?.data ?? [])
            print(self.arrCities)
           
       }
   }
    
    func citySelected(city:CityModal) {
        
        if popType == .home || popType == .signUp{
            
            Local.shared.saveUserLocation(city: city.name ?? "", state: self.state.name ?? "", country: self.country.name ?? "", timezone: "")
        }
        
        for vc in self.navigationController?.viewControllers ?? [] {
          
            if popType == .buyPackage {
                
                    if let vc1 = vc as? CategoryPlanVC  {
                        vc1.savePostLocation(latitude:city.latitude ?? "", longitude:city.longitude ?? "",  city:city.name ?? "", state:self.state.name ?? "", country:self.country.name ?? "")
                        self.navigationController?.popToViewController(vc1, animated: true)
                        break
                    }
                
            }else if popType == .filter {
                
                    if let vc1 = vc as? FilterVC  {
                        vc1.savePostLocation(latitude:city.latitude ?? "", longitude:city.longitude ?? "",  city:city.name ?? "", state:self.state.name ?? "", country:self.country.name ?? "")
                        self.navigationController?.popToViewController(vc1, animated: true)
                        break
                    }
                
            }else  if popType == .createPost {
                
               
                    if let vc1 = vc as? CreateAddVC2 {
                        vc1.savePostLocation(latitude:city.latitude ?? "", longitude:city.longitude ?? "",  city:city.name ?? "", state:self.state.name ?? "", country:self.country.name ?? "")
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
                        
                        vc1.savePostLocation(latitude:city.latitude ?? "", longitude:city.longitude ?? "",  city:city.name ?? "", state:self.state.name ?? "", country:self.country.name ?? "")
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
