//
//  FavoritesView.swift
//  GetKart
//
//  Created by Radheshyam Yadav on 25/02/25.
//

import SwiftUI
import Kingfisher


struct FavoritesView: View {
   var navigation:UINavigationController?

    @State private var selectedTab: FavoritesTab = .posts

    var body: some View {
        VStack(spacing: 0) {

            // Header
            HeaderView(navigation: navigation)

            // Tabs
            tabBar.padding(.bottom,5)

            // Swipe Content
            TabView(selection: $selectedTab) {

                FavoriteAdsView(navigation:navigation)
                    .tag(FavoritesTab.posts)

                FavoriteBoardView(navigationController: navigation)
                    .tag(FavoritesTab.boards)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(Color(.systemGroupedBackground))
    }
}


#Preview {
    FavoritesView()
}

extension FavoritesView {

    var tabBar: some View {
        HStack {
            ForEach(FavoritesTab.allCases, id: \.self) { tab in
                VStack(spacing: 8) {

                    Text(tab.title)
                        .font(Font.inter((selectedTab == tab ? .medium : .medium), size: 15))

                        .foregroundColor(Color(.label))

                    Rectangle()
                        .fill(selectedTab == tab ? Color.orange : Color.clear)
                        .frame(height: 2)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal)
        .background(Color(UIColor.systemBackground))
    }
}



enum FavoritesTab: Int, CaseIterable {
    case posts = 0
    case boards = 1

    var title: String {
        switch self {
        case .posts: return "Ads"
        case .boards: return "Boards"
        }
    }
}

struct HeaderView: View {
   var navigation:UINavigationController?
    var body: some View {
        HStack{
            
            Button(action: {
                // Action to go back
                navigation?.popViewController(animated: true)
            }) {
                Image("arrow_left").renderingMode(.template)
                    .foregroundColor(Color(UIColor.label))
                    .padding(.leading)
            }
            Text("Favorites").font(Font.inter(.semiBold, size: 18))
                .foregroundColor(Color(UIColor.label))
            
            Spacer()
        }.frame(height:44).background(Color(UIColor.systemBackground))
    }
}
