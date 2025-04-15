//
//  SearchProductView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/02/25.
//

/*
 Item(image: "ipad_mini", price: "\u{20B9}12000.0", title: "Ipad mini 5th generation 64gb", location: "Delhi, Delhi, India"),
 Item(image: "samsung_tab", price: "\u{20B9}12000.0", title: "SAMSUNG GALAXY TAB 3 T211 TABLET", location: "Mayur Vihar, New Delhi, Delhi, India"),
 Item(image: "oppo_f23", price: "\u{20B9}12000.0", title: "OPPO f23 5G. 8+256", location: "Kundli, Sonipat, Haryana, India"),
 Item(image: "samsung_a9", price: "\u{20B9}12000.0", title: "Samsung a9 4&64 storage", location: "Sector 122, Noida, Uttar Pradesh, India")
 */

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

    var body: some View {
        VStack{
        HStack {
         
            Button(action: {
                // Action to go back
                navigation?.popViewController(animated: true)
            }) {
                Image("arrow_left").renderingMode(.template)
                    .foregroundColor(.black).padding(5)
            }
            Text("Search").font(.custom("Manrope-Bold", size: 20.0))
                .foregroundColor(.black)
            
            Spacer()
        }.frame(height: 44).padding(.horizontal)
            
            HStack {
                HStack{
                    Image("search").resizable().frame(width: 20,height: 20).padding(.leading,10)
                    TextField("Search any item...", text: $searchText).tint(.orange)
                        .frame(height: 45)
                        .background(Color.white).padding(.trailing,10).tint(Color(hex: "#FF9900"))
                }.background(Color.white).frame(height: 45).overlay {
                    RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
                }
                
                Button(action: {
                    /* Filter action */
                    if let vc = StoryBoard.postAdd.instantiateViewController(identifier: "FilterVC") as? FilterVC {
                        vc.delFilterSelected = self
                        self.navigation?.pushViewController(vc, animated: true)
                    }
                }) {
                    ZStack{
                        
                    Image("filter")
                            .foregroundColor(.orange)
                    }.frame(width: 50,height: 45).overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    }.background(Color.white)
                }.padding(.leading,10)
            }.padding(.leading,10)
            .padding(.horizontal,10)
            
            Text("Searched Items")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top, 5)
                .frame(maxWidth: .infinity, alignment: .leading)
       
     
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(items) { item in
                       // ItemRow(item: item)
                        FavoritesCell(itemObj: item).onTapGesture {
                            let hostingController = UIHostingController(rootView: ItemDetailView(navController:  AppDelegate.sharedInstance.navigationController, itemId: item.id ?? 0,isMyProduct:false))
                            AppDelegate.sharedInstance.navigationController?.pushViewController(hostingController, animated: true)
                        }

                    }
                }.padding([.leading,.trailing],10)
                
                // Add a marker at the bottom
                GeometryReader { geo -> Color in
                    DispatchQueue.main.async {
                        let frame = geo.frame(in: .global)
                        let screenHeight = UIScreen.main.bounds.height
                        isAtBottom = frame.maxY < screenHeight + 20
                    }
                    return Color.clear
                }
                .frame(height: 1)
            }
        }.background(Color(UIColor.systemGray6)).navigationBarHidden(true).onAppear {
            
            if (navigateToFilterScreen){
                if let vc = StoryBoard.postAdd.instantiateViewController(identifier: "FilterVC") as? FilterVC {
                    vc.delFilterSelected = self
                    vc.isPushedFromHome = navigateToFilterScreen
                    self.navigation?.pushViewController(vc, animated: false)
                }
                navigateToFilterScreen = false
            }else{
                self.getProductListApi()
            }
        }
        .onChange(of: isAtBottom) { atBottom in
                    if atBottom {
                        print("Scrolled to bottom!")
                        // You can trigger your 'load more' logic here
                        if isDataLoading == false {
                            self.getProductListApi()
                        }
                    }
                }

    }
    
    func getProductListApi(){
        isDataLoading = true
        var strUrl = ""
        if dictCustomFields.keys.count == 0 {
            strUrl = "\(Constant.shared.get_item)?page=\(page)&sort_by=popular_items"
        }else {
            strUrl = "\(Constant.shared.get_item)"
            
            for (ind,key) in dictCustomFields.keys.enumerated(){
                // for ind in 0..<keys.count {
                //let key = keys[ind] as? String ?? ""
                if ind == 0 {
                    strUrl = strUrl + "?\(dictCustomFields[key] ?? "")"
                }else {
                    strUrl = strUrl + "&\(dictCustomFields[key] ?? "")"
                }
            }
        }
        
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

extension SearchProductView: FilterSelected{
    func filterSelectectionDone(dict:Dictionary<String,Any>) {
        print(dict)
        self.page = 1
        self.dictCustomFields = dict
        self.getProductListApi()
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

