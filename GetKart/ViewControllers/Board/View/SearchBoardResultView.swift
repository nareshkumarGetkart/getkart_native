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
    @State private var searchText = ""
    @State private var selected = "All"
    @StateObject private var vm = SearchBoardResultViewModel()
    @State private var paymentGateway: PaymentGatewayCentralized?

    
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
                            
                            let hostingVC = UIHostingController(rootView: SearchBoardView(searchText:searchText, navigationController: self.navigationController, searchedItem: { srchTxt in
                                
                                if searchText != srchTxt{
                                    searchText = srchTxt
                                    vm.searchText = searchText
                                    // if !vm.isLoading{
                                    vm.loadInitial()
                                    //}
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
                
                
                CategoryTabs(
                    selected: $selected,
                    selectedCategoryId: Binding(
                        get: { vm.selectedCategoryId },
                        set: { vm.categoryChanged($0) }
                    )
                )
                
            } .background(Color(.systemBackground))
            
            if vm.items.count == 0 && !vm.isLoading {
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
                
                
                ScrollView {
                    
                    
                    
                    LazyVStack {
                        StaggeredGrid(columns: 2, spacing: 5) {
                            //ForEach(Array(vm.items.enumerated()), id: \.offset) { index, item in
                            ForEach(Array(vm.items.enumerated()), id: \.element.id) { index, item in
                                
                                
                             /*   ProductCardStaggered1(
                                    product: item,
                                    // imgHeight: CGFloat(150 + (index % 2) * 50)
                                    onTapBoostButton:{
                                        paymentGatewayOpen(product: item)
                                        
                                    }
                                ) { isLiked, boardId in
                                    vm.updateLike(boardId: boardId, isLiked: isLiked)
                                }*/
                                ProductCardStaggered1(
                                    product: item,
                                    sendLikeUnlikeObject: { isLiked, boardId in
                                        vm.updateLike(boardId: boardId, isLiked: isLiked)
                                    }, onTapBoostButton: {
                                        paymentGatewayOpen(product: item)
                                    }
                                )
                                .contentShape(Rectangle())
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
        
        .onAppear{
            if isByDefaultOpenSearch{
                let hostingVC = UIHostingController(rootView: SearchBoardView(navigationController: self.navigationController, isToCloseToSearchResultScreen:isByDefaultOpenSearch,searchedItem: { srchTxt in
                    if searchText != srchTxt{
                        searchText = srchTxt
                        vm.searchText = searchText
                        if !vm.isLoading{
                            vm.loadInitial()
                        }
                    }
                }))
                self.navigationController?.pushViewController(hostingVC, animated: true)
                isByDefaultOpenSearch = false
            }
            
            //            if vm.items.count == 0 && !vm.isLoading{
            //               vm.searchText = searchText
            //               vm.loadInitial()
            //            }
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
                for: Notification.Name(NotificationKeys.boardBoostedRefresh.rawValue)
            )
        ) { notification in
           guard let dict = notification.object as? [String: Any] else { return }
            let boardId = dict["boardId"] as? Int ?? 0
            
            vm.updateBoost(isBoosted: true, boardId: boardId)
        }

    }
    
    func paymentGatewayOpen(product:ItemModel) {

        paymentGateway = PaymentGatewayCentralized()
        paymentGateway?.selectedPlanId = product.package?.id ?? 0
        paymentGateway?.categoryId = product.categoryID ?? 0
        paymentGateway?.itemId = product.id ?? 0
        paymentGateway?.paymentFor = .boostBoard
        paymentGateway?.selIOSProductID = product.package?.iosProductID ?? ""

        paymentGateway?.callbackPaymentSuccess = { (isSuccess) in

            if isSuccess {
                let vc = UIHostingController(
                    rootView: PlanBoughtSuccessView(
                        navigationController: navigationController
                    )
                )
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                navigationController?.present(vc, animated: true)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.boardBoostedRefresh.rawValue), object:  ["boardId":product.id ?? 0], userInfo: nil)

            }
            
      
               self.paymentGateway = nil
        }

        paymentGateway?.initializeDefaults()
    }
    func pushToDetailScreen(item:ItemModel){
        let hostingVC = UIHostingController(rootView: BoardDetailView(navigationController:self.navigationController, itemObj: item))
        self.navigationController?.pushViewController(hostingVC, animated: true)
    }
}

#Preview {
    SearchBoardResultView(navigationController: nil, isByDefaultOpenSearch: false)
}
