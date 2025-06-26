//
//  SearchProductView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/02/25.
//


import SwiftUI




struct SearchProductView: View {
 
    var navigation:UINavigationController?
    @State private var isAtBottom = false
    @State var navigateToFilterScreen = false
    @State var strCategoryTitle = ""
    @StateObject private var viewModel = ProductSearchViewModel()
    @FocusState private var isFocused: Bool

    var onSelectSuggestion: (Search) -> Void

    var body: some View {
       
        VStack {
           /* HStack {
                Button(action: {
                    navigation?.popViewController(animated: true)
                }) {
                    Image("arrow_left")
                        .renderingMode(.template)
                        .foregroundColor(Color(.label))
                        .padding(5)
                }
                Text("Search")
                    .font(.custom("Manrope-Bold", size: 20.0))
                    .foregroundColor(Color(.label))
                Spacer()
            }
            .frame(height: 44)
            .padding(.horizontal)
*/
            HStack {
          
                VStack{
                    
                    HStack{
                        
                        Button(action: {
                            navigation?.popViewController(animated: true)
                        }) {
                            Image("Cross")
                                .renderingMode(.template)
                                .foregroundColor(Color(.label))
                                .padding(5)
                        }.padding(.leading,8)
                        
                        
                        HStack {
                            Image("search")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(.leading, 10)
                            
                            TextField("Search any item...", text: $viewModel.searchText)
                                .focused($isFocused) // bind focus to this field
                                .tint(Color.orange)
                                .frame(height: 45)
                                .submitLabel(.done)
                                .background(Color(.systemBackground))
                                .padding(.trailing, 10)
                                .onSubmit {
                                    if  viewModel.searchText.count > 0{
                                        onSelectSuggestion(Search(categoryID: 0, categoryName: "", categoryImage: "", keyword:  viewModel.searchText))
                                        self.navigation?.popViewController(animated: false)
                                }
                                }
                        }
                        .background(Color(.systemBackground))
                        .frame(height: 45)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.separator), lineWidth: 1)
                        ).clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    HStack{
                        HStack{
                            Image("location_icon_orange")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(.leading, 10)

                            Text(getLocation())
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemBackground))
                                .frame(height: 45)
                                .padding(.trailing, 10)
                        }.background(Color(.systemBackground))
                            .frame(height: 45)
                            .frame(maxWidth: .infinity) // Makes HStack full-width

                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.separator), lineWidth: 1)
                            ).clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        
                    }.padding(.leading,47)
                
                }.padding(.horizontal, 10).padding(.bottom)
                    .onAppear{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isFocused = true
                        }
                    }

               /* Button(action: {
                    if let vc = StoryBoard.postAdd.instantiateViewController(identifier: "FilterVC") as? FilterVC {
                        vc.dataArray = self.viewModel.dataArray
                        vc.dictCustomFields = self.viewModel.dictCustomFields
                        vc.strCategoryTitle = self.strCategoryTitle
                        vc.delFilterSelected = self
                        self.navigation?.pushViewController(vc, animated: true)
                    }
                }) {
                    Image("filter")
                        .renderingMode(.template)
                        .foregroundColor(.orange)
                        .frame(width: 50, height: 45)
                        .background(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.separator), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                }
                .padding(.leading, 10)
                .clipped()*/
            }.background(Color(.systemBackground))
            

//            let strHeader = (viewModel.searchText.count == 0) ? "Popular Ads" : "Searched Ads"
//            Text(strHeader)
//                .font(.headline)
//                .padding(.horizontal)
//                .padding(.top, 5)
//                .frame(maxWidth: .infinity, alignment: .leading)

            if viewModel.items.count == 0  && !viewModel.isDataLoading{
                HStack {
                    Spacer()
                    VStack(spacing: 20) {
                        Spacer()
                        Image("no_data_found_illustrator")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 150, height: 150)
                            .padding()
                        Text("No Data Found")
                            .foregroundColor(.orange)
                            .font(Font.manrope(.medium, size: 20.0))
                            .padding(.top)
                            .padding(.horizontal)
                        Text("We're sorry what you were looking for. Please try another way")
                            .font(Font.manrope(.regular, size: 16.0))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Spacer()
                    }
                    Spacer()
                }
            } else {
               // ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(spacing: 0) {
                        
                        
                        ForEach(Array(viewModel.items.enumerated()), id: \.offset) { index, item in
                        
                            SearchSuggestionCell(title: item.keyword ?? "",categoryTitle:item.categoryName ?? "")
                                .onTapGesture {
                                    onSelectSuggestion(item)
                                    self.navigation?.popViewController(animated: false)
                            }
                        
                            /*   ForEach($viewModel.items) { $item in
                            
                            
                         FavoritesCell(itemObj: $item).id(item.id)
                                .onTapGesture {
                                    var swiftVw = ItemDetailView(navController: self.navigation, itemId: item.id ?? 0, itemObj: item, isMyProduct: false, slug: item.slug)
                                    
                                    swiftVw.returnValue = { value in
                                        
                                        if let obj = value{
                                            self.updateItemInList(obj)
                                        }
                                    }
                                    let hostingController = UIHostingController(rootView: swiftVw)

                                    self.navigation?.pushViewController(hostingController, animated: true)
                                }*/
                        }
                    }
                    .padding(.horizontal, 10)

//                    GeometryReader { geo -> Color in
//                        DispatchQueue.main.async {
//                            let frame = geo.frame(in: .global)
//                            let screenHeight = UIScreen.main.bounds.height
//                            isAtBottom = frame.maxY < screenHeight + 20
//                        }
//                        return Color.clear
//                    }
//                    .frame(height: 1)

                    if viewModel.isDataLoading {
                        ProgressView()
                            .padding()
                    }
                }
                .simultaneousGesture(
                    DragGesture().onChanged { _ in
                        UIApplication.shared.endEditing()
                    }
                )
                
//                .onChange(of: viewModel.shouldScrollToTop) { shouldScroll in
//                    if shouldScroll {
//                        withAnimation {
//                            if let id =  viewModel.items.first?.id{
//                                scrollProxy.scrollTo(id, anchor: .top)
//                            }
//                        }
//                        viewModel.shouldScrollToTop = false
//                    }
//                }
           // }
                
               
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
//        .onAppear {
//            if navigateToFilterScreen {
//                if let vc = StoryBoard.postAdd.instantiateViewController(identifier: "FilterVC") as? FilterVC {
//                    vc.delFilterSelected = self
//                    vc.isPushedFromHome = navigateToFilterScreen
//                    self.navigation?.pushViewController(vc, animated: false)
//                }
//                navigateToFilterScreen = false
//            }
//        }
//        .onChange(of: isAtBottom) { atBottom in
//            if atBottom && self.viewModel.isDataLoading == false {
//            
//                self.viewModel.getProductListApi(source:.pagination,searchTxt: viewModel.searchText)
//            }
//        }
    }
    
//    private func updateItemInList(_ value: ItemModel) {
//        if let index = $viewModel.items.firstIndex(where: { $0.id == value.id }) {
//            viewModel.items[index] = value
//        }
//    }
    
    func getLocation()->String{
        let city = Local.shared.getUserCity()
        let country = Local.shared.getUserCountry()
        let state = Local.shared.getUserState()
        
        var locStr = "\(city) \(state) \(country)"

        if city.count == 0 && state.count == 0{
            locStr = "All India"
        }else  if city.count == 0 && state.count > 0{
            locStr = "All \(state)"

        }
            
        return locStr
    }
}

//extension SearchProductView: FilterSelected{
//    func filterSelectectionDone(dict:Dictionary<String,Any>, dataArray:Array<CustomField>, strCategoryTitle:String) {
//        print(dict)
//        self.viewModel.page = 1
//        self.viewModel.dictCustomFields = dict
//        self.viewModel.dataArray = dataArray
//        self.strCategoryTitle = strCategoryTitle
//        self.viewModel.getProductListApi(source: .filter, searchTxt: viewModel.searchText)
//    }
//    
//}

#Preview {
    SearchProductView(navigation: nil, strCategoryTitle: "", onSelectSuggestion: {_ in })
}




struct SearchSuggestionCell:View {
    let title:String
    let categoryTitle:String
    
    var body: some View {
        VStack{
            HStack{
                
                let strTitle =  (title.count == 0) ? categoryTitle : (categoryTitle.count > 0) ? "\(title) in \(categoryTitle)" : title
                
               
                Text(strTitle)
                    .font(Font.manrope(.regular, size: 16)).padding([.leading,.trailing],8).padding([.top,.bottom],10)
                Spacer()
                
            }
            Divider().background(Color(.separator))
        }.background(Color(.systemBackground))
    }
}
