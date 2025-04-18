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
    var categoryName = ""
    @State var srchTxt = ""
    @State var selectedSortBy: String  = "Default"
    @State var showSortSheet: Bool = false
    @StateObject private var objVM: SearchViewModel
    
    init(categroryId: Int,navigationController:UINavigationController?,categoryName:String) {
        _objVM = StateObject(wrappedValue: SearchViewModel(catId: categroryId))
        self.categoryName = categoryName
        self.navigationController = navigationController
    }
    
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
        }.frame(height:44)
        
        VStack {
            HStack {
                HStack{
                    Image("search").renderingMode(.template).foregroundColor(.gray).padding(.leading,10)
                    TextField("Search any item...", text: $srchTxt).frame(height:40)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .submitLabel(.search)
                        .onSubmit {
                            self.objVM.page = 1
                            self.objVM.getSearchItemApi(srchTxt:srchTxt)
                        }
                }.background(Color(.systemGray6))
                .cornerRadius(10).padding(.leading,10)
               
                Spacer()
                // Toggle button
                Button(action: {
                    isGridView = true
                }) {
                    Image("grid_view").renderingMode(.template).tint((!isGridView) ? .gray : .black) .background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 6))
                        .padding(8)
                }.tint((isGridView) ? .black : .gray)
                
                Button(action: {
                    isGridView = false
                }) {
                    Image("list_view").renderingMode(.template).tint((isGridView) ? .gray : .black) .background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 6))
                        .padding(8)
                }.tint((isGridView) ? .gray : .black)
            }.frame(height:50).background(Color.white)
                .padding(.top,1)
            
            // Listings
            ScrollView {
                if isGridView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(objVM.items, id: \.id) { item in
                            
                            ProductCard(objItem: item)
                                .onTapGesture {
                                    
                                    
                                    let itemId = item.id ?? 0
                                    
                                    self.pushToDetailScreen(id: itemId, item: item)
                                    /*    let destView = ItemDetailView(navController: nil,
                                                                  itemId:itemId,
                                                                  isMyProduct:false,
                                                                  itemObj:nil)
                                  let hostingVC = UIHostingController(rootView:destView)
                                    AppDelegate.sharedInstance.navigationController?.pushViewController(hostingVC, animated: true)*/
                                    
                                }
                                .onAppear {
                                    let lastItem = objVM.items.last
                                    let isLastItem = lastItem?.id == item.id
                                    let isNotLoading = !objVM.isDataLoading
                                    if isLastItem && isNotLoading {
                                        objVM.getSearchItemApi(srchTxt: srchTxt)
                                    }
                                }
                            
                        }
                    }
                    .padding(.horizontal,10)
                    
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(objVM.items, id: \.id) {
                            item in
                            FavoritesCell(itemObj: item)
                                .padding(.horizontal)
                                .onTapGesture {
                                    
                                  let itemId =  item.id ?? 0
                                    self.pushToDetailScreen(id: itemId, item: item)

                                    /*   let destView = ItemDetailView(navController:  AppDelegate.sharedInstance.navigationController, itemId:id,isMyProduct:false,itemObj: item)
                                    let hostController = UIHostingController(rootView: destView)
                                    AppDelegate.sharedInstance.navigationController?.pushViewController(hostController, animated: true)
                                    */
                                }.onAppear {
                                    let lastItem = objVM.items.last
                                    let isLastItem = lastItem?.id == item.id
                                    let isNotLoading = !objVM.isDataLoading
                                    if isLastItem && isNotLoading {
                                        objVM.getSearchItemApi(srchTxt: srchTxt)
                                    }
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
                        
                        Image("filter").renderingMode(.template).foregroundColor(.black)
                        Text("Filter")
                    }
                    .frame(maxWidth: .infinity)
                }.tint(.black)
                
                
                
                Divider()
                Button {
                    showSortSheet.toggle()
                } label: {
                    HStack {
                        Image("sort_by")
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
                        
                        self.objVM.page = 1
                        self.objVM.selectedSortBy = selected
                        self.objVM.getSearchItemApi(srchTxt: srchTxt)
                    })
                    .presentationDetents([.fraction(0.45)])
                } else {
                    // Fallback on earlier versions
                }
            }
    }
    
    func pushToDetailScreen(id:Int,item:ItemModel){
        let destView = ItemDetailView(navController:  AppDelegate.sharedInstance.navigationController, itemId:id,itemObj: item, isMyProduct:false)
         let hostController = UIHostingController(rootView: destView)
         AppDelegate.sharedInstance.navigationController?.pushViewController(hostController, animated: true)
         
    }
}


extension SearchWithSortView: FilterSelected{
    func filterSelectectionDone(dict:Dictionary<String,Any>) {
        print(dict)
        self.objVM.page = 1
        self.objVM.dictCustomFields = dict
        self.objVM.city = dict["city"] as? String ?? ""
        self.objVM.country = dict["country"] as? String ?? ""
        self.objVM.state = dict["state"] as? String ?? ""
        self.objVM.getSearchItemApi(srchTxt: srchTxt)
    }
}

#Preview {
    SearchWithSortView(categroryId: 0, navigationController: nil, categoryName: "")
}





