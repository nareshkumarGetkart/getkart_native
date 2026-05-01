//
//  BoardView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 11/12/25.
//

import SwiftUI
import Kingfisher


struct BoardView: View {
    
    weak var tabBarController: UITabBarController?
    let navigationController: UINavigationController?
    @State private var selected = "All"
    @StateObject private var vm = BoardViewModel()
    @State private var paymentGateway: PaymentGatewayCentralized?
    
    var body: some View {
        
        ScrollViewReader { verticalProxy in   //ADD THIS
            VStack(spacing: 0) {
                
                headerView(
                    onCategoryTap: {
                        scrollToTop(verticalProxy)
                    }
                )
                ScrollView {
                    //  TOP ANCHOR
                    Color.clear.frame(height: 0)
                        .id("TOP").hidden()
                    
                    if vm.items.isEmpty && !vm.isLoading {
                        
                        
                        emptyView.padding(.top,100)
                        
                    } else {
                        
                        LazyVStack(spacing:0) {
                            StaggeredGrid(columns: 2, spacing: 5) {
                                ForEach(Array(vm.items.enumerated()), id: \.element.id) { index, item in
                                    
                                    //                                    ProductCardStaggered1(
                                    //                                        product: item,
                                    //                                        onTapBoostButton:{
                                    //                                            paymentGatewayOpen(product:item)
                                    //                                        }
                                    //                                    ) { isLiked, boardId in
                                    //                                        vm.updateLike(boardId: boardId, isLiked: isLiked)
                                    //                                    }.contentShape(Rectangle())
                                    //                                        .onTapGesture {
                                    //                                            pushToDetail(item: item)
                                    //                                        }
                                    
                                    
                                    ProductCardStaggered1(
                                        product: item,
                                        sendLikeUnlikeObject: { isLiked, boardId in
                                            vm.updateLike(boardId: boardId, isLiked: isLiked)
                                        },
                                        onTapBoostButton: {
                                            paymentGatewayOpen(product: item)
                                        }
                                    ).contentShape(Rectangle())
                                        .onTapGesture {
                                            pushToDetail(item: item)
                                        }
                                }
                            }
                            .padding(.horizontal, 5)
                            .padding(.top, 0)
                            
                            if vm.isLoading {
                                ProgressView().padding()
                            }
                        }.padding(.top,0)
                        
                    }
                    //  MUST be inside ScrollView, after content
                    ScrollDetector {
                        vm.loadNextPage()
                    }
                }
                
                .scrollIndicators(.hidden)
                
                .refreshable {
                    if !vm.isLoading{
                        vm.loadInitial()
                    }
                }.tint(.orange)
                    .environment(\.scrollToTopProxy, verticalProxy)
            }
            
            .onReceive(
                NotificationCenter.default.publisher(
                    for: Notification.Name(NotificationKeys.refreshInterestChangeBoardScreen.rawValue)
                )
            ) { notification in
                scrollToTop(verticalProxy)
                vm.selectedCategoryId = 0
                selected = "All"
                vm.loadInitial()
                
            }
        }
        .background(Color(.systemGray6))
        .onAppear {
            if vm.items.count == 0 && !vm.isLoading{
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
    
    private func scrollToTop(_ proxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.25)) {
                proxy.scrollTo("TOP", anchor: .top)
            }
        }
    }
    
    func headerView(onCategoryTap: @escaping () -> Void) -> some View {
        VStack {
            HStack {
                //                Text("For you")
                //                    .underline()
                //                    .font(.manrope(.medium, size: 15))
                
                searchBar
                interestButton
            }
            .padding(.horizontal, 10)
            
            CategoryTabs(
                selected: $selected,
                selectedCategoryId: Binding(
                    get: { vm.selectedCategoryId },
                    set: {
                        onCategoryTap()  // SCROLL TO TOP HERE
                        vm.categoryChanged($0)
                    }
                )
            ).padding(.bottom,0)
        }
        .background(Color(.systemBackground))
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
}

#Preview {
    BoardView(navigationController: nil)
}


struct ScrollBottomKey: PreferenceKey {
   static var defaultValue: CGFloat = .zero
   static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
       value = nextValue()
   }
}


struct CategoryTabs: View {

    @Binding var selected: String
    @Binding var selectedCategoryId: Int
    @State private var didSetupDefault = false
    @State private var isHorizontalDrag = false
    @Environment(\.scrollToTopProxy) private var scrollProxy

    @StateObject private var objViewModel = CategoryViewModel(type: 2)

    var body: some View {
        VStack(spacing: 0) {

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {

                    HStack(spacing: 20) {
                        ForEach(objViewModel.listArray ?? [], id: \.id) { catObj in
                            categoryTab(catObj)
                                .id(catObj.id)
                                
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        selectedCategoryId = catObj.id ?? 0
                                        selected = catObj.name ?? ""

                                        proxy.scrollTo(catObj.id,
                                                       anchor: .center)
                                        // vertical scroll to top
                                        scrollProxy?.scrollTo("TOP", anchor: .top)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal,12)
                    .padding(.vertical, 0)
                    .padding(.top,4)
                }
             
                // 🔥 Auto-scroll when selection changes (API / default)
                .onChange(of: selectedCategoryId) { newValue in
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }

            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 1)
        }.padding(.bottom, 0)

        // When categories load
        .onChange(of: objViewModel.listArray?.count ?? 0) { _ in
            setupAllAndDefaultSelection()
        }
    }

    // MARK: - Tab UI
    private func categoryTab(_ cat: CategoryModel) -> some View {

        let isSelected = selectedCategoryId == cat.id

        return VStack(spacing: 6) {

            Text(cat.name ?? "")
                .font(.inter(.medium, size: 15))
                .foregroundColor(Color(.label))

            Rectangle()
                .fill(isSelected ? Color.orange : Color.clear)
                .frame(height: 3)
                .cornerRadius(2)
        }
        .contentShape(Rectangle())
    }

    // MARK: - Default Setup
    private func setupAllAndDefaultSelection() {

        guard didSetupDefault == false else { return }
        guard var list = objViewModel.listArray, !list.isEmpty else { return }

        didSetupDefault = true

        if list.first?.id != 0 {
            list.insert(
                CategoryModel(
                    id: 0,
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

        objViewModel.listArray = list

        // Default select "All"
      //  selectedCategoryId = 0
       // selected = "All"
    }
}

private struct ScrollToTopProxyKey: EnvironmentKey {
    static let defaultValue: ScrollViewProxy? = nil
}

extension EnvironmentValues {
    var scrollToTopProxy: ScrollViewProxy? {
        get { self[ScrollToTopProxyKey.self] }
        set { self[ScrollToTopProxyKey.self] = newValue }
    }
}


private extension BoardView {

    var headerView: some View {
        VStack {
            HStack {
                Text("For you")
                    .underline()
                    .font(.manrope(.medium, size: 15))

                searchBar

                interestButton
            }
            .padding(.horizontal, 10)

            CategoryTabs(
                selected: $selected,
                selectedCategoryId: Binding(
                    get: { vm.selectedCategoryId },
                    set: { vm.categoryChanged($0) }
                )
            )
        }
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
           /* let vc = UIHostingController(
                rootView: SearchBoardResultView(
                    navigationController: navigationController,
                    isByDefaultOpenSearch: true
                )
            )
            navigationController?.pushViewController(vc, animated: false)*/
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
            let vc = UIHostingController(
                rootView: BoardInterestView(navigationController: navigationController)
            )
            navigationController?.pushViewController(vc, animated: true)
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

    func pushToDetail(item: ItemModel) {
        let vc = UIHostingController(
            rootView: BoardDetailView(
                navigationController: navigationController,
                itemObj: item
            )
        )
        navigationController?.pushViewController(vc, animated: true)
    }
}


struct ProductCardStaggered1: View {
    @State private var showSafari = false
    @State private var paymentGateway: PaymentGatewayCentralized?
    let product: ItemModel
    let sendLikeUnlikeObject: (Bool, Int) -> Void
    @State private var imageRatio: CGFloat = 3/4 // fallback ratio
    let onTapBoostButton: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            
            ZStack(alignment:.bottomTrailing) {
                if let url = URL(string: product.image ?? "") {
                 
                        KFImage(url)
                        .setProcessor(
                              DownsamplingImageProcessor(size: CGSize(width: 400, height: 400))
                          )
                          .scaleFactor(UIScreen.main.scale)
                          .cacheOriginalImage(false)
                            .resizable()
                            .onSuccess { result in
                                            let size = result.image.size
                                            if size.height > 0 {
                                                imageRatio = size.width / size.height
                                            }
                                        }
                                        .scaledToFill()
                                        .aspectRatio(imageRatio, contentMode: .fill)
                            .clipped()
                            .cornerRadius(8)
                            .shadow(
                                color: Color.black.opacity(0.10),
                                radius: 7,
                                x: 0,
                                y: 2
                            )
                }
                if (product.user?.id ?? 0) != Local.shared.getUserId(){
                    
                    Button {
                        showSafari = true
                        outboundClickApi(strURl: product.outbondUrl ?? "", boardId: product.id ?? 0)
                    } label: {
                        HStack(spacing:2){
                            Text(product.ctaLabel ?? "Buy Now")
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
            }
            
            HStack(spacing:2) {
                
                if (product.user?.id ?? 0) == Local.shared.getUserId(){
                    Spacer()

                }else{
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
                }
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
            
            if (product.user?.id ?? 0) == Local.shared.getUserId(){
                
                if product.isFeature == false {
                    Button {
                        // Boost action
                        onTapBoostButton()
                       // paymentGatewayOpen()
                    } label: {
                        Text("Boost \(Local.shared.currencySymbol)\(Int(product.package?.finalPrice ?? 0))")
                            .font(.inter(.semiBold, size: 14))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 30)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.65, blue: 0.15), // light orange
                                        Color(red: 0.95, green: 0.45, blue: 0.05) // dark orange
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(5)
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                }


            }

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
    
    
    private func manageLike(boardId: Int) {
        if AppDelegate.sharedInstance.isUserLoggedInRequest(){
            
            let newState = !(product.isLiked ?? false)
            sendLikeUnlikeObject(newState, boardId)
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
    
    
    func paymentGatewayOpen() {

        paymentGateway = PaymentGatewayCentralized()  //  STRONG REFERENCE
        paymentGateway?.selectedPlanId = product.package?.id ?? 0
        paymentGateway?.categoryId = product.categoryID ?? 0
        paymentGateway?.itemId = product.id ?? 0
        paymentGateway?.paymentFor = .boostBoard
        paymentGateway?.selIOSProductID = product.package?.iosProductID ?? ""

        paymentGateway?.callbackPaymentSuccess = { (isSuccess) in

            if isSuccess {
                let vc = UIHostingController(
                    rootView: PlanBoughtSuccessView(
                        navigationController: AppDelegate.sharedInstance.navigationController
                    )
                )
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                vc.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                AppDelegate.sharedInstance.navigationController?.present(vc, animated: true)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationKeys.boardBoostedRefresh.rawValue), object:  ["boardId":self.product.id ?? 0], userInfo: nil)
            }
            
            //  RELEASE
               self.paymentGateway = nil
        }

        paymentGateway?.initializeDefaults()
    }
}


struct PriceView: View {

    let price: Double
    let specialPrice: Double
    let currencySymbol: String

    private var discountPercent: Double {
        guard price > 0, specialPrice > 0 else { return 0 }
        return ((price - specialPrice) / price) * 100
    }

    var body: some View {
        if specialPrice > 0 {
            HStack(spacing: 6) {

                // Special price
                Text("\(currencySymbol)\(specialPrice.indianPriceFormat())")
                    .font(.inter(.semiBold, size: 14))
                    .foregroundColor(Color(CustomColor.sharedInstance.priceColor))

                // Original price (striked)
                Text("\(currencySymbol)\(price.indianPriceFormat())")
                    .font(.inter(.medium, size: 11))
                    .foregroundColor(.gray)
                    .strikethrough(true, color: .secondary)

                // Discount
                Text("\(discountPercent.formatNumber())% Off")
                    .font(.inter(.medium, size: 11))
                    .foregroundColor(Color(CustomColor.sharedInstance.priceColor))
            }
        } else {
            // Normal price
            Text("\(currencySymbol)\(price.indianPriceFormat())")
                .font(.inter(.semiBold, size: 14))
                .foregroundColor(Color(CustomColor.sharedInstance.priceColor))
        }
    }
}



struct StaggeredGrid: Layout {

    let columns: Int
    let spacing: CGFloat

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {

        guard let totalWidth = proposal.width else { return .zero }

        let columnWidth = (totalWidth - (CGFloat(columns - 1) * spacing)) / CGFloat(columns)

        var heights = Array(repeating: CGFloat.zero, count: columns)

        for subview in subviews {
            let col = heights.firstIndex(of: heights.min()!)!
            let size = subview.sizeThatFits(.init(width: columnWidth, height: nil))
            heights[col] += size.height + spacing
        }

        return CGSize(width: totalWidth, height: heights.max() ?? 0)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {

        let columnWidth = (bounds.width - (CGFloat(columns - 1) * spacing)) / CGFloat(columns)

        var heights = Array(repeating: CGFloat.zero, count: columns)

        for subview in subviews {
            let col = heights.firstIndex(of: heights.min()!)!
            let x = bounds.minX + CGFloat(col) * (columnWidth + spacing)
            let y = bounds.minY + heights[col]

            let size = subview.sizeThatFits(.init(width: columnWidth, height: nil))

            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: .init(width: columnWidth, height: size.height)
            )

            heights[col] += size.height + spacing
        }
    }
}





import UIKit

struct ScrollDetector: UIViewRepresentable {

    var onScrollToBottom: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onScrollToBottom: onScrollToBottom)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            attachScrollView(from: view, coordinator: context.coordinator)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    private func attachScrollView(
        from view: UIView,
        coordinator: Coordinator
    ) {
        var parent = view.superview
        while parent != nil {
            if let scrollView = parent as? UIScrollView {
                scrollView.delegate = coordinator
                return
            }
            parent = parent?.superview
        }
    }

    // MARK: - Coordinator
    final class Coordinator: NSObject, UIScrollViewDelegate {

        let onScrollToBottom: () -> Void

        private var isTriggered = false
        private var lastContentHeight: CGFloat = 0   // 🔥 KEY

        init(onScrollToBottom: @escaping () -> Void) {
            self.onScrollToBottom = onScrollToBottom
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {

            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let height = scrollView.frame.size.height

            // 🔥 RESET on content shrink (category change)
            if contentHeight < lastContentHeight {
                isTriggered = false
            }

            // 🔥 RESET when new data added
            if contentHeight > lastContentHeight {
                isTriggered = false
                lastContentHeight = contentHeight
            }

            if offsetY > contentHeight - height - 200 {
                if !isTriggered {
                    isTriggered = true
                    onScrollToBottom()
                }
            }
        }

    }
}
