//
//  SearchProductView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/02/25.
//


import SwiftUI

struct SearchProductView: View {
    
    var navigation:UINavigationController?
    @State private var searchText = ""
    @State var items = [ItemModel]()
    @State var dictCustomFields:Dictionary<String,Any> = [:]
    @State var page = 1
    @State var isDataLoading = false
    @State var isAtBottom = false
    @State var navigateToFilterScreen = false
    @State var dataArray:Array<CustomField> = Array()
    @State var strCategoryTitle = ""
   
    var body: some View {
       
        VStack {
            HStack {
                Button(action: {
                    navigation?.popViewController(animated: true)
                }) {
                    Image("arrow_left")
                        .renderingMode(.template)
                        .foregroundColor(Color(.label)) // Adapt to dark/light
                        .padding(5)
                }
                Text("Search")
                    .font(.custom("Manrope-Bold", size: 20.0))
                    .foregroundColor(Color(.label))
                Spacer()
            }
            .frame(height: 44)
            .padding(.horizontal)

            HStack {
                HStack {
                    Image("search")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.leading, 10)

                    TextField("Search any item...", text: $searchText)
                        .tint(Color.orange)
                        .frame(height: 45)
                        .submitLabel(.search)
                        .onSubmit {
                            self.page = 1
                            self.getProductListApi(searchTxt: searchText)
                        }
                        .background(Color(.systemBackground)) // Adaptive
                        .padding(.trailing, 10)
                }
                .background(Color(.systemBackground)) // Adaptive
                .frame(height: 45)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.separator), lineWidth: 1)
                )

                Button(action: {
                    if let vc = StoryBoard.postAdd.instantiateViewController(identifier: "FilterVC") as? FilterVC {
                        vc.dataArray = self.dataArray
                        vc.dictCustomFields = self.dictCustomFields
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
                }
                .padding(.leading, 10)
            }
            .padding(.horizontal, 10)

            let strHeader = (searchText.count == 0) ? "Popular Items" : "Searched Items"
            Text(strHeader)
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 5)
                .frame(maxWidth: .infinity, alignment: .leading)

            if items.count == 0 {
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
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach($items) { $item in
                            FavoritesCell(itemObj: $item)
                                .onTapGesture {
                                    let hostingController = UIHostingController(rootView: ItemDetailView(navController: self.navigation, itemId: item.id ?? 0, itemObj: item, isMyProduct: false, slug: item.slug))
                                    self.navigation?.pushViewController(hostingController, animated: true)
                                }
                        }
                    }
                    .padding(.horizontal, 10)

                    GeometryReader { geo -> Color in
                        DispatchQueue.main.async {
                            let frame = geo.frame(in: .global)
                            let screenHeight = UIScreen.main.bounds.height
                            isAtBottom = frame.maxY < screenHeight + 20
                        }
                        return Color.clear
                    }
                    .frame(height: 1)

                    if isDataLoading {
                        ProgressView()
                            .padding()
                    }
                }
            }
        }
        .background(Color(.systemGroupedBackground)) // Adaptive background
        .navigationBarHidden(true)
        .onAppear {
            if navigateToFilterScreen {
                if let vc = StoryBoard.postAdd.instantiateViewController(identifier: "FilterVC") as? FilterVC {
                    vc.delFilterSelected = self
                    vc.isPushedFromHome = navigateToFilterScreen
                    self.navigation?.pushViewController(vc, animated: false)
                }
                navigateToFilterScreen = false
            } else {
                self.getProductListApi(searchTxt: searchText)
            }
        }
        .onChange(of: isAtBottom) { atBottom in
            if atBottom && isDataLoading == false {
                self.getProductListApi(searchTxt: searchText)
            }
        }


    }
    
    func getProductListApi(searchTxt:String){
        isDataLoading = true
        var strUrl = ""
      
        if dictCustomFields.keys.count == 0 {
            strUrl = "\(Constant.shared.get_item)?page=\(page)&sort_by=popular_items"
        }else {
            strUrl = "\(Constant.shared.get_item)?page=\(page)"
            
            for (ind,key) in dictCustomFields.keys.enumerated(){
                // for ind in 0..<keys.count {
                //let key = keys[ind] as? String ?? ""
//                if ind == 0 {
//                    strUrl = strUrl + "?\(dictCustomFields[key] ?? "")"
//                }else {
                  //  strUrl = strUrl + "&\(dictCustomFields[key] ?? "")"
               // }
                if let value = dictCustomFields[key]{
                   
                    strUrl += "&\(key)=\(value)"
                }
            }
        }
        
        
        if searchTxt.count > 0{
            strUrl.append("&search=\(searchTxt)")
        }
        
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: false, url: strUrl) { (obj:ItemParse) in

            if self.page == 1{
                self.items = obj.data?.data ?? []

            }else{
                self.items.append(contentsOf: (obj.data?.data)!)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.isDataLoading = false
                self.page = (self.page) + 1
            })
        }
    }
    
}

extension SearchProductView: FilterSelected{
    func filterSelectectionDone(dict:Dictionary<String,Any>, dataArray:Array<CustomField>, strCategoryTitle:String) {
        print(dict)
        self.page = 1
        self.dictCustomFields = dict
        self.dataArray = dataArray
        self.strCategoryTitle = strCategoryTitle
        self.getProductListApi(searchTxt: searchText)
    }
}

#Preview {
    SearchProductView()
}



struct Item: Identifiable {
    let id = UUID()
    let image: String
    let price: String
    let title: String
    let location: String
}

struct ItemRow: View {
    let item: Item
    
    var body: some View {
        HStack {
            Image(item.image) // Replace with actual asset names
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .cornerRadius(10)
            
            VStack(alignment: .leading) {
                Text(item.price)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#FF9900"))
                Text(item.title)
                    .font(.body)
                    .lineLimit(1)
                Text(item.location)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            
            Button(action: { /* Favorite action */ }) {
                Image(systemName: "heart")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 2)
        .padding(.horizontal)
    }
}

