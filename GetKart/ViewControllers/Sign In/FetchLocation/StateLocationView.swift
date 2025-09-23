//
//  StateLocationView.swift
//  GetKart
//
//  Created by gurmukh singh on 3/4/25.
//

import Foundation
import SwiftUI
import Alamofire

struct StateLocationView: View, LocationSelectedDelegate {
    var navigationController: UINavigationController?
    @State var arrStates:Array<StateModal> = []
    @State var arrSearchStates:Array<StateModal> = []
    @State private var searchText = ""
    @State private var pageNo = 1
    @State private var pageNoSearch = 1
    @State private var isSearching = false
    @State private var totalRecords = 1
    var country:CountryModel = CountryModel()
    @State private var isDataLoading = false
    var popType:PopType?
    var delLocationSelected:LocationSelectedDelegate?
    

   
    var body: some View {
        
        VStack(spacing: 0) {
            HStack{
                
                Button {
                    self.navigationController?.popViewController(animated: true)
                } label: {
                    Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
                }.frame(width: 40,height: 40)
                
                Text("\(country.name ?? "")").font(.custom("Manrope-Bold", size: 20.0))
                    .foregroundColor(Color(UIColor.label))
                Spacer()
            }.frame(height:44).background(Color(UIColor.systemBackground))
            
            // MARK: - Search Bar
            HStack {
               
                HStack {
                    Image("search").resizable().frame(width: 20,height: 20)
                    TextField("Search State", text: $searchText)
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
                                self.fetchStateListing()
                            
                        }
                    if searchText.count > 0 {
                        Button("Clear") {
                            self.isDataLoading = false
                            searchText = ""
                        }.padding(.horizontal,5).foregroundColor(Color(UIColor.label))
                    }
                }.background(Color(UIColor.systemBackground)).padding().frame(height: 45).overlay {
                        RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                    }
                // Icon button on the right (for settings or any other action)
              /*  Button(action: {
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
                if popType == .filter  || popType == .home{
                    CountryRow(strTitle:"All in \(country.name ?? "")")
                        .frame(height: 40)
                        .padding(.horizontal)
                        .onTapGesture{
                            self.allStatesSelected()
                        }
                }else {
                    CountryRow(strTitle:"Choose State",isArrowNeeded:false)
                        .frame(height: 40)
                        .padding(.horizontal)
                        .onTapGesture{
                        }
                }
                Divider()
  
                LazyVStack {
                    
                    if isSearching{
                        //IS Searching
                        ForEach(arrSearchStates, id:\.id) { state in
                            
                            CountryRow(strTitle:state.name ?? "")
                                .frame(height: 40)
                                .padding(.horizontal)
                            
                                .onAppear{
                                    if state.id == arrSearchStates.last?.id {
                                        if !isDataLoading {
                                            fetchStateListing()
                                        }
                                    }
                                    
                                }
                                .onTapGesture{
                                    self.NavigateToCityListing(state:state)
                                }
                            Divider()
                        }
                    }else{
                        
                        ForEach(arrStates, id:\.id) { state in
                            
                            CountryRow(strTitle:state.name ?? "")
                                .frame(height: 40)
                                .padding(.horizontal)
                            
                                .onAppear{
                                    if state.id == arrStates.last?.id {
                                        if self.totalRecords != arrStates.count  && !isDataLoading {
                                            fetchStateListing()
                                        }
                                    }
                                }
                                .onTapGesture{
                                    self.NavigateToCityListing(state:state)
                                }
                            Divider()
                        }
                    }
                   
                }
            }
            Spacer()
            
           
            if isDataLoading {
                ProgressView()
                    .padding()
            }
            
        }.onAppear{
            if arrStates.count == 0{
                self.fetchStateListing()
            }
        }
        .navigationTitle("Location")
        .navigationBarBackButtonHidden()
        .navigationBarHidden(true)
    
}
    
    
    
    func fetchStateListing(){
        guard !isDataLoading else { return }

        self.isDataLoading = true

        var url = Constant.shared.get_States + "?country_id=\(country.id ?? 0)&page=\(pageNo)&search="
        
        if isSearching{
             url = Constant.shared.get_States + "?country_id=\(country.id ?? 0)&page=\(pageNoSearch)&search=\(searchText)"
        }

        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: url) { (obj:StateParse) in
           
           if obj.code == 200{
               
               if self.isSearching{
                   
                   if self.pageNoSearch == 1 {
                       self.arrSearchStates.removeAll()
                   }
                   self.arrSearchStates.append(contentsOf: obj.data?.data ?? [])
                 
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                       self.isDataLoading = false
                       self.pageNoSearch = pageNoSearch + 1
                   })
               }else{
                  
                   if self.pageNo == 1 {
                       self.arrStates.removeAll()
                   }
                   self.totalRecords = obj.data?.total ?? 0
                   self.arrStates.append(contentsOf: obj.data?.data ?? [])
                 
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
    
    
    func allStatesSelected() {
        
 
        let data: [String: Any] = [
                        "city": "",
                        "state": "",
                        "country": self.country.name ?? "",
                        "latitude":  "",
                        "longitude": "",
                        "locality": "",

                    ]
        
        if popType == .home || popType == .signUp{
            
//            Local.shared.saveUserLocation(city: "", state:  "", country:self.country.name ?? "", latitude: "\(self.country.latitude ?? "")", longitude: "\(self.country.longitude ?? "")"  , timezone: "")
            
            
            Local.shared.saveUserLocation(city: "", state:  "", country:self.country.name ?? "", latitude: "", longitude: "" , timezone: "")

        }
        
        for vc in self.navigationController?.viewControllers ?? [] {
          
            if popType == .buyPackage {
                
                    if let vc1 = vc as? CategoryPlanVC  {
                        
                     
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotiKeysLocSelected.buyPackageNewLocation.rawValue), object: nil, userInfo: data)
                        
                        self.navigationController?.popToViewController(vc1, animated: true)
                        break
                    }
                
            }else if popType == .filter {
                
                    if let vc1 = vc as? FilterVC  {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotiKeysLocSelected.filterNewLocation.rawValue), object: nil, userInfo: data)
                        self.navigationController?.popToViewController(vc1, animated: true)
                        break
                    }
                
            }else  if popType == .createPost {
                if let vc1 = vc as? ConfirmLocationHostingController {
 
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotiKeysLocSelected.createPostNewLocation.rawValue), object: nil, userInfo: data)
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

                        NotificationCenter.default.post(name: NSNotification.Name(rawValue:NotiKeysLocSelected.homeNewLocation.rawValue), object: nil, userInfo: data)
                        self.navigationController?.popToViewController(vc1, animated: true)
                        break
                    }
                   
                }
            }
        }
    }
    
    func NavigateToCityListing(state:StateModal){
        var rootView = CityLocationView(navigationController: self.navigationController,country: country, state: state, popType: self.popType)
        rootView.delLocationSelected = self
        let vc = UIHostingController(rootView: rootView)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func savePostLocation(latitude:String, longitude:String,  city:String, state:String, country:String,locality:String) {
        delLocationSelected?.savePostLocation(latitude: latitude, longitude: longitude, city: city, state: state, country: country, locality: locality)
    }
    
}


#Preview {
    StateLocationView()
}
