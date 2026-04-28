//
//  SearchBoardView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 12/12/25.

import SwiftUI
import Alamofire
import Kingfisher

struct SearchBoardView: View {

    @State  var searchText = ""
    let navigationController:UINavigationController?
    var isToCloseToSearchResultScreen = false
    let searchedItem:(_ srchTxt:String) -> Void
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = BoardSearchViewModel()
    @FocusState private var isFocused: Bool
    
   
    var body: some View {
        
        VStack(spacing:8){
        HStack {
            Button {
                navigationController?.popToRootViewController(animated: true)
                
            } label: {
                Image("arrow_left").renderingMode(.template).foregroundColor(Color(UIColor.label))
            }.frame(width: 40,height: 40)
            
            
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.orange)
                TextField("Search", text: $viewModel.searchText)
                    .focused($isFocused) // bind focus to this field
                    .tint(Color.orange)
                    .submitLabel(.search)
                    .onSubmit {
                        
                        if  viewModel.searchText.trim().count > 0{
                            
                            FaceBookAppEvents.facebookEvents(type: .boardSearch, categoryName:  viewModel.searchText)
                            viewModel.cancelSearchRequest()
                            viewModel.istoSearch = false
                            isFocused = false
                            searchedItem(viewModel.searchText)
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            //.background(Color(UIColor.systemGray5)).cornerRadius(10)
            .overlay(
                Capsule()
                    .strokeBorder(Color(UIColor.separator), lineWidth: 0.5)
            )
            //.shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            if  viewModel.searchText.count > 0{
                Button("Cancel") {
                    viewModel.searchText = ""
                    viewModel.items.removeAll()
                }
                .foregroundColor(Color(.label))
                .font(.inter(.regular, size: 15))
                .padding(.leading, 8)
            }
            
        
        }.frame(height:44).padding(.horizontal,12)
            
            Divider()
        }
        
        VStack(spacing: 0) {
                        
            // List of Recent Items
            ScrollView {
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
                            searchedItem(item.keyword ?? "")
                            self.navigationController?.popViewController(animated: true)
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
                            goBackToSearchResults(tagText: tag)
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
                            HStack(spacing: 12) {
                                
                                ForEach(viewModel.myViewItems, id: \.id) { item in

                                    if item.boardType == 3{
                                        //Idea View
                                        IdeaCardStaggered(product: item,
                                                          defaultImgWidth: 170,
                                                          defaultImgHeight: 240).frame(width:170,height: 240)
                                            .onTapGesture{
                                                pushToDetailScreen(item: item)

                                        }
                                    }else{
                                        //Normal board
                                        BoardCardView(product: item,
                                                      defaultImgWidth: 170,
                                                      defaultImgHeight: 190).frame(width:170,height: 240)
                                        .onTapGesture {
                                            pushToDetailScreen(item: item)
                                        }
                                    }
                                }
                            }
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
         searchedItem(tagText)
         self.navigationController?.popViewController(animated: true)
    }
    
    func pushToMyViewsScreen(){
        let hostingVC = UIHostingController(rootView: MyViews(navigationController:self.navigationController))
        self.navigationController?.pushViewController(hostingVC, animated: true)
    }
   
    func pushToDetailScreen(item:ItemModel){
        let hostingVC = UIHostingController(rootView: BoardDetailView(navigationController:self.navigationController, itemObj: item))
        self.navigationController?.pushViewController(hostingVC, animated: true)
    }
}


#Preview {
    SearchBoardView(navigationController: nil, searchedItem: {srchTxt in })
}




// MARK: - Popular Search Chips (Dynamic Flow Layout)
 
struct PopularSearchChipsView: View {
    let tags: [String]
    var onSelectedTag: (_ tag: String) -> Void

    private let hSpacing: CGFloat = 12
    private let vSpacing: CGFloat = 10

    @State private var availableWidth: CGFloat = 0

    var body: some View {
        // 1. Use a hidden GeometryReader ONLY for width, anchored in the background
        //    so it doesn't affect layout height
        Color.clear
            .frame(height: 0)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { availableWidth = geo.size.width }
                        .onChange(of: geo.size.width) { availableWidth = $0 }
                }
            )

        // 2. Build rows only once we have a real width
        if availableWidth > 0 {
            let rows = buildRows(availableWidth: availableWidth)
            VStack(alignment: .leading, spacing: vSpacing) {
                ForEach(rows.indices, id: \.self) { rowIndex in
                    HStack(spacing: hSpacing) {
                        ForEach(rows[rowIndex], id: \.self) { tag in
                            SearchChip(title: tag)
                                .onTapGesture { onSelectedTag(tag) }
                        }
                    }
                }
            }
        }
    }

    private func buildRows(availableWidth: CGFloat) -> [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []
        var currentRowWidth: CGFloat = 0

        for tag in tags {
            let chipWidth = estimatedChipWidth(for: tag)
            let widthNeeded = currentRow.isEmpty
                ? chipWidth
                : currentRowWidth + hSpacing + chipWidth

            if widthNeeded > availableWidth && !currentRow.isEmpty {
                rows.append(currentRow)
                currentRow = [tag]
                currentRowWidth = chipWidth
            } else {
                currentRow.append(tag)
                currentRowWidth = widthNeeded
            }
        }
        if !currentRow.isEmpty { rows.append(currentRow) }
        return rows
    }

    private func estimatedChipWidth(for text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 13.5)
        let textWidth = (text as NSString).size(withAttributes: [.font: font]).width
        return textWidth + 28 + 2
    }
}
 
struct SearchChip: View {
    let title: String
 
    var body: some View {
        Text(title)
            .font(.system(size: 13.5))
            .foregroundColor(.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(Color(.systemBackground))
            .overlay(
                Capsule()
                    .stroke(Color(red: 0.80, green: 0.80, blue: 0.82), lineWidth: 1.5)
            )
            .clipShape(Capsule())
            .lineLimit(1)
    }
}




struct BoardCardView: View {
    let product: ItemModel
    var defaultImgWidth: CGFloat = 0.0
    var defaultImgHeight: CGFloat = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: Image
            KFImage(URL(string: product.image ?? ""))
                .setProcessor(
                    DownsamplingImageProcessor(size: CGSize(width: 400, height: 500))
                )
                .cacheOriginalImage(false)
                .resizable()
                .scaledToFill()
                .frame(
                    width: defaultImgWidth > 0 ? defaultImgWidth : 170,
                    height: defaultImgHeight > 0 ? defaultImgHeight : 190
                )
                .cornerRadius(12)
                .clipped()

            // MARK: Title + Price
            VStack(alignment: .leading, spacing: 2) {
                Text(product.name ?? "")
                    .foregroundColor(Color(.label))
                    .font(.inter(.semiBold, size: 14))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                PriceView(
                    price: product.price ?? 0.0,
                    specialPrice: product.specialPrice ?? 0.0,
                    currencySymbol: Local.shared.currencySymbol
                )
                .padding(.top, 2)
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 8)
            .padding(.top, 6)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
        .contentShape(Rectangle())
    }
}
