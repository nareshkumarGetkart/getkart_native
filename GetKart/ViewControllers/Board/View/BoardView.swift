//
//  BoardView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 11/12/25.
//

import SwiftUI
import Kingfisher


struct BoardView: View {

    let navigationController: UINavigationController?
    @State private var selected = "All"
    @StateObject private var vm = BoardViewModel()

    var body: some View {
        
        VStack(spacing: 0) {
            
           // headerView
            
            
            ScrollViewReader { verticalProxy in   // 👈 ADD THIS

                headerView(
                    onCategoryTap: {
                        withAnimation(.easeInOut) {
                            verticalProxy.scrollTo("TOP", anchor: .top)
                        }
                    }
                )
               
            ScrollView {
                
                // 🔥 TOP ANCHOR
                         Color.clear
                             .frame(height: 0)
                             .id("TOP").hidden()
                
                if vm.items.isEmpty && !vm.isLoading {
                    
                    
                    emptyView.padding(.top,100)
                    
                } else {
                    
                    LazyVStack {
                        StaggeredGrid(columns: 2, spacing: 5) {
                            ForEach(Array(vm.items.enumerated()), id: \.offset) { index, item in
                                ProductCardStaggered1(
                                    product: item,
                                    imgHeight: CGFloat(160 + (index % 2) * 50)
                                ) { isLiked, boardId in
                                    vm.updateLike(boardId: boardId, isLiked: isLiked)
                                }
                                .onTapGesture {
                                    pushToDetail(item: item)
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
                    }.padding(.top,0)
                    
                }
            }.padding(.top,-10)
            .refreshable {
                if !vm.isLoading{
                    vm.loadInitial()
                }
            }
            .onPreferenceChange(ScrollBottomKey.self) { bottomY in
                vm.handleScrollBottom(bottomY: bottomY)
            }
            .scrollIndicators(.hidden, axes: .vertical)
            .scrollIndicators(.hidden, axes: .horizontal)
            
            // 🔥 EXPOSE PROXY TO CATEGORY TABS
            .environment(\.scrollToTopProxy, verticalProxy)
            // }
        }
        }
        .background(Color(.systemGray6))
        .onAppear {
            if vm.items.count == 0{
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
                for: Notification.Name(NotificationKeys.refreshInterestChangeBoardScreen.rawValue)
            )
        ) { notification in
            
            vm.categoryChanged(0)
            selected = "All"
        }
        
    }
    
    
    func headerView(onCategoryTap: @escaping () -> Void) -> some View {
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
                    set: {
                        vm.categoryChanged($0)
                        onCategoryTap()   // 🔥 SCROLL TO TOP HERE
                    }
                )
            )
        }
        .background(Color(.systemBackground))
        
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

            ScrollViewReader { proxy in      // 🔥 ADD THIS
                ScrollView(.horizontal, showsIndicators: false) {

                    HStack(spacing: 26) {
                        ForEach(objViewModel.listArray ?? [], id: \.id) { catObj in
                            categoryTab(catObj)
                                .id(catObj.id)   // 🔥 IMPORTANT
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        selectedCategoryId = catObj.id ?? 0
                                        selected = catObj.name ?? ""

                                        proxy.scrollTo(catObj.id,
                                                       anchor: .center)
                                        // 🔥 vertical scroll to top
                                        scrollProxy?.scrollTo("TOP", anchor: .top)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                    //.padding(.top, 6)
                }
                // 🔥 Direction lock gesture
                 /*     .simultaneousGesture(
                          DragGesture(minimumDistance: 5)
                              .onChanged { value in
                                  let horizontal = abs(value.translation.width)
                                  let vertical = abs(value.translation.height)

                                  // lock only horizontal drags
                                  isHorizontalDrag = horizontal > vertical
                              }
                              .onEnded { _ in
                                  isHorizontalDrag = false
                              }
                      )
                      // 🔥 disable vertical parent scroll while horizontal dragging
                      .scrollDisabled(isHorizontalDrag == false ? false : false)
                */
             
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
        }.padding(.bottom,0)

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
            let vc = UIHostingController(
                rootView: SearchBoardResultView(
                    navigationController: navigationController,
                    isByDefaultOpenSearch: true
                )
            )
            navigationController?.pushViewController(vc, animated: false)
        }
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
    
    let product: ItemModel
    let imgHeight: CGFloat
    let sendLikeUnlikeObject: (Bool, Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            
            ZStack(alignment:.bottomTrailing) {
                if let url = URL(string: product.image ?? "") {
                    
                    
                    GeometryReader { geo in
                        KFImage(url)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width,height:imgHeight)
                            .clipped()
                            .cornerRadius(8)
                            .shadow(
                                color: Color.black.opacity(0.10),
                                radius: 7,
                                x: 0,
                                y: 2
                            )
                    }
                    .frame(height: imgHeight)
                }
                
                Button {
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
                
                Text("\(product.totalLikes ?? 0)").foregroundColor(Color(.gray))
                    .font(Font.inter(.regular, size: 12))
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
        )
        
    }
    
    
    private func manageLike(boardId: Int) {
        let newState = !(product.isLiked ?? false)
        sendLikeUnlikeObject(newState, boardId)
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
        
        if let url = URL(string: strURl)  {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Cannot open URL")
            }
        }
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
/*
private extension BoardView {

    private var listView: some View {
        ScrollView {

         LazyVStack {

                StaggeredGrid(columns: 2, spacing: 5) {

                    ForEach(Array(vm.items.enumerated()), id: \.offset) { index, item in
                        ProductCardStaggered1(
                            product: item,
                            imgHeight: CGFloat(150 + (index % 2) * 50)
                        ) { isLiked, boardId in
                            vm.updateLike(boardId: boardId, isLiked: isLiked)
                        }
                        .onTapGesture {
                            pushToDetail(item: item)
                        }
                    }
                }
                .padding(5)

                // 🔥 PAGINATION TRIGGER VIEW (KEY)
                if vm.hasMoreData {
                    Color.clear
                         .frame(height: 0)
                         .hidden()
                        .onAppear {
                            vm.loadNextPage()   // ✅ ALWAYS fires
                        }
                }

//                if vm.isLoading {
//                    ProgressView().padding()
//                }
            }
        }
    }
*/

/*
 
 struct SearchBarView: View {
     var body: some View {
         HStack {
             Image(systemName: "magnifyingglass")
             TextField("Search any item…", text: .constant(""))
                 .font(.inter(.regular, size: 14))
             Image(systemName: "barcode.viewfinder")
         }
         .padding()
         .background(Color(.systemGray6))
         .cornerRadius(12)
         .padding(.horizontal)
     }
 }

 
 struct BoardView: View {
    
    let navigationController:UINavigationController?
    @State private var selected = "All"
    @State private var selectedCategoryId = 0
    @State private var listArray:Array<ItemModel> = [ItemModel]()
    @State private var page = 1
    @State private var isDataLoading = true
    
    
    @StateObject private var vm = BoardViewModel()

    
    var body: some View {
        VStack(spacing: 0) {
            
            VStack{
                // MARK: - Top Row (Time, Icons)
                HStack {
                    Text("For you").underline()
                        .font(.manrope(.semiBold, size: 15))
                    // MARK: - Search Bar
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.orange)
                        TextField("Search any item...", text: .constant(""))
                            .textFieldStyle(PlainTextFieldStyle()).disabled(true)
                        
                    }.padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .background(Color(UIColor.systemGray6)).cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 0.1)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .onTapGesture {
                            let hostingVC = UIHostingController(rootView: SearchBoardResultView(navigationController: self.navigationController,isByDefaultOpenSearch:true))
                            self.navigationController?.pushViewController(hostingVC, animated: false)
                        }
                    
                    Button {
                        let hostingVC = UIHostingController(rootView: BoardInterestView(navigationController: self.navigationController))
                        self.navigationController?.pushViewController(hostingVC, animated: true)
                    } label: {
                        Image("magic")
                            .font(.title3)
                            .foregroundColor(Color(.label))
                            .padding(8)
                    }.background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 0.1)
                        )
                }
                .padding(.horizontal,12)
                
                CategoryTabs(selected: $selected, selectedCategoryId: $selectedCategoryId)
                
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
                        // ProductCardStaggered(product: product,imgHeight:CGFloat(150 + (index % 2) * 50))
                        .onTapGesture {
                            pushToDetailScreen(item:product)
                        }.onAppear{
                            if let lastItem = listArray.last, lastItem.id == product.id  && !isDataLoading{
                                self.getBoardListApi()
                            }
                        }
                    }
                }
                .padding(5)
                
            }
        }
        }
        .background(Color(.systemGray6))
        .onAppear{
            getBoardListApi()
            
        }.onChange(of: selectedCategoryId) { _ in
            self.page = 1
            getBoardListApi()
        }
    }
}


extension BoardView{
    
    func loadNextPageIfNeeded() {
        guard !isDataLoading else { return }
        getBoardListApi()
    }

    
    private func shouldLoadMoreData(currentItem: ItemModel) -> Bool {
        guard let index = listArray.firstIndex(where: { $0.id == currentItem.id }) else {
            return false
        }

        let thresholdIndex = listArray.count - 4   // preload earlier
        return index >= thresholdIndex
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

        let strUrl = Constant.shared.get_public_board + "?page=\(page)&category_id=\(selectedCategoryId > 0 ? "\(selectedCategoryId)" : "")"
        self.isDataLoading = true
       
        ApiHandler.sharedInstance.makeGetGenericData(isToShowLoader: true, url: strUrl,loaderPos: .mid) { (obj:ItemParse) in
            
            if obj.code == 200 {
                if obj.data != nil , (obj.data?.data ?? []).count > 0 {
                    self.listArray.append(contentsOf:  obj.data?.data ?? [])
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                    self.isDataLoading = false
                    self.page += 1
                })

            }else{
                self.isDataLoading = false
            }
        }
    }
}
 
 
 
 struct ProductCardStaggered: View {

    @State var product: ItemModel?
     var imgHeight:CGFloat = 250
     var sendLikeUnlikeObject: (_ isLiked:Bool, _ boardId:Int) -> Void

     var body: some View {
         VStack(alignment: .leading, spacing: 5) {
             
             ZStack(alignment: .bottomTrailing) {
           
                 if let url = URL(string: product?.image ?? "") {
                     KFImage(url)
                         .resizable()
                         .placeholder {
                             Image("getkartplaceholder")
                                 .resizable()
                                 .scaledToFill()
                         }
                         .scaledToFill()
                         .frame(
                             width: UIScreen.ft_width()/2 - 30,
                             height: imgHeight
                         )
                         .clipped()
                         .cornerRadius(12)
                 }
                                 
                 Button {
                     outboundClickApi(strURl: product?.outbondUrl ?? "", boardId: product?.id ?? 0)
                 } label: {
                     HStack(spacing:2){
                         Text("Buy Now")
                             .font(.inter(.medium, size: 14))
                             .foregroundColor(.white)
                         Image("upRight")
                     }
                 }.padding(.vertical, 5)
                  .padding(.horizontal, 10)
                 .background(Color.orange)
                 .cornerRadius(5)
                 .padding(5)
             }// .frame(maxWidth: UIScreen.ft_width()/2 - 30)

             HStack(spacing:5) {
                /* let imgStr = (product.isLiked == true) ? "like_fill" : "heart"
                 Image(imgStr).resizable().frame(width: 13, height: 13)
                 //.renderingMode(.template).foregroundColor(Color(.label))
                
                 */
        
             
                 Button {
                  
                    // post.isLiked?.toggle()
                     manageLikeDislikeApi(boardId: product?.id ?? 0)
                 } label: {
                     let imgStr = (product?.isLiked == true) ? "like_fill" : "heartGrey"
                     Image(imgStr).resizable().aspectRatio(contentMode: .fit).frame(width: 20, height: 20)//.foregroundColor(Color(.label))
                 }

                 Text("\(product?.totalLikes ?? 0)")
                     .font(.inter(.regular, size: 14))
                     .foregroundColor(Color(.gray))
                 
                 Spacer()

                if (product?.isFeature ?? false) {
                     Text("Sponsored")
                         .font(.inter(.regular, size: 10))
                         .foregroundColor(.gray)
                 }
             }
             VStack(alignment: .leading){
                 Text(product?.name ?? "").foregroundColor(Color(.label))
                     .font(.inter(.semiBold, size: 14))
                     .fixedSize(horizontal: false, vertical: true)
                 
                 Text(product?.description ?? "")
                     .font(.inter(.regular, size: 12))
                     .foregroundColor(.gray)
                     .fixedSize(horizontal: false, vertical: true)
             }
             
             if (product?.specialPrice ?? 0.0) > 0{
                 HStack{
                     Text("\(Local.shared.currencySymbol) \((product?.specialPrice ?? 0.0).formatNumber())")
                         .font(.inter(.semiBold, size: 14))
                         .foregroundColor(Color(CustomColor.sharedInstance.priceColor))
                     Text("\(Local.shared.currencySymbol)\((product?.price ?? 0.0).formatNumber())")
                         .font(.inter(.medium, size: 11))
                         .foregroundColor(Color(.gray)).strikethrough(true, color: .secondary)
                     let per = (((product?.price ?? 0.0) - (product?.specialPrice ?? 0.0)) / (product?.price ?? 0.0)) * 100.0
                     Text("\(per.formatNumber())% Off").font(.inter(.medium, size: 11))
                         .foregroundColor(Color(CustomColor.sharedInstance.priceColor))
                 }

             }else{
                
                 Text("\(Local.shared.currencySymbol) \((product?.price ?? 0.0).formatNumber())")
                     .font(.inter(.semiBold, size: 14))
                     .foregroundColor(Color(CustomColor.sharedInstance.priceColor))
             }
         }
         .padding(10)
         .background(Color(.systemBackground))
         .cornerRadius(14)
         .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
         
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
         
         
         if let url = URL(string: strURl)  {
             if UIApplication.shared.canOpenURL(url) {
                 UIApplication.shared.open(url, options: [:], completionHandler: nil)
             } else {
                 print("Cannot open URL")
             }
         }
       
     }
     
     func manageLikeDislikeApi(boardId:Int){
         
         product?.isLiked?.toggle()
         
         let params = ["board_id":boardId]
         
         URLhandler.sharedinstance.makeCall(url: Constant.shared.manage_board_favourite, param: params,methodType: .post) { responseObject, error in
             
             if error == nil{
                 
                 let result = responseObject! as NSDictionary
                 let status = result["code"] as? Int ?? 0
                 let message = result["message"] as? String ?? ""
                 
                 if status == 200{
                     
                     self.sendLikeUnlikeObject(product?.isLiked ?? false,boardId)

                 }else{
                     
                 }
             }
         }
     }
 }

*/




extension Double {

    func indianPriceFormat() -> String {

        let absValue = abs(self)

        switch absValue {

        case 1_00_00_000...:
            let value = self / 1_00_00_000
            return format(value, suffix: "Cr")

        case 1_00_000...:
            let value = self / 1_00_000
            return format(value, suffix: "Lac")

        default:
            return NumberFormatter.indianComma.string(from: NSNumber(value: self)) ?? "\(self)"
        }
    }

    private func format(_ value: Double, suffix: String) -> String {
        let isWhole = value.truncatingRemainder(dividingBy: 1) == 0
        let formatted = String(format: isWhole ? "%.0f" : "%.1f", value)
        return "\(formatted) \(suffix)"
    }
}

extension NumberFormatter {

    static let indianComma: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_IN")
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

