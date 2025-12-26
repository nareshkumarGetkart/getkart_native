//
//  SearchBoardResultView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 12/12/25.
//

import SwiftUI

struct SearchBoardResultView: View {
    let navigationController:UINavigationController?
    @State  var isByDefaultOpenSearch:Bool
    @State private var selected = "All"
    @State private var selectedCategoryId = 0
    @State private var listArray:Array<ItemModel> = [ItemModel]()
    @State private var page = 1
    @State private var isDataLoading = true
    @State private var searchText = ""

    
  /*  let sampleProducts: [Product] = [
        Product(title: "Lakmé Foundation",
                subtitle: "Lakmé 9 to 5 Complexion Care Face Cream Foundation",
                price: "402",
                image: "https://d3se71s7pdncey.cloudfront.net/getkart/v1/chat/2025/08/6892f2a328ee10.794870231754460835.png",
                isSponsored: true,
                likes: 215,
                imageHeight: 200),
        
        Product(title: "Gabriel - elegant shoes",
                subtitle: "Our items are ideal for every occasion",
                price: "7,327.95",
                image: "https://d3se71s7pdncey.cloudfront.net/getkart/v1/chat/2025/08/6892f2a328ee10.794870231754460835.png",
                isSponsored: true,
                likes: 215,
                imageHeight: 180),
        
        Product(title: "Luminize (Skin Glow)",
                subtitle: "Achieve radiant skin with a glutathione formula",
                price: "1,230",
                image: "https://d3se71s7pdncey.cloudfront.net/getkart/v1/chat/2025/08/6892f2a328ee10.794870231754460835.png",
                isSponsored: true,
                likes: 215,
                imageHeight: 200),
        
        Product(title: "Black Two-Piece Suit",
                subtitle: "Trending Modern Prom Suit Styles",
                price: "4,202",
                image: "https://d3se71s7pdncey.cloudfront.net/getkart/v1/chat/2025/08/6892f2a328ee10.794870231754460835.png",
                isSponsored: true,
                likes: 215,
                imageHeight: 180),
    ]
*/
    
    var body: some View {
        VStack(spacing: 0) {
            
            VStack{
                // MARK: - Top Row (Time, Icons)
                HStack {
                    
                    Button {
                        navigationController?.popViewController(animated: true)
                        
                    } label: {
                        Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
                    }.frame(width: 40,height: 40)
                    
                    
                    
                    // MARK: - Search Bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.orange)
                        
                        TextField("Search any item...", text: .constant(searchText))
                            .textFieldStyle(PlainTextFieldStyle()).disabled(true)
                        
                    }   .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .background(Color(UIColor.systemBackground)).cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 0.5)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .onTapGesture {
                            
                            let hostingVC = UIHostingController(rootView: SearchBoardView(searchText:searchText, navigationController: self.navigationController,searchedItem: { srchTxt in
                                
                                if searchText != srchTxt{
                                    searchText = srchTxt
                                }
                            }))
                            self.navigationController?.pushViewController(hostingVC, animated: false)
                            
                        }
                    
                    Button {
                        print("Scan tapped")
                        navigationController?.popViewController(animated: true)
                        
                    } label: {
                        Text("Cancel")
                            .font(.title3)
                            .foregroundColor(Color(.label))
                    }
                }
                .padding(.horizontal)
                
                
                
                CategoryTabs(selected: $selected, selectedCategoryId: $selectedCategoryId)
                //.padding([.top,.bottom], 7)
                
            } .background(Color(.systemBackground))
            
            if listArray.count == 0 && !isDataLoading {
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
                
            ScrollView(showsIndicators: false) {
                StaggeredGrid(columns: 2, spacing: 5) {
                    ForEach(Array(listArray.enumerated()), id: \.element.id) { index, product in
                        ProductCardStaggered(
                            product: product,
                            imgHeight: CGFloat(150 + (index % 2) * 50)
                        ) { isLiked, boardId in
                            
                            print("Liked:", isLiked, "BoardId:", boardId)
                            
                            if let index = listArray.firstIndex(where: { $0.id == boardId }) {
                                listArray[index].isLiked = isLiked
                            }
                        }
                        .onTapGesture {
                            pushToDetailScreen(item:product)
                        }.onAppear{
                            if let lastItem = listArray.last, lastItem.id == product.id {
                                //   self.getBoardListApi()
                            }
                        }
                    }
                    
                }
                .padding(5)
            }
        }
            // CustomTabBar()
        }
        .background(Color(.systemGray6))
        //.edgesIgnoringSafeArea(.bottom)
        .onAppear {
            if listArray.isEmpty && !isByDefaultOpenSearch{
                getBoardListApi()
            }
        }.onChange(of: selectedCategoryId) { _ in
            self.page = 1
            getBoardListApi()
        }
        .onAppear{
            if isByDefaultOpenSearch{
                let hostingVC = UIHostingController(rootView: SearchBoardView(navigationController: self.navigationController,isToCloseToSearchResultScreen:isByDefaultOpenSearch,searchedItem: { srchTxt in
                    if searchText != srchTxt{
                        searchText = srchTxt
                    }
                }))
                self.navigationController?.pushViewController(hostingVC, animated: true)
                isByDefaultOpenSearch = false
            }
        }
    }
    
    func pushToDetailScreen(item:ItemModel){
        let hostingVC = UIHostingController(rootView: BoardDetailView(navigationController:self.navigationController, itemObj: item))
        self.navigationController?.pushViewController(hostingVC, animated: true)
    }
    
    
    
    //MARK: Api methods
    func getBoardListApi(){
        
        if self.page == 1{
            self.listArray.removeAll()
        }

        let strUrl = Constant.shared.get_public_board + "?page=\(page)&search=\(searchText)&category_id=\(selectedCategoryId > 0 ? "\(selectedCategoryId)" : "")"

        self.isDataLoading = true
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl,loaderPos: .mid) { (obj:ItemParse) in
            
            if obj.code == 200 {
                

                if obj.data != nil , (obj.data?.data ?? []).count > 0 {
                    self.listArray.append(contentsOf:  obj.data?.data ?? [])
                }
                                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.isDataLoading = false
                    self.page += 1
                })

            }else{
                self.isDataLoading = false

            }
        }
    }
}

//#Preview {
//    SearchBoardResultView(navigationController: nil)
//}
