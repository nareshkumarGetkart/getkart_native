//
//  SearchBoardView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 12/12/25.
//


import SwiftUI
import Alamofire
import Kingfisher

struct RecentSearchItem: Identifiable {
    let id = UUID()
    let title: String
    let image: String
}

struct SearchBoardView: View {

    @State  var searchText = ""
    let navigationController:UINavigationController?
    var isToCloseToSearchResultScreen = false
    let searchedItem:(_ srchTxt:String) -> Void
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = BoardSearchViewModel()
    @FocusState private var isFocused: Bool

    var body: some View {
        
        
        HStack {
            Button {
                // if isToCloseToSearchResultScreen{
              //  navigationController?.popToRootViewController(animated: true)
                //                    }else{
                //                        navigationController?.popViewController(animated: true)
                //                    }
                var isPopped = false
                
                if let nav = navigationController,
                   let boardVC = nav.viewControllers.first(where: {
                       guard let hostingVC = $0 as? UIHostingController<AnyView> else { return false }
                       return String(describing: type(of: hostingVC.rootView)) == "BoardView"
                   }) {
                    nav.popToViewController(boardVC, animated: true)
                    isPopped = true
                }
                if !isPopped{
                    navigationController?.popToRootViewController(animated: true)
                }

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
                        
                        if  viewModel.searchText.count > 0{
                            viewModel.istoSearch = false
                            isFocused = false
                            searchedItem(viewModel.searchText)
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(Color(UIColor.systemGray5)).cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 0.1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            if  viewModel.searchText.count > 0{
                Button("Cancel") {
                    viewModel.searchText = ""
                    viewModel.items.removeAll()
                }
                .foregroundColor(Color(.label))
                .padding(.leading, 8)
            }
        }.frame(height:44).padding(.horizontal,12)
        
        VStack(spacing: 0) {
            
            HStack {
                let strMsg = (viewModel.searchText.count) == 0 ? "Recent search" : "Search result"
                Text(strMsg)
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 15)
            
            // List of Recent Items
            ScrollView {
                
                VStack(spacing: 8) {
                    
                    ForEach(Array(viewModel.items.enumerated()), id: \.offset) { index, item in
                        
                        HStack(spacing: 15) {
                            
                            if viewModel.searchText.count == 0 && viewModel.isEmptySearched == true  {
                                KFImage(URL(string:  item.categoryImage ?? ""))
                                    .placeholder {
                                        Image("getkartplaceholder")
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 45, height: 45)
                                            .clipShape(RoundedRectangle(cornerRadius: 22.5))
                                    }
                                    .setProcessor(
                                        DownsamplingImageProcessor(size: CGSize(width: widthScreen / 2.0 - 15,
                                                                                height: widthScreen / 2.0 - 15))
                                    )
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 45, height: 45)
                                    .clipShape(RoundedRectangle(cornerRadius: 22.5))
                            }
                            // Text
                            Text(item.keyword ?? "")
                                .foregroundColor(Color(.label))
                                .font(.system(size: 16))
                            
                            Spacer()
                            
                            if viewModel.searchText.count == 0{
                                // ❌ Delete Button
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
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(14)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .onTapGesture {
                            searchedItem(item.keyword ?? "")
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 20)
                .onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isFocused = true
                    }
                }

            }
            .simultaneousGesture(
                DragGesture().onChanged { _ in
                    UIApplication.shared.endEditing()
                }
            )
        }
        .background(Color(.systemGray5).opacity(0.3))
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear{
            
        }
    }
}
