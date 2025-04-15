//
//  SearchWithSortView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 15/04/25.
//

import SwiftUI

struct SearchWithSortView: View {
    @State private var isGridView = true
    var navigationController:UINavigationController?
    @State var categroryId = 0
    @State var categoryName = "Motorcycles and Scooters"
    @State var srchTxt = ""
    @State var items = [ItemModel]()
    @State var page = 1
    @State var isDataLoading = false
    @State var dictCustomFields:Dictionary<String,Any> = [:]
    @State var selectedSortBy: String  = "Default"
    @State var showSortSheet: Bool = false
    @State var city = ""
    @State var country = ""
    @State var state = ""
    
    var body: some View {
        
        HStack{
            Button {
                navigationController?.popViewController(animated: true)
                
            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(.black)
            }.frame(width: 40,height: 40)
            Text(categoryName).font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(.black)
            Spacer()
        }.frame(height:44).background().onAppear{
            city = Local.shared.getUserCity()
            state = Local.shared.getUserState()
            country = Local.shared.getUserCountry()

            getSearchItemApi()

        }
        
        
            VStack {
                // Search & View Toggle
                HStack {
                    TextField("Search any item...", text: $srchTxt).padding().frame(height:40)
                       .background(Color(.systemGray6))
                       .cornerRadius(10).padding(.leading,10)
                       .submitLabel(.search)
                       .onSubmit {
                           self.page = 1
                           getSearchItemApi()
                       }

                    Spacer()
                    
                    // Toggle button
                    Button(action: {
                        isGridView = true
                    }) {
                        Image(systemName:"square.grid.2x2") .background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 6))
                            .padding(8)
                    }.tint((isGridView) ? .black : .gray)
                    
                    Button(action: {
                        isGridView = false
                    }) {
                        Image(systemName:"list.bullet") .background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 6))
                            .padding(8)
                    }.tint((isGridView) ? .gray : .black)
                }.frame(height:50).background(Color.white)
                    .padding(.top,1)

                // Listings
                ScrollView {
                    if isGridView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(items, id: \.id) { item in
                                ProductCard(objItem: item)
                                    .onTapGesture {
                                    let hostingController = UIHostingController(rootView: ItemDetailView(navController:  AppDelegate.sharedInstance.navigationController, itemId: item.id ?? 0,isMyProduct:false))
                                    AppDelegate.sharedInstance.navigationController?.pushViewController(hostingController, animated: true)
                                }

                            }
                        }
                        .padding(.horizontal,10)
                        
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(items, id: \.id) {
                                item in
                                FavoritesCell(itemObj: item)
                                    .padding(.horizontal)
                                    .onTapGesture {
                                    let hostingController = UIHostingController(rootView: ItemDetailView(navController:  AppDelegate.sharedInstance.navigationController, itemId: item.id ?? 0,isMyProduct:false))
                                    AppDelegate.sharedInstance.navigationController?.pushViewController(hostingController, animated: true)
                                }
                            }
                        }
                    }
                }

                Spacer()
                // Bottom bar
                HStack {
                    
                    Button {
                        if let vc = StoryBoard.postAdd.instantiateViewController(identifier: "FilterVC") as? FilterVC {
                            vc.delFilterSelected = self
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    } label: {
                        
                        HStack {
                            
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            Text("Filter")
                        }
                        .frame(maxWidth: .infinity)
                    }.tint(.black)

                  

                    Divider()
                    Button {
                        showSortSheet.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.up.arrow.down")
                            Text("Sort by")
                        }
                        
                        .frame(maxWidth: .infinity)
                    }.tint(.black)
                }.frame(height: 50)
                .background(Color.white.shadow(radius: 2))
            }.background(Color(UIColor.systemGray6)).navigationBarHidden(true)
            .sheet(isPresented: $showSortSheet) {
                if #available(iOS 16.0, *) {
                    SortSheetView(isPresented: $showSortSheet, selectedSort: $selectedSortBy, onSortSelected: {selected  in
                        
                        self.page = 1
                        self.selectedSortBy = selected
                        getSearchItemApi()
                    })
                        .presentationDetents([.fraction(0.45)])
                } else {
                    // Fallback on earlier versions
                }
                    }
    }
    
    
    func getSearchItemApi(){
        var latitude = 0.0
        var longitude = 0.0
        
        
        var strUrl = Constant.shared.get_item + "?category_id=\(categroryId)&page=\(page)"

              
        if srchTxt.count > 0{
            strUrl.append("&search=\(srchTxt)")
        }
        
        if city.count > 0{
            strUrl.append("&city=\(city)")
        }
        
        
        if country.count > 0{
            strUrl.append("&country=\(country)")
        }
        
        
        if state.count > 0{
            strUrl.append("&state=\(state)")
        }
        
        
        if  let  latit = dictCustomFields["latitude"]  as? Double{
            latitude =  latit
            strUrl.append("&latitude=\(latitude)")
        }
        
        if  let  longit = dictCustomFields["longitude"]  as? Double{
            longitude =  longit
            strUrl.append("&longitude=\(longitude)")
        }
       
        if selectedSortBy.count > 0{
            
            if selectedSortBy == "Default"{
                
            }else{
                let str = selectedSortBy.lowercased()
                    .replacingOccurrences(of: " ", with: "-")
                strUrl.append("&sort_by=\(str)")
            }
        }

        
        if  let  max_price = dictCustomFields["max_price"]  as? String{
            strUrl.append("&max_price=\(max_price)")
        }
        
        if  let  min_price = dictCustomFields["min_price"]  as? String{
            strUrl.append("&min_price=\(min_price)")
        }
        
        
       // city: Akasahebpet, state: Andhra Pradesh, country: India
      
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) { (obj:ItemParse) in

            if self.page == 1{
                self.items = obj.data?.data ?? []

            }else{
                self.items.append(contentsOf: (obj.data?.data)!)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.isDataLoading = false
                self.page = (self.page) + 1
            })
        }

    }
}


extension SearchWithSortView: FilterSelected{
    func filterSelectectionDone(dict:Dictionary<String,Any>) {
        print(dict)
        self.page = 1
        self.dictCustomFields = dict
        
        city = dict["city"] as? String ?? ""
        country = dict["country"] as? String ?? ""
        state = dict["state"] as? String ?? ""

        getSearchItemApi()
    }
}

#Preview {
    SearchWithSortView()
}




struct SortSheetView: View {
    @Binding var isPresented: Bool
    @Binding var selectedSort: String
    let onSortSelected: (String) -> Void

    let sortOptions = [
        "Default",
        "New to Old",
        "Old to New",
        "Price High to Low",
        "Price Low to High"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray.opacity(0.5))
                .padding(.top, 8)

            Text("Sort by")
                .font(.headline)
                .padding()

            ForEach(sortOptions, id: \.self) { option in
                Button(action: {
                    selectedSort = option
                    onSortSelected(option)
                    isPresented = false
                }) {
                    HStack {
                        Text(option)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedSort == option {
                            Image(systemName: "checkmark")
                        }
                    }
                    .padding()
                }
                Divider()
            }
        }
        .padding(.bottom, 20)
    }
}
