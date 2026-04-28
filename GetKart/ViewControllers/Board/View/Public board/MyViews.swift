//
//  MyViews.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 23/04/26.
//

import SwiftUI

struct MyViews: View {
    let navigationController: UINavigationController?
    @StateObject private var vm = MyViewViewModel()
    @State private var safariURL: URL?
    @State private var itemHeights: [Int: CGFloat] = [:] //  Measured heights for staggered layout
    
    var body: some View {
        HStack{
            
            Button {
                navigationController?.popViewController(animated: true)
            } label: {
                Image("arrow_left")
                    .renderingMode(.template)
                    .foregroundColor(Color(UIColor.label))
            }
            .frame(width: 40, height: 40)
            
            Text("My Views")
                .font(Font.inter(.semiBold, size: 16))
                .foregroundColor(Color(UIColor.label))
            
            Spacer()
        }
        
        VStack{
            
            if vm.items.isEmpty && !vm.isLoading {
                HStack{
                    Spacer()
                    VStack(spacing: 20){
                        Spacer()
                        Image("no_data_found_illustrator").frame(width: 150,height: 150).padding()
                        Text("No Data Found").foregroundColor(.orange).font(Font.manrope(.medium, size: 20.0)).padding(.top).padding(.horizontal)
                        Spacer()
                    }
                    Spacer()
                }
            } else {
                ScrollView {
                    
                    let columns = splitColumns()
                    
                    HStack(alignment: .top, spacing: 6) {
                        
                        // LEFT COLUMN
                        LazyVStack(spacing: 6) {
                            
                            ForEach(columns.left, id: \.id) { item in
                                
                                if item.boardType == 2 {
                                    
                                    
                                } else {
                                    CardItemView(
                                        item: item,
                                        onLike: { isLiked, boardId in
                                            vm.updateLike(boardId: boardId, isLiked: isLiked)
                                        },
                                        onTap: { pushToDetailScreen(item: item) },
                                        onTapBoostButton:{
                                            if item.boardType == 1{
                                                //Clicking on bottom prmotional
                                                if let url = URL(string:(item.outbondUrl ?? "").getValidUrl()) {
                                                    safariURL = url
                                                    
                                                }
                                            }else{
                                                //paymentGatewayOpen(product: item)
                                            }
                                            
                                        },
                                        isToShowBoostButton:false
                                    )
                                    .measureHeight(id: item.id ?? 0)
                                    .onAppear {
                                        // handlePrefetch(itemIndex: globalIndex(of: item))
                                        
                                        if let index = globalIndex(of: item){
                                            vm.loadNextPageIfNeeded(currentIndex: index)
                                        }
                                    }
                                }
                            }
                        }
                        
                        // RIGHT COLUMN
                        LazyVStack(spacing: 6) {
                            
                            ForEach(columns.right, id: \.id) { item in
                                
                                
                                if item.boardType == 2 {
                                    
                                } else {
                                    CardItemView(
                                        item: item,
                                        onLike: { isLiked, boardId in
                                            vm.updateLike(boardId: boardId, isLiked: isLiked)
                                        },
                                        onTap: { pushToDetailScreen(item: item) },
                                        onTapBoostButton:{
                                            
                                            if item.boardType == 1{
                                                //Tapped on prmotional button
                                                if let url = URL(string:(item.outbondUrl ?? "").getValidUrl()) {
                                                    
                                                    safariURL = url
                                                }
                                            }else{
                                                // paymentGatewayOpen(product: item)
                                            }
                                        },
                                        isToShowBoostButton:false
                                    )
                                    .measureHeight(id: item.id ?? 0)
                                    .onAppear {
                                        
                                        if let index = globalIndex(of: item){
                                            vm.loadNextPageIfNeeded(currentIndex: index)
                                        }
                                        //handlePrefetch(itemIndex: globalIndex(of: item))
                                    }
                                }
                            }
                        }
                    }
                    .padding([.horizontal,.top], 5)
                    
                                    
                    //
                    
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
                .onPreferenceChange(ScrollBottomKey.self) { bottomY in
                    vm.handleScrollBottom(bottomY: bottomY)
                }
            }
        }.background(Color(.systemGray6))
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
            
            .onReceive(
                NotificationCenter.default.publisher(
                    for: Notification.Name(NotificationKeys.refreshCommentCountBoard.rawValue)
                )
            ) { notification in
                
                guard let dict = notification.object as? [String: Any] else { return }
                
                let count  = dict["count"] as? Int ?? 0
                let boardId = dict["boardId"] as? Int ?? 0
                if let commentObj = dict["lastComment"] as? CommentModel {
                    vm.updateCommentCount(commentCount: count, commentObj: commentObj, boardId: boardId)
                }else{
                    vm.updateCommentCount(commentCount: count, commentObj: nil, boardId: boardId)
                }
            }
            
            .onReceive(
                NotificationCenter.default.publisher(
                    for: Notification.Name(NotificationKeys.boardBoostedRefresh.rawValue)
                )
            ) { notification in
                guard let dict = notification.object as? [String: Any] else { return }
                let boardId = dict["boardId"] as? Int ?? 0
                
                vm.updateBoost(isBoosted: true, boardId: boardId)
            }
        
    }
    
    func pushToDetailScreen(item:ItemModel){
        let hostingVC = UIHostingController(rootView: BoardDetailView(navigationController:self.navigationController, itemObj: item))
        self.navigationController?.pushViewController(hostingVC, animated: true)
    }
    
    // MARK: - Split into 2 staggered columns
    private func splitColumns() -> (left: [ItemModel], right: [ItemModel]) {
        
        var left: [ItemModel] = []
        var right: [ItemModel] = []
        
        var leftHeight: CGFloat = 0
        var rightHeight: CGFloat = 0
        
        for item in vm.items {
            let h = itemHeights[item.id ?? 0] ?? 200
            
            if leftHeight <= rightHeight {
                left.append(item)
                leftHeight += h
            } else {
                right.append(item)
                rightHeight += h
            }
        }
        return (left, right)
    }
    
    
    private func globalIndex(of item: ItemModel) -> Int? {
        vm.items.firstIndex { $0.id == item.id }
    }
}

#Preview {
    MyViews(navigationController: nil)
}

