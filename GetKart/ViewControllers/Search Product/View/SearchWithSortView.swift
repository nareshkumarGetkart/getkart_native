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
    
//    var selectIds = ""
//    var strTitle = ""
//    var strSubTitle = ""
//    
//    @State var dataArray:[CustomField]?

    var objViewModel:CustomFieldsViewModel?

    init(categroryId: Int,navigationController:UINavigationController?,categoryName:String,categoryIds:String) {
//        _objVM = StateObject(wrappedValue: SearchViewModel(catId: categroryId))
        
        _objVM = StateObject(wrappedValue: SearchViewModel(catId: categroryId, categoryIds: categoryIds))

        self.categoryName = categoryName
        self.navigationController = navigationController
        
        
        if objViewModel == nil {
            objViewModel = CustomFieldsViewModel()
            objViewModel?.appendInitialFilterFieldAndGetCustomFieldds(category_ids: categoryIds)
           
        }
       // objViewModel?.delegate = self
       // objViewModel?.getCustomFieldsListApi(category_ids: categoryIds)
      //  self.getCustomFieldsListApi(category_ids: "\(categroryId)")
    }
    
    var body: some View {
        
        HStack{
            Button {
                navigationController?.popViewController(animated: true)
                
            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
            }.frame(width: 40,height: 40)
            Text(categoryName).font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(Color(UIColor.label))
            Spacer()
        }.frame(height:44).background(Color(.systemBackground))
        
        VStack {
            HStack {
                HStack{
                    Image("search").renderingMode(.template)
                        .foregroundColor(.gray)
                        .padding(.leading,10)
                    TextField("Search any item...", text: $srchTxt).frame(height:40)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .submitLabel(.search)
                        .tint(Color(Themes.sharedInstance.themeColor))
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
                    Image("grid_view").renderingMode(.template).tint((!isGridView) ? .gray : Color(UIColor.label)) .background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 6))
                        .padding(8)
                }.tint((isGridView) ? Color(UIColor.label) : .gray)
                
                Button(action: {
                    isGridView = false
                }) {
                    Image("list_view").renderingMode(.template).tint((isGridView) ? .gray : Color(UIColor.label)) .background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 6))
                        .padding(8)
                }.tint((isGridView) ? .gray : .black)
            }.frame(height:50).background(Color(.systemBackground))
                .padding(.top,1)
            
            if objVM.items.count == 0 && !objVM.isDataLoading {
                HStack{
                    Spacer()
                    VStack(spacing: 20){
                        Spacer()
                        Image("no_data_found_illustrator").frame(width: 150,height: 150).padding()
                        Text("No Data Found").foregroundColor(.orange).font(Font.manrope(.medium, size: 20.0)).padding(.top).padding(.horizontal)
                        Text("We're sorry what you were looking for. Please try another way").font(Font.manrope(.regular, size: 16.0)).multilineTextAlignment(.center).padding(.horizontal)
                        Spacer()
                    }
                    Spacer()
                }
            }else{
                // Listings
                ScrollView {
                    if isGridView {
                        
                        gridView //.padding(.horizontal,10)
                       /* LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach($objVM.items, id: \.id) { $item in
                                
                                ProductCard(objItem: $item)
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
                        */
                    } else {
                      /*  LazyVStack(spacing: 10) {
                            ForEach($objVM.items, id: \.id) {
                                $item in
                                FavoritesCell(itemObj: $item)
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
                        */
                        listView
                    }
                }
                
            }
           
            Spacer()
            // Bottom bar
            HStack {
                Button {
                    if let vc = StoryBoard.postAdd.instantiateViewController(identifier: "FilterVC") as? FilterVC {
                        vc.delFilterSelected = self
                        vc.dataArray = objViewModel?.dataArray ?? []
                        vc.dictCustomFields = self.objVM.dictCustomFields
                        vc.strCategoryTitle = self.categoryName
                        vc.isToCategorybtnDisabled = true
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } label: {
                    
                    HStack {
                        Image("filter").renderingMode(.template).foregroundColor(Color(UIColor.label))
                        Text("Filter")
                    }
                    .frame(maxWidth: .infinity)
                }.tint((Color(UIColor.label)))
                
                
                
                Divider()
                Button {
                    showSortSheet.toggle()
                } label: {
                    HStack {
                        Image("sort_by").renderingMode(.template).foregroundColor(Color(UIColor.label))
                        Text("Sort by")
                    }
                    
                    .frame(maxWidth: .infinity)
                }.tint((Color(UIColor.label)))
            }.frame(height: 50)
                .background(Color(UIColor.systemBackground).shadow(radius: 2))
        }.background(Color(UIColor.systemGray6))
            .navigationBarHidden(true)
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
                  //  fullScreenCover(isPresented: $showSortSheet) {
                            ZStack {
                                Color.black.opacity(0.1).ignoresSafeArea()
                                    .onTapGesture { showSortSheet = false }

                                CustomBottomSheet {
                                    SortSheetView(
                                        isPresented: $showSortSheet,
                                        selectedSort: $selectedSortBy,
                                        onSortSelected: { selected in
                                            self.objVM.page = 1
                                            self.objVM.selectedSortBy = selected
                                            self.objVM.getSearchItemApi(srchTxt: srchTxt)
                                        }
                                    )
                                }
                            }.background(Color.clear)
                      //  }
                }
            }
    }
    
    
    func pushToDetailScreen(id:Int,item:ItemModel){
        var destView = ItemDetailView(navController:  self.navigationController, itemId:id,itemObj: item, isMyProduct:false, slug: item.slug)
        destView.returnValue = { value in
            if let obj = value{
                self.updateItemInList(obj)
            }
        }
        let hostController = UIHostingController(rootView: destView)
        self.navigationController?.pushViewController(hostController, animated: true)
    }
    
    
    private var gridView: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach($objVM.items, id: \.id) { $item in
                ProductCard(objItem: $item, onItemLikeDislike: { likedObj in
                    updateItemInList(likedObj)

                })
                    .onTapGesture {
                        let itemId = item.id ?? 0
                        self.pushToDetailScreen(id: itemId, item: item)
                    }
                    .onAppear {
                        checkIfLastItem(item)
                    }
            }
        }
        .padding(.horizontal, 10)
    }

    private var listView: some View {
        LazyVStack(spacing: 10) {
            ForEach($objVM.items, id: \.id) { $item in
                FavoritesCell(itemObj: $item)
                    .padding(.horizontal)
                    .onTapGesture {
                        let itemId = item.id ?? 0
                        self.pushToDetailScreen(id: itemId, item: item)
                    }
                    .onAppear {
                        checkIfLastItem(item)
                    }
            }
        }
    }
    
    private func checkIfLastItem(_ item: ItemModel) {
        let lastItem = objVM.items.last
        let isLastItem = lastItem?.id == item.id
        let isNotLoading = !objVM.isDataLoading
        if isLastItem && isNotLoading {
            objVM.getSearchItemApi(srchTxt: srchTxt)
        }
    }

    private func updateItemInList(_ value: ItemModel) {
        if let index = $objVM.items.firstIndex(where: { $0.id == value.id }) {
            objVM.items[index] = value
        }
    }
}


extension SearchWithSortView: FilterSelected{
    func filterSelectectionDone(dict:Dictionary<String,Any>, dataArray:Array<CustomField>, strCategoryTitle:String) {
        print(dict)
        
        self.objVM.dictCustomFields = dict

        if dataArray.count < (self.objViewModel?.dataArray?.count ?? 0){
            
            self.objVM.dictCustomFields["category_id"] =  self.objVM.categroryId
        }else{
            self.objViewModel?.dataArray = dataArray
        }
        self.objVM.page = 1
        self.objVM.city = dict["city"] as? String ?? ""
        self.objVM.country = dict["country"] as? String ?? ""
        self.objVM.state = dict["state"] as? String ?? ""
       // self.objVM.latitude = dict["latitude"] as? String ?? ""
      //  self.objVM.longitude = dict["longitude"] as? String ?? ""

        self.objVM.getSearchItemApi(srchTxt: srchTxt)
    }
}


#Preview {
    SearchWithSortView(categroryId: 0, navigationController: nil, categoryName: "",categoryIds:"")
}


struct CustomBottomSheet<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack {
            Spacer()
            content
                .frame(height: UIScreen.main.bounds.height * 0.45)
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
                .shadow(radius: 5)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}



//extension SearchWithSortView {
    
//    func getCustomFieldsListApi(category_ids:String){
//        let url = Constant.shared.getCustomfields + "?category_ids=\(category_ids)"
//        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: url) { (obj:CustomFieldsParse) in
//            
//            if obj.data != nil {
//                dataArray = obj.data
//            }
//        }
//    }
  /*  func refreshScreen() {
       // print(self.objViewModel?.dataArray)
        self.dataArray.removeAll()
        
        //self.dataArray.append(contentsOf: [CustomFields(),CustomFields(),CustomFields(),CustomFields()])
        for ind in 0..<4 {
            let obj = CustomField(id: ind, name: "", type: .none, image: "", customFieldRequired: nil, values: nil, minLength: nil, maxLength: 0, status: 0, value: nil, customFieldValue: nil, arrIsSelected: [], selectedValue: nil)
            self.dataArray.append(obj)
        }
        
        for objCustomField in self.objViewModel?.dataArray ?? [] {
            if objCustomField.type == .radio || objCustomField.type  ==  .checkbox || objCustomField.type  == .dropdown{
                self.dataArray.append(objCustomField)
            }
        }
        
        tblView.reloadData()
        tblView.performBatchUpdates(nil) { _ in
            self.tblView.beginUpdates()
            self.tblView.endUpdates()
        }

        
    }*/
//}
