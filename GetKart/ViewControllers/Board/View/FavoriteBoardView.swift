//
//  FavoriteBoardView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/12/25.
//

import SwiftUI

struct FavoriteBoardView: View {
    let navigationController:UINavigationController?
    
    @State private var listArray:Array<ItemModel> = [ItemModel]()
    @State private var page = 1
    @State private var isDataLoading = true
    
    var body: some View {
        VStack(spacing: 0) {
           
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
                            if let lastItem = listArray.last, lastItem.id == product.id , !isDataLoading{
                                self.getFavoriteBoardListApi()
                            }
                        }
                    }
                    
                }
                .padding(5)
            }.scrollIndicators(.hidden, axes: .vertical)
                .refreshable {
                    if isDataLoading == false {
                        page = 1
                        getFavoriteBoardListApi()
                    }
                }
        }
            
            // CustomTabBar()
        }
        .background(Color(.systemGray6))
        //.edgesIgnoringSafeArea(.bottom)
        .onAppear {
            if listArray.isEmpty{
                getFavoriteBoardListApi()
            }
        }
    }
    
    func pushToDetailScreen(item:ItemModel){
        let hostingVC = UIHostingController(rootView: BoardDetailView(navigationController:self.navigationController, itemObj: item))
        self.navigationController?.pushViewController(hostingVC, animated: true)
    }
    
    
    
    //MARK: Api methods
    func getFavoriteBoardListApi(){
        
        if self.page == 1{
            self.listArray.removeAll()
        }

        let strUrl = Constant.shared.get_favourite_board + "?page=\(page)"

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

#Preview {
    FavoriteBoardView(navigationController: nil)
}
