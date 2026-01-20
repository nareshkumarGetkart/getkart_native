//
//  PublicBoardView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 08/01/26.
//

import SwiftUI
import Kingfisher
import UIKit


struct PublicBoardView: View {

    @State private var selectedCategoryId: Int = 0
    @State private var selectedName: String = ""
    let tabBarController: UITabBarController?
    @StateObject private var categoryVM = CategoryViewModel(type: 2,isToShowLoader: false)
    @StateObject private var boardStore = BoardStore()   // ✅ STORE
    @State private var loadedCategoryIds: Set<Int> = []

    var body: some View {
        VStack(spacing: 0) {
            
            headerView.background(Color(.systemBackground))
            
            
            CategoryTabsNew(
                selected: $selectedName,
                selectedCategoryId: $selectedCategoryId,
                categoryVM: categoryVM
            )        .background(Color(.systemBackground))
            
            if selectedCategoryId > 0{
         /*   TabView(selection: $selectedCategoryId) {
                
                ForEach(categoryVM.listArray ?? [], id: \.id) { cat in
                    BoardListView(
                        vm: boardStore.vm(for: cat.id ?? 0),
                        navigationController: navigationController
                    )
                    .tag(cat.id ?? 0)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .transaction { tx in
                tx.animation = nil   // 🔥 CRITICAL
            }*/
                
             ZStack {
               
                  let boardNav = tabBarController?.viewControllers?[1] as? UINavigationController
                    ForEach(categoryVM.listArray ?? [], id: \.id) { cat in
                        if loadedCategoryIds.contains(cat.id ?? 0) {

                        BoardListView(
                            vm: boardStore.vm(for: cat.id ?? 0),
                            navigationController: boardNav
                        )
                        .opacity(selectedCategoryId == cat.id ? 1 : 0)
                        .allowsHitTesting(selectedCategoryId == cat.id)
                    }
                    }
                }
                // ✅ High priority horizontal swipe gesture
                .simultaneousGesture(
                    DragGesture(minimumDistance: 15)
                        .onEnded { value in
                            let horizontal = value.translation.width
                            let vertical = value.translation.height

                            // Only trigger horizontal swipes
                            guard abs(horizontal) > abs(vertical) else { return }

                            if horizontal < -50 {
                                swipeCategory(left: true)   // next tab
                            } else if horizontal > 50 {
                                swipeCategory(left: false)  // previous tab
                            }
                        }
                )        }
           
            Spacer()
        }.onChange(of: selectedCategoryId) { newId in
            markTabLoaded(newId)
        }
        .onAppear {
            markTabLoaded(selectedCategoryId)
        }
        .background(Color(.systemGray6))
        
        // 🔥 NOTIFICATION OBSERVER HERE
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: Notification.Name(
                            NotificationKeys.refreshInterestChangeBoardScreen.rawValue
                        )
                    )
                ) { _ in
                    handleInterestRefresh()
                }
    }
    
    private func markTabLoaded(_ id: Int) {
        if !loadedCategoryIds.contains(id) {
            loadedCategoryIds.insert(id)
        }
    }

  
    // MARK: - Notification Handler
        private func handleInterestRefresh() {
            // 1️⃣ Switch tab to ALL
            selectedCategoryId = 55555
            selectedName = "All"

            // 2️⃣ Get ALL category VM
            let allVM = boardStore.vm(for: 55555)

            // 3️⃣ Refresh ONLY that VM
            Task {
                await allVM.refresh()
            }
        }
    
    private func swipeCategory(left: Bool) {
        guard let list = categoryVM.listArray,
              let currentIndex = list.firstIndex(where: { $0.id == selectedCategoryId })
        else { return }

        let newIndex = left
            ? min(currentIndex + 1, list.count - 1)
            : max(currentIndex - 1, 0)

        let newCat = list[newIndex]

        withAnimation(.easeInOut) {
            selectedCategoryId = newCat.id ?? 0
            selectedName = newCat.name ?? ""
        }
    }

}


final class BoardStore: ObservableObject {
    
    @Published private(set) var boardVMs: [Int: BoardViewModelNew] = [:]

    @MainActor
    func vm(for categoryId: Int) -> BoardViewModelNew {
        if let vm = boardVMs[categoryId] {
            return vm
        }

        let vm = BoardViewModelNew(categoryId: categoryId)
        boardVMs[categoryId] = vm
        return vm
    }
}
struct CategoryTabsNew: View {

    @Binding var selected: String
    @Binding var selectedCategoryId: Int
    @ObservedObject var categoryVM: CategoryViewModel

    @State private var didSetupDefault = false

    @Environment(\.scrollToTopProxy) private var scrollToTopProxy
    @State private var categoryScrollProxy: ScrollViewProxy?   // ✅ CORRECT PROXY

    var body: some View {
        VStack(spacing: 0) {

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {

                    HStack(spacing: 20) {
                        ForEach(categoryVM.listArray ?? [], id: \.id) { cat in
                            categoryTab(cat)
                                .id(cat.id)
                                .onTapGesture {
                                    selectCategory(cat, proxy: proxy)
                                }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top)
                }
                .onAppear {
                    categoryScrollProxy = proxy   // 🔥 SAVE HORIZONTAL PROXY
                }
            }

            Divider()
        }
        .onChange(of: categoryVM.listArray?.count) { _ in
            setupDefaultAll()
        }
        // 🔥 THIS FIXES SWIPE → MID SCROLL
        .onChange(of: selectedCategoryId) { newId in
                scrollCategoryToCenter(newId)
        }
    }

    // MARK: - Actions

    private func selectCategory(_ cat: CategoryModel, proxy: ScrollViewProxy) {
        withAnimation(.easeInOut) {
            selectedCategoryId = cat.id ?? 0
            selected = cat.name ?? ""

            proxy.scrollTo(cat.id, anchor: .center)          // horizontal
            scrollToTopProxy?.scrollTo("TOP", anchor: .top)  // vertical
        }
    }

    private func scrollCategoryToCenter(_ id: Int) {
        guard let proxy = categoryScrollProxy else { return }

        withAnimation(.easeInOut) {
            proxy.scrollTo(id, anchor: .center)
        }
    }

    // MARK: - UI

    private func categoryTab(_ cat: CategoryModel) -> some View {
        let isSelected = selectedCategoryId == cat.id

        return VStack(spacing: 6) {
            Text(cat.name ?? "")
                .font(.system(size: 15, weight: .medium))

            Rectangle()
                .fill(isSelected ? Color.orange : .clear)
                .frame(height: 3)
        }
        .contentShape(Rectangle())
    }

    // MARK: - Default "All"

    private func setupDefaultAll() {
        guard !didSetupDefault,
              var list = categoryVM.listArray,
              !list.isEmpty else { return }

        didSetupDefault = true

        if list.first?.id != 55555 {
            list.insert(
                CategoryModel(
                    id: 55555,
                    sequence: nil,
                    name: "All",
                    image: "",
                    parentCategoryID: nil,
                    description: nil,
                    status: nil,
                    createdAt: nil,
                    updatedAt: nil,
                    slug: nil,
                    subcategoriesCount: nil,
                    allItemsCount: nil,
                    translatedName: nil,
                    translations: nil,
                    subcategories: []
                ),
                at: 0
            )
        }

        categoryVM.listArray = list
        selectedCategoryId = 55555
        selected = "All"
    }
}


struct BoardPageView: View {

    let categoryId: Int
    let navigationController: UINavigationController?

    @StateObject private var vm: BoardViewModelNew

    init(categoryId: Int, navigationController: UINavigationController?) {
        self.categoryId = categoryId
        self.navigationController = navigationController
        _vm = StateObject(wrappedValue: BoardViewModelNew(categoryId: categoryId))
    }

    var body: some View {
        BoardListView(
            vm: vm,
            navigationController: navigationController
        )
    }
}


struct BoardListView: View {

    @ObservedObject var vm: BoardViewModelNew
    let navigationController: UINavigationController?

    var body: some View {
        
        ScrollViewReader { proxy in     // ✅ added
            
            ScrollView {
                // 🔝 TOP ANCHOR (harmless)
                if vm.items.isEmpty && !vm.isLoading {
                    
                    
                    emptyView.padding(.top,100)
                    
                } else {
                    
                    Color.clear
                        .frame(height: 0)
                        .id("TOP")
                    LazyVStack {
                        
                        StaggeredGrid(columns: 2, spacing: 6) {
                            ForEach(Array(vm.items.enumerated()), id: \.element.id) { index, item in
                                
                                ProductCardStaggered(product: item) { isLiked, boardId in
                                    vm.updateLikeTo(boardId: boardId, isLiked: isLiked)
                                }
                                .onTapGesture {
                                    pushToDetail(item: item)
                                }
                                
                            }
                        }
                        .padding(.horizontal, 5).padding(.top,0)
                        
                        // 🔥 SINGLE PAGINATION TRIGGER (FOOTER)
                        if !vm.isLastPage {
                            PaginationFooter()
                                .onAppear {
                                    guard !vm.isLoading else { return }
                                    vm.loadNextPage()
                                }
                        }
                        
                        
                        // 🔥 Bottom loading indicator
                        if vm.isLoading && !vm.items.isEmpty {
                            ProgressView()
                                .padding(.vertical, 24)
                        }
                    }.transaction { tx in
                        tx.animation = nil   // 🔥 CRITICAL
                    }
                }
            }
            .refreshable {
                await vm.refresh()
            }
            .onAppear {
                if vm.items.count == 0{
                    vm.loadIfNeeded()
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
                    for: Notification.Name(NotificationKeys.scrollBoardToTop)
                )
            ) { _ in
                print("SCROLL TO TOP TRIGGERED")
                DispatchQueue.main.async {
                    
                    withAnimation(.easeInOut) {
                        
                        proxy.scrollTo("TOP", anchor: .top)
                    }
                }
            }
        }
    }

    var emptyView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image("no_data_found_illustrator")
            Text("No Data Found")
                .foregroundColor(.orange)
            Spacer()
        }
    }
    
    private func pushToDetail(item: ItemModel) {
       
        let vc = UIHostingController(
            rootView: BoardDetailView(
                navigationController: navigationController,
                itemObj: item
            )
        )
        vc.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(vc, animated: true)
    }
}

struct PaginationFooter: View {
    var body: some View {
        Color.clear
            .frame(height: 1) // invisible but stable
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}



extension PublicBoardView{
    
    var headerView: some View {
        HStack {
            Text("For you")
                .underline()
                .font(.manrope(.medium, size: 15))
            
            searchBar
            
            interestButton
        }
        .padding(.horizontal, 10)
        
        .background(Color(.systemBackground))
    }
    
    var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.orange)
            Text("Search any item...")
                .foregroundColor(.gray)
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .onTapGesture {
            pushSearchBoard()
        }
    }
    
    func pushSearchBoard() {
       guard let tabBar = tabBarController,
             let boardNav = tabBar.viewControllers?[1] as? UINavigationController else { return }
       
       let vc = UIHostingController(
           rootView: SearchBoardResultView(
               navigationController: boardNav,
               isByDefaultOpenSearch: true
           )
       )
        vc.hidesBottomBarWhenPushed = true
       boardNav.pushViewController(vc, animated: false)
   }
    
    var interestButton: some View {
        Button {
            guard let tabBar = tabBarController,
                  let boardNav = tabBar.viewControllers?[1] as? UINavigationController else { return }
            let vc = UIHostingController(
                rootView: BoardInterestView(navigationController: boardNav)
            )
            vc.hidesBottomBarWhenPushed = true
            boardNav.pushViewController(vc, animated: true)
        } label: {
            Image("magic").renderingMode(.template).foregroundColor(Color(.label)).padding(8)
        }
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    var emptyView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image("no_data_found_illustrator")
            Text("No Data Found")
                .foregroundColor(.orange)
            Spacer()
        }
    }
}


#Preview {
    PublicBoardView(tabBarController: nil)
}


struct ProductCardStaggered: View {

    @State private var showSafari = false

    let product: ItemModel
    let sendLikeUnlikeObject: (Bool, Int) -> Void
    @State private var imageRatio: CGFloat = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            
            ZStack(alignment:.bottomTrailing) {

                    KFImage(URL(string: product.image ?? ""))
                      .setProcessor(
                            DownsamplingImageProcessor(size: CGSize(width: 400, height: 400))
                        )
                        .scaleFactor(UIScreen.main.scale)
                        .cacheOriginalImage(false)
                        .resizable()
                        .scaledToFit()
                        .clipped()
                        .cornerRadius(10)
                            .shadow(
                                color: Color.black.opacity(0.10),
                                radius: 7,
                                x: 0,
                                y: 2
                            )
                
                Button {
                    showSafari = true
                    outboundClickApi(strURl: product.outbondUrl ?? "", boardId: product.id ?? 0)
                } label: {
                    HStack(spacing:2){
                        Text("Buy Now")
                            .font(.inter(.medium, size: 11))
                            .foregroundColor(.white)
                        Image("upRight")
                    }
                }.padding(.vertical, 3)
                    .padding(.horizontal, 8)
                    .background(Color.orange)
                    .cornerRadius(5)
                    .padding(5)
            }
            
            HStack(spacing:2) {
                Button {
                    manageLike(boardId: product.id ?? 0)
                } label: {
                    Image(product.isLiked == true ? "like_fill" : "like")
                        .frame(width: 24, height: 24)
                 
                }
                if (product.totalLikes ?? 0) > 0{
                    Text("\(product.totalLikes ?? 0)").foregroundColor(Color(.gray))
                        .font(Font.inter(.regular, size: 12))
                }
                Spacer()
                
                if (product.isFeature ?? false) {
                    Text("Sponsored")
                        .font(.inter(.medium, size: 11))
                        .foregroundColor(Color(.gray))
                }
            } .padding(.horizontal,4)
            
            VStack(alignment: .leading,spacing: 0){
                
                Text(product.name ?? "").foregroundColor(Color(.label))
                    .font(.inter(.semiBold, size: 14))
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(product.description ?? "")
                    .font(.inter(.regular, size: 12)).lineLimit(2)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
              
            }.padding(.horizontal,8)
            
            
            PriceView(
                price: product.price ?? 0.0,
                specialPrice: product.specialPrice ?? 0.0,
                currencySymbol: Local.shared.currencySymbol
            ).padding([.bottom],8).padding(.horizontal,8).padding(.top,2)
        }
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        .clipShape(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
        ).contentShape(Rectangle())
        
            .fullScreenCover(isPresented: $showSafari) {
              
                if let url = URL(string:getUrlValid(strURl: product.outbondUrl ?? ""))  {
                    
                    SafariView(url:url)
                }
            }
        
    }
    
    
    func getUrlValid(strURl:String) ->String{
        var urlString = strURl
        if !urlString.lowercased().hasPrefix("http://") &&
              !urlString.lowercased().hasPrefix("https://") {
               urlString = "https://" + urlString
           }
        return urlString
    }
    
    private func manageLike(boardId: Int) {
        if AppDelegate.sharedInstance.isUserLoggedInRequest(){
            
            
            let newState = !(product.isLiked ?? false)
            sendLikeUnlikeObject(newState, boardId)
        }
    }
    
    func outboundClickApi(strURl:String,boardId:Int){
        
        let params = ["board_id":boardId]
        
        URLhandler.sharedinstance.makeCall(url: Constant.shared.board_outbond_click, param: params,methodType: .post) { responseObject, error in
            
            if error == nil{
                
                let result = responseObject! as NSDictionary
                let status = result["code"] as? Int ?? 0
                _ = result["message"] as? String ?? ""
                
                if status == 200{
                    
                }else{
                }
            }
        }
    }
}



