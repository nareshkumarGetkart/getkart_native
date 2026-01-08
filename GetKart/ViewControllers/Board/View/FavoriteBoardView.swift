//
//  FavoriteBoardView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/12/25.
//

import SwiftUI
/*
struct FavoriteBoardView: View {
    let navigationController:UINavigationController?
    @StateObject private var vm = FavoriteBoardViewModel()

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
*/
#Preview {
    FavoriteBoardView(navigationController: nil)
}


struct FavoriteBoardView: View {

    let navigationController: UINavigationController?
    @StateObject private var vm = FavoriteBoardViewModel()

    var body: some View {
        VStack(spacing: 0) {

            if vm.items.isEmpty && !vm.isLoading {
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
            } else {
                ScrollView {
                    LazyVStack {
                        StaggeredGrid(columns: 2, spacing: 5) {
                            //ForEach(Array(vm.items.enumerated()), id: \.offset) { index, item in
                                ForEach(Array(vm.items.enumerated()), id: \.element.id) { index, item in

                                ProductCardStaggered1(
                                    product: item,
                                   // imgHeight: CGFloat(150 + (index % 2) * 50)
                                ) { isLiked, boardId in
                                    vm.updateLike(boardId: boardId, isLiked: isLiked)
                                }.contentShape(Rectangle())
                                .onTapGesture {
                                    pushToDetailScreen(item: item)
                                }
                                .onAppear {
                                    vm.loadNextPageIfNeeded(currentIndex: index)
                                }
                            }
                        }
                        .padding(5)

                        // 👇 bottom detector (NO layout impact)
                           GeometryReader { geo in
                               Color.clear
                                   .preference(
                                       key: ScrollBottomKey.self,
                                       value: geo.frame(in: .global).maxY
                                   )
                           }
                           .frame(height: 0)
                        
                        if vm.isLoading {
                            ProgressView().padding()
                        }
                    }
                }
                .onPreferenceChange(ScrollBottomKey.self) { bottomY in
                    vm.handleScrollBottom(bottomY: bottomY)
                }
            }
        }
        .background(Color(.systemGray6))
        .onAppear {
            if vm.items.count == 0{
                vm.loadInitial()
            }
        }
        .refreshable {
            if !vm.isLoading{
                vm.loadInitial()
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: Notification.Name(NotificationKeys.refreshLikeDislikeBoard.rawValue)
            )
        ) { notification in

            guard let dict = notification.object as? [String: Any] else { return }

            let isLike  = dict["isLike"] as? Bool ?? false
            let count  = dict["count"] as? Int ?? 0
            let boardId = dict["boardId"] as? Int ?? 0

            vm.update(likeCount: count, isLike: isLike, boardId: boardId)
        }

    }
    
    func pushToDetailScreen(item:ItemModel){
        let hostingVC = UIHostingController(rootView: BoardDetailView(navigationController:self.navigationController, itemObj: item))
        self.navigationController?.pushViewController(hostingVC, animated: true)
    }
}

