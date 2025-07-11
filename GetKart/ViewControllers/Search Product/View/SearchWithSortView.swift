//
//  SearchWithSortView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 15/04/25.
//

import SwiftUI

struct SearchWithSortView: View {
   
    private var navigationController:UINavigationController?
    @State private var isGridView = true
    @State private var categoryName = ""
    @State private var categoryImage = ""
    @State private var srchTxt = ""
    @StateObject private var objVM: SearchViewModel
    @State private var newFieldArray:[CustomField]?
    @State  private var isByDefaultOpenSearch:Bool
    @State  private var isByDefaultOpenFilter:Bool

    init(categroryId: Int,navigationController:UINavigationController?,categoryName:String,categoryIds:String,categoryImg:String,pushToSuggestion:Bool = false,pushToFilter:Bool = false) {
        self.categoryName = categoryName
        self.isByDefaultOpenSearch = pushToSuggestion
        self.isByDefaultOpenFilter = pushToFilter
        self.categoryImage = categoryImg
        self.navigationController = navigationController
        
        _objVM = StateObject(wrappedValue: SearchViewModel(catId: categroryId, categoryIds: categoryIds))

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
        
            .onAppear{
                objVM.isDataLoading = false

                if isByDefaultOpenSearch{
                    pushToSearchSuggestionScreen()
                }
                
                if (newFieldArray?.count ?? 0) == 0{
                    getCustomFieldsListApi(category_ids: objVM.categroryId)
                }
            }
        
        VStack {
            HStack {
                ZStack{
                    HStack{
                        Image("search").renderingMode(.template)
                            .foregroundColor(.gray)
                            .padding(.leading,10)
                        TextField("Search any item...", text: $srchTxt).frame(height:40)
                            .background(Color(.systemGray6))
                           // .cornerRadius(6)
                            .tint(Color(Themes.sharedInstance.themeColor))
                        
                    }.background(Color(.systemGray6))
                        //.cornerRadius(6)
                       
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.separator), lineWidth: 1)
                        ).clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.leading,10)
                    
                    // Transparent Button over HStack
                    Button(action: {
                        pushToSearchSuggestionScreen()
                    }) {
                        Color.clear
                    }
                    .contentShape(Rectangle()) // Makes the entire frame tappable
                    
                }
                Spacer()
                // Toggle button
                Button(action: {
                    isGridView.toggle()
                }) {
                    
                    let strImg = isGridView ? "list_view" : "grid_view"
                    
                    Image(strImg).renderingMode(.template)
                        .tint(Color(UIColor.label))

                }.tint( Color(UIColor.label) )
                    .background(Color(.systemGray6))
                   
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.separator), lineWidth: 1)
                    ).clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.trailing,7)

            }.frame(height:50).background(Color(.systemBackground))
                .padding(.top,1)
            
            //Filter and load items
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    let countStr = getFilterAppliedCount()
                    FilterChip(title: "Filters\(countStr)", icon: "Settings-adjust",isBorder:false)
                    {selIndx in
                        
                    }.onTapGesture {
                        
                        pushToFilterScreen(selIndex: 0)
                        
                    }
                    
                    ForEach(Array((newFieldArray ?? []).enumerated()), id: \.element.id) { index, field in
                        
                        filterChipView(for: field, at: index)
                    }
                }
                .padding(.horizontal)
                .padding([.bottom,.top], 5)
            }
            .background(Color(.systemGray5))
            
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
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        Color.clear.id("top") // <-- ID to scroll to
                        if isGridView {
                            gridView
                        } else {
                            listView
                        }
                    }
                    
                    .onChange(of: objVM.shouldScrollToTop) { shouldScroll in
                        if shouldScroll {
                            scrollProxy.scrollTo("top", anchor: .top)
                            objVM.shouldScrollToTop = false
                        }
                    }
                }
            }
            
        }.background(Color(UIColor.systemGray6))
            .navigationBarHidden(true)
    }
    
    
    @ViewBuilder
     func filterChipView(for field: CustomField, at index: Int) -> some View {
        let title = field.name ?? ""
        let isBorder = (field.selectedMaxValue ?? 0) > 0 || (field.value?.count ?? 0) > 0

        FilterChip(title: title, isBorder: isBorder, index: index) { selIndx in
            
            self.newFieldArray?[selIndx].value?.removeAll()
            self.newFieldArray?[selIndx].selectedMaxValue = nil
            self.newFieldArray?[selIndx].selectedMinValue = nil
            self.objVM.dictCustomFields.removeValue(forKey: "\(field.id ?? 0)")
          
            if self.newFieldArray?[selIndx].type == .sortby{
                self.objVM.dictCustomFields.removeValue(forKey: "sort_by")
            }
            self.objVM.page = 1
            self.objVM.getSearchItemApi(srchTxt: srchTxt)
        }
        .onTapGesture {
            pushToFilterScreen(selIndex: index)
        }
    }

    
    func pushToFilterScreen(selIndex:Int){
        
        let filterView = FilterView(navigation:self.navigationController,categoryId: objVM.categroryId,categImg: self.categoryImage,categoryName: categoryName,filterDict: objVM.dictCustomFields,fieldArray: newFieldArray,onApplyFilter: { filterDict, filterFieldsArr in
            objVM.page = 1
            newFieldArray = filterFieldsArr
            objVM.dictCustomFields = filterDict
            self.objVM.getSearchItemApi(srchTxt: srchTxt)
            
        }, selectedIndex:selIndex)
        
        let hostingVC = UIHostingController(rootView: BottomSheetHost(content: filterView))

        
        if let sheet = hostingVC.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom(resolver: { context in
                    context.maximumDetentValue * 0.85
                })]
            } else {
                sheet.detents = [.large()]
            }
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        self.navigationController?.present(hostingVC, animated: true)
    }
    
    func pushToSearchSuggestionScreen(){
        
        let swiftUIView = SearchProductView(navigation:self.navigationController,onSelectSuggestion: { search in
            
            self.objVM.page = 1
            self.categoryName = search.categoryName ?? ""
            self.categoryImage = search.categoryImage ?? ""
            self.srchTxt = search.keyword ?? ""
            self.objVM.categroryId = "\(search.categoryID ?? 0)"
            self.objVM.categoryIds = "\(search.categoryID ?? 0)"
            self.objVM.dictCustomFields.removeAll()
            self.objVM.dictCustomFields["category_id"] =  "\(search.categoryID ?? 0)"
            self.getCustomFieldsListApi(category_ids: "\(search.categoryID ?? 0)")
            self.objVM.getSearchItemApi(srchTxt:srchTxt)
        }, isToCloseToHomeScreen:self.isByDefaultOpenSearch)
        let hostingController = UIHostingController(rootView: swiftUIView) // Wrap in UIHostingController
        self.navigationController?.pushViewController(hostingController, animated: true)
        self.isByDefaultOpenSearch = false
    }
    
    func pushToDetailScreen(id:Int,item:ItemModel){
        objVM.isDataLoading = true
        
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
    
    
    func getFilterAppliedCount() -> String {
        var count = 0
        for field in newFieldArray ?? [] {
            if field.type != .category {
                if (field.selectedMaxValue ?? 0) > 0 || (field.value?.count ?? 0) > 0 {
                    count += 1
                }
            }
        }
        return count > 0 ? " (\(count))" : ""
    }
}


#Preview {
    SearchWithSortView(categroryId: 0, navigationController: nil, categoryName: "",categoryIds:"", categoryImg: "")
}





extension SearchWithSortView {
    
    func getCustomFieldsListApi(category_ids:String){
        
       let city = Local.shared.getUserCity()
       let country = Local.shared.getUserCountry()
       let  state = Local.shared.getUserState()
    
        var latitude = ""
        var longitude = ""

        if state.count > 0 || state.count > 0{
            latitude = Local.shared.getUserLatitude()
            longitude = Local.shared.getUserLongitude()
        }
        
      
        
        var strUrl = Constant.shared.getFilterCustomfields + "?category_ids=\(category_ids)"
        
        
//        let categoryId = category_ids.components(separatedBy: ",")
//        
//        if categoryId.count > 0{
//            if let strCatId = categoryId.last{
//                strUrl = Constant.shared.getFilterCustomfields + "?category_ids=\(strCatId)"
//            }
//        }
//            
        if city.count > 0{
            strUrl.append("&city=\(city)")
        }
        
        if state.count > 0{
            strUrl.append("&state=\(state)")
        }
        
        if country.count > 0{
            strUrl.append("&country=\(country)")
        }
        
        if latitude.count > 0 && (state.count > 0 || city.count > 0){
            strUrl.append("&latitude=\(latitude)")
        }
        
        if longitude.count > 0 && (state.count > 0 || city.count > 0){
            strUrl.append("&longitude=\(longitude)")
        }
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl) {
            (obj:CustomFieldsParse) in
            
            if obj.data != nil {
                self.newFieldArray = obj.data ?? []
                    
//                if category_ids.count > 0{
//                    let objCategory = CustomField(id: 123323, name: "Category", type: .category, image: "", customFieldRequired: nil, values: nil, minLength: nil, maxLength: 0, status: 0, value: nil, customFieldValue: nil, arrIsSelected: [], selectedValue: nil)
//                    self.newFieldArray?.insert(objCategory, at: 0)
//                }
//                
                let objSortBY = CustomField(id: 345676, name: "Sort By", type: .sortby, image: "", customFieldRequired: nil, values: [
                   // "Default",
                    "New to Old",
                    "Old to New",
                    "Price High to Low",
                    "Price Low to High"
                ], minLength: nil, maxLength: 0, status: 0, value: nil, customFieldValue: nil, arrIsSelected: [], selectedValue: nil,ranges: [])
                self.newFieldArray?.append(objSortBY)
                
                if isByDefaultOpenFilter{
                    pushToFilterScreen(selIndex: 0)
                    isByDefaultOpenFilter = false
                }
            }
        }
    }
    
}



struct FilterChip: View {
    let title: String
    var icon: String? = nil
    let isBorder:Bool
    var index:Int? = nil
    var getSelectedRemoveIndex: (Int) -> Void
    

    var body: some View {
        HStack {
            if let icon = icon {
               
                Image(icon).renderingMode(.template).foregroundColor(.gray)
                Text(title)
                
            }else{
                Text(title)
                if isBorder{
                    Button {
                        
                        getSelectedRemoveIndex(index ?? 0)

                    } label: {
                        Image("close-small").renderingMode(.template).foregroundColor(.gray)
                    }
                }else{
                    Image("arrow_dd").renderingMode(.template).foregroundColor(.gray)
                }
            }
            
        }.padding(8).frame(height: 30)
            .font(.caption)
            .background(isBorder ? Color.orange.opacity(0.1) : Color(.systemGray6))
            .foregroundColor(Color(.label))
            .cornerRadius(7)
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(((icon?.count ?? 0) > 0) ? Color.clear : (isBorder ? Color.orange : Color(.lightGray)), lineWidth: 1)
            )
    }
}




struct BottomSheetHost: View {
    let content: FilterView

    var body: some View {
        
        if #available(iOS 16.0, *) {
            
            content//.padding(.top, 10)
                .presentationDetents([.fraction(0.8)]) // iOS 16+
                .presentationDragIndicator(.visible)
                .ignoresSafeArea(.container, edges: .bottom)

        }else{
            content//.padding(.top, 10)
                .ignoresSafeArea(.container, edges: .bottom)

        }
    }
}
