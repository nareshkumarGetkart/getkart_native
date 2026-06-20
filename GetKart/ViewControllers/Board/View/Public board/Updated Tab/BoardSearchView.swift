//
//  BoardSearchView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 01/05/26.
//

import SwiftUI
import Alamofire
import Kingfisher





struct BannerItem: Identifiable {
    let id = UUID()
    let image: String
}
struct BoardSearchView: View {

    @State  private var searchText = ""
    @StateObject private var viewModel = BoardSearchViewModel()
    @FocusState private var isFocused: Bool

    let tabBarController: UITabBarController?

    private var navigationController: UINavigationController? {
        return tabBarController?.viewControllers?[1].navigationController
    }
    
    @State private var currentBanner = 0

        let banners = [
            BannerItem(image: "products"),
            BannerItem(image: "products"),
            BannerItem(image: "products")
        ]
    
    var body: some View {
        
        VStack(spacing:8){
            HStack {

                HStack(spacing: 8) {

                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.orange)

                    Text(viewModel.searchText.isEmpty ? "Search" : viewModel.searchText)
                        .foregroundColor(
                            viewModel.searchText.isEmpty
                            ? Color(.placeholderText)
                            : Color(.label)
                        )
                        .font(.inter(.regular, size: 15))

                    Spacer()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity)
               // .contentShape(Capsule())
                .cornerRadius(10.0)
                .overlay(
                    RoundedRectangle(cornerRadius: 10.0)
                        .strokeBorder(Color(UIColor.separator), lineWidth: 0.5)
                )
                .onTapGesture {
                    pushSearchBoard()
                }

                if viewModel.searchText.count > 0 {

                    Button("Cancel") {
                        viewModel.searchText = ""
                        viewModel.items.removeAll()
                    }
                    .foregroundColor(Color(.label))
                    .font(.inter(.regular, size: 15))
                    .padding(.leading, 8)
                }
            }
            .frame(height: 44)
            .padding(.horizontal, 12)
           /* HStack {

                HStack(spacing: 8) {

                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.orange)

                    TextField("Search", text: $viewModel.searchText)
                        .focused($isFocused)
                        .tint(.orange)
                        .allowsHitTesting(false) // <- instead of disabled(true)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .contentShape(Capsule()) // improves tap area
                .overlay(
                    Capsule()
                        .strokeBorder(Color(UIColor.separator), lineWidth: 0.5)
                )
                .onTapGesture {
                    pushSearchBoard()
                }

                if viewModel.searchText.count > 0 {

                    Button("Cancel") {
                        viewModel.searchText = ""
                        viewModel.items.removeAll()
                    }
                    .foregroundColor(Color(.label))
                    .font(.inter(.regular, size: 15))
                    .padding(.leading, 8)
                }
            }
            .frame(height: 44)
            .padding(.horizontal, 12)*/
            Divider()
        }
        
        VStack(spacing: 0) {
            
                        
            // List of Recent Items
            ScrollView {
                
                bannerSection
                
                if !viewModel.items.isEmpty{
                    
                    HStack {
                        let strMsg = (viewModel.searchText.count) == 0 ? "Recent search" : "Search result"
                        Text(strMsg)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 15)
                }
                VStack(spacing: 0) {
                    
                    ForEach(Array(viewModel.items.enumerated()), id: \.offset) { index, item in
                        
                        HStack(spacing: 15) {
                            
                            if viewModel.searchText.count == 0 && viewModel.isEmptySearched == true  {
                                KFImage(URL(string:  item.categoryImage ?? ""))
                                    .placeholder {
                                        Image("getkartplaceholder")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 40, height: 40)
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                    }
                                    .setProcessor(
                                        DownsamplingImageProcessor(size: CGSize(width: widthScreen / 2.0 - 15,
                                                                                height: widthScreen / 2.0 - 15))
                                    )
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                            // Text
                            Text(item.keyword ?? "")
                                .foregroundColor(Color(.label))
                                .font(.system(size: 16))
                            
                            Spacer()
                            
                            if viewModel.searchText.count == 0 && viewModel.isEmptySearched == true {
                                //  Delete Button
                                Button {
                                    withAnimation {
                                        viewModel.items.removeAll { $0.categoryID == item.categoryID }
                                        viewModel.removeRecentSearchApi(suggestionId: item.categoryID ?? 0)
                                    }
                                } label: {
                                    Image(systemName: "xmark")
                                        .foregroundColor(Color(.label))
                                }
                            }
                        }
                        .padding(8)
                        .background(Color(.systemBackground))
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .onTapGesture {
                            viewModel.cancelSearchRequest()
                            viewModel.istoSearch = false
                           /* searchedItem(item.keyword ?? "")
                            self.navigationController?.popViewController(animated: true)*/
                            
                            self.pushSearchBoardWithSearchText(srchTxt: item.keyword ?? "")

                        }
                    }
                }
                .padding(.horizontal)
                //.padding(.top)
               
                .onAppear{
                    
                    if viewModel.myViewItems.isEmpty {
                        viewModel.getMyviewBoardList()
                    }
                    if viewModel.popularSearches.isEmpty {
                        viewModel.getPopularSearches()
                    }
                                        
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isFocused = true
                    }
                }
               
                if !viewModel.popularSearches.isEmpty{
                    
                    // MARK: Popular Searches
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Popular Searches")
                            .font(.headline)
                            .padding(.horizontal, 16)
                            .padding(.top, 14)
                        
                        // Wrap chips manually (fixed 3-row layout matching screenshot)
                        PopularSearchChipsView(tags: viewModel.popularSearches) { tag in
                            //goBackToSearchResults(tagText: tag)
                            
                            self.pushSearchBoardWithSearchText(srchTxt: tag)
                        }.padding(.horizontal, 12)
                        
                    }
                }
                
                if !viewModel.myViewItems.isEmpty{
                    //MARK: My view
                    VStack(alignment: .leading, spacing: 14) {
                        
                        HStack {
                            Text("My Views")
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                
                                pushToMyViewsScreen()
                            }) {
                                Text("See All")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding([.top,.horizontal], 16)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                
                                ForEach(viewModel.myViewItems, id: \.id) { item in

                                    if item.boardType == 3{
                                        //Idea View
                                        IdeaCardSearch(product: item,
                                                          defaultImgWidth: 170,
                                                          defaultImgHeight: 190).frame(width:170,height: 260)
                                            .onTapGesture{
                                                pushToDetailScreen(item: item)

                                        }
                                    }else{
                                        //Normal board
                                        BoardCardView(product: item,
                                                      defaultImgWidth: 170,
                                                      defaultImgHeight: 190).frame(width:170,height: 260)
                                        .onTapGesture {
                                            pushToDetailScreen(item: item)
                                        }
                                    }
                                }
                            }.padding(.vertical)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 4)
                        }
                    }.padding(.bottom, 30)
                }
            }
            .simultaneousGesture(
                DragGesture().onChanged { _ in
                    UIApplication.shared.endEditing()
                }
            )
        }
       // .background(Color(.systemGray5).opacity(0.3))
        .background(Color(.systemBackground))
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    
    func goBackToSearchResults(tagText:String){
        viewModel.cancelSearchRequest()
         viewModel.istoSearch = false
         isFocused = false
        /* searchedItem(tagText)
         self.navigationController?.popViewController(animated: true)*/
    }
    
    func pushToMyViewsScreen(){

        let hostingVC = UIHostingController(rootView: MyViews(navigationController:navigationController))
        navigationController?.pushViewController(hostingVC, animated: true)
    }
   
    func pushToDetailScreen(item:ItemModel){
        

        let hostingVC = UIHostingController(rootView: BoardDetailView(navigationController:navigationController, itemObj: item))
        navigationController?.pushViewController(hostingVC, animated: true)
    }
    
    
    func pushSearchBoard() {
      
       let vc = UIHostingController(
           rootView: SearchBoardResultView(
               navigationController: navigationController,
               isByDefaultOpenSearch: true
           )
       )
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: false)
   }
    
    func pushSearchBoardWithSearchText(srchTxt:String) {
      
       let vc = UIHostingController(
           rootView: SearchBoardResultView(
               navigationController: navigationController,
               searchText:srchTxt, isByDefaultOpenSearch: false
           )
       )
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: false)
   }
    
}



extension BoardSearchView {

    var bannerSection: some View {

        VStack(spacing: 10) {

            TabView(selection: $currentBanner) {

                ForEach(0..<banners.count, id: \.self) { index in

                    Image(banners[index].image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()
                        .cornerRadius(14)
                        .tag(index)
                }
            }
            .frame(height: 180)
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: 6) {

                ForEach(0..<banners.count, id: \.self) { index in

                    Circle()
                        .fill(
                            currentBanner == index
                            ? Color.orange
                            : Color.gray.opacity(0.4)
                        )
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    BoardSearchView(tabBarController: nil)
}




